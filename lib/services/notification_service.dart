// ============================================================
// FILE: lib/services/notification_service.dart
// FUNGSI: Mengelola pengingat jadwal kuliah dan deadline tugas.
// ============================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/date_helper.dart';
import '../models/jadwal.dart';
import '../models/tugas.dart';
import 'schedule_service.dart';
import 'storage_service.dart';

class NotificationService {
  // Singleton pattern agar mudah dipanggil di mana saja
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _memantauPerubahanJadwal = false;
  bool _bisaMenjadwalkanAlarmTepat = false;
  static const List<int> _reminderHoursBeforeDeadline = [24, 18, 12, 6];
  static const int _notificationIdKuliahMulai = 0;
  static const int _notificationIdKuliah30Menit = 1;

  // Inisialisasi awal (dipanggil di main.dart)
  Future<void> inisialisasi() async {
    if (_isInitialized) return;

    // Inisialisasi timezone untuk Android scheduled notifications
    tz.initializeTimeZones();
    // Set default ke Asia/Jakarta (WIB)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Konfigurasi icon notifikasi Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Callback saat notifikasi ditekan pengguna
        debugPrint('Notifikasi ditekan: ${response.payload}');
      },
    );

    // Minta izin notifikasi (wajib untuk Android 13+)
    await mintaIzinNotifikasi();
    await mintaIzinAlarmTepat();
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    _bisaMenjadwalkanAlarmTepat =
        await androidImplementation?.canScheduleExactNotifications() ?? false;

    await sinkronkanNotifikasiJadwal();
    _isInitialized = true;
    if (!_memantauPerubahanJadwal) {
      ScheduleService.instance.perubahan.addListener(_jadwalBerubah);
      _memantauPerubahanJadwal = true;
    }
  }

  void _jadwalBerubah() {
    if (_isInitialized) {
      unawaited(sinkronkanNotifikasiJadwal());
    }
  }

  Future<void> sinkronkanNotifikasiJadwal() async {
    final storage = StorageService.instance;
    final jadwal = ScheduleService.instance.semuaJadwal;
    final idLama = storage.ambilIdJadwalNotifikasi();
    final idSekarang = jadwal.map((item) => item.id).toSet();

    for (final id in {...idLama, ...idSekarang}) {
      await _notifications.cancel(
        _notificationId('jadwal:$id', _notificationIdKuliahMulai),
      );
      await _notifications.cancel(
        _notificationId('jadwal:$id', _notificationIdKuliah30Menit),
      );
    }

    final ingatkan30Menit = storage.ambilPengingat30Menit();
    final ingatkanSaatMulai = storage.ambilNotifikasiKuliahMulai();
    for (final item in jadwal) {
      if (ingatkan30Menit) {
        await _jadwalkanNotifikasiKuliah(
          item,
          menitSebelum: 30,
          notificationId: _notificationId(
            'jadwal:${item.id}',
            _notificationIdKuliah30Menit,
          ),
          judul: 'KULIAH 30 MENIT LAGI',
        );
      }
      if (ingatkanSaatMulai) {
        await _jadwalkanNotifikasiKuliah(
          item,
          menitSebelum: 0,
          notificationId: _notificationId(
            'jadwal:${item.id}',
            _notificationIdKuliahMulai,
          ),
          judul: 'KULIAH DIMULAI',
        );
      }
    }

    await storage.simpanIdJadwalNotifikasi(idSekarang.toList());
  }

  Future<void> _jadwalkanNotifikasiKuliah(
    Jadwal jadwal, {
    required int menitSebelum,
    required int notificationId,
    required String judul,
  }) async {
    final waktuJadwal = waktuNotifikasiJadwalBerikutnya(
      jadwal,
      tz.TZDateTime.now(tz.local),
      menitSebelum: menitSebelum,
    );
    final waktuLokal = tz.TZDateTime(
      tz.local,
      waktuJadwal.year,
      waktuJadwal.month,
      waktuJadwal.day,
      waktuJadwal.hour,
      waktuJadwal.minute,
    );
    await _notifications.zonedSchedule(
      notificationId,
      judul,
      '${jadwal.mataKuliah} • ${jadwal.gedung}, ${jadwal.ruangan} (${jadwal.jamMulai.teks})',
      waktuLokal,
      NotificationDetails(
        android: _androidDetails(ongoing: false, autoCancel: true),
      ),
      androidScheduleMode: _androidScheduleMode,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: jadwal.id,
    );
  }

  // Meminta izin notifikasi (Android 13+)
  Future<bool?> mintaIzinNotifikasi() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return await androidImplementation?.requestNotificationsPermission();
  }

  Future<bool?> mintaIzinAlarmTepat() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return androidImplementation?.requestExactAlarmsPermission();
  }

  // ──────────────────────────────────────────
  // JADWALKAN NOTIFIKASI TUGAS (1 HARI SEBELUM DEADLINE)
  // ──────────────────────────────────────────
  Future<void> jadwalkanNotifikasiTugas(Tugas tugas) async {
    if (tugas.isSelesai) {
      // Jika tugas sudah selesai, batalkan notifikasinya
      await batalkanNotifikasiTugas(tugas.id);
      return;
    }

    final sekarang = DateTime.now();
    if (!tugas.deadline.isAfter(sekarang)) {
      await batalkanNotifikasiTugas(tugas.id);
      return;
    }

    try {
      for (var index = 0;
          index < _reminderHoursBeforeDeadline.length;
          index++) {
        final waktuJadwal = tugas.deadline.subtract(
          Duration(hours: _reminderHoursBeforeDeadline[index]),
        );
        if (!waktuJadwal.isAfter(sekarang) && index != 0) continue;

        final targetTime = waktuJadwal.isAfter(sekarang)
            ? waktuJadwal
            : sekarang.add(const Duration(seconds: 5));
        await _notifications.zonedSchedule(
          _notificationId(tugas.id, index),
          'DEADLINE TUGAS',
          '${tugas.judul} • ${tugas.mataKuliah}\nDeadline: ${_formatTanggal(tugas.deadline)}',
          tz.TZDateTime.from(targetTime, tz.local),
          NotificationDetails(
            android: _androidDetails(
              ongoing: index == 0,
              autoCancel: index != 0,
            ),
          ),
          androidScheduleMode: _androidScheduleMode,
          payload: tugas.id,
        );
        debugPrint('Pengingat dijadwalkan pada $targetTime untuk ${tugas.judul}');
      }
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi: $e');
    }
  }

  int _notificationId(String tugasId, int index) {
    var hash = 0x811c9dc5;
    for (final unit in '$tugasId:$index'.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  AndroidScheduleMode get _androidScheduleMode => _bisaMenjadwalkanAlarmTepat
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  String _formatTanggal(DateTime tanggal) {
    final jam = tanggal.hour.toString().padLeft(2, '0');
    final menit = tanggal.minute.toString().padLeft(2, '0');
    return '${tanggal.day}/${tanggal.month}/${tanggal.year} $jam:$menit';
  }

  AndroidNotificationDetails _androidDetails({
    required bool ongoing,
    required bool autoCancel,
  }) {
    return AndroidNotificationDetails(
      'tugas_kuliah_channel',
      'Pengingat Tugas Kuliah',
      channelDescription: 'Pengingat otomatis menjelang deadline tugas kuliah',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 180, 100, 180]),
      ongoing: ongoing,
      autoCancel: autoCancel,
    );
  }

  // ──────────────────────────────────────────
  // BATALKAN NOTIFIKASI TUGAS
  // ──────────────────────────────────────────
  Future<void> batalkanNotifikasiTugas(String tugasId) async {
    for (var index = 0;
        index < _reminderHoursBeforeDeadline.length;
        index++) {
      await _notifications.cancel(_notificationId(tugasId, index));
    }
  }

}
