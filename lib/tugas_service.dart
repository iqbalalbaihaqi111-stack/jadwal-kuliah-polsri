// ============================================================
// FILE: lib/services/tugas_service.dart
// FUNGSI: Mengelola penyimpanan offline data tugas menggunakan Hive
//         serta otomatis mengatur jadwal notifikasi pengingat.
// ============================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../models/tugas.dart';
import 'notification_service.dart';

class TugasService {
  static final TugasService _instance = TugasService._internal();
  factory TugasService() => _instance;
  TugasService._internal();

  static const String _boxName = 'tugas_box';
  Box? _box;

  // Inisialisasi Hive Box untuk tugas
  Future<void> inisialisasi() async {
    if (_box?.isOpen ?? false) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('TugasService belum diinisialisasi. Panggil inisialisasi() terlebih dahulu.');
    }
    return _box!;
  }

  // ──────────────────────────────────────────
  // AMBIL SEMUA TUGAS (DIURUTKAN DARI DEADLINE PALING DEKAT)
  // ──────────────────────────────────────────
  List<Tugas> ambilSemuaTugas() {
    final List<Tugas> daftar = [];

    for (var value in box.values) {
      if (value is Map) {
        daftar.add(Tugas.fromMap(value));
      }
    }

    // Urutkan:
    // 1. Tugas yang belum selesai tampil di atas, sudah selesai di bawah.
    // 2. Berdasarkan waktu deadline paling dekat (ascending).
    daftar.sort((a, b) {
      if (a.isSelesai != b.isSelesai) {
        return a.isSelesai ? 1 : -1;
      }
      return a.deadline.compareTo(b.deadline);
    });

    return daftar;
  }

  // ──────────────────────────────────────────
  // TAMBAH TUGAS BARU
  // ──────────────────────────────────────────
  Future<void> tambahTugas(Tugas tugas) async {
    await box.put(tugas.id, tugas.toMap());

    // Otomatis jadwalkan notifikasi jika deadline < 1 hari
    await NotificationService().jadwalkanNotifikasiTugas(tugas);
  }

  // ──────────────────────────────────────────
  // UPDATE STATUS SELESAI / BELUM
  // ──────────────────────────────────────────
  Future<void> toggleSelesai(String id) async {
    final data = box.get(id);
    if (data is Map) {
      final tugas = Tugas.fromMap(data);
      final tugasBaru = tugas.copyWith(isSelesai: !tugas.isSelesai);
      await box.put(id, tugasBaru.toMap());

      if (tugasBaru.isSelesai) {
        await NotificationService().batalkanNotifikasiTugas(id);
      } else {
        await NotificationService().jadwalkanNotifikasiTugas(tugasBaru);
      }
    }
  }

  // ──────────────────────────────────────────
  // HAPUS TUGAS
  // ──────────────────────────────────────────
  Future<void> hapusTugas(String id) async {
    await box.delete(id);
    await NotificationService().batalkanNotifikasiTugas(id);
  }
}

