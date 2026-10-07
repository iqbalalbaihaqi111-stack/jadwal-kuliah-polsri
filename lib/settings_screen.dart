import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pengingat30Menit = true;
  bool _notifikasiKuliahMulai = true;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muatPreferensi();
  }

  Future<void> _muatPreferensi() async {
    final storage = StorageService.instance;
    if (mounted) {
      setState(() {
        _pengingat30Menit = storage.ambilPengingat30Menit();
        _notifikasiKuliahMulai = storage.ambilNotifikasiKuliahMulai();
        _memuat = false;
      });
    }
  }

  Future<void> _ubahPengingat30Menit(bool aktif) async {
    setState(() => _pengingat30Menit = aktif);
    await StorageService.instance.simpanPengingat30Menit(aktif);
    await NotificationService().sinkronkanNotifikasiJadwal();
  }

  Future<void> _ubahNotifikasiKuliahMulai(bool aktif) async {
    setState(() => _notifikasiKuliahMulai = aktif);
    await StorageService.instance.simpanNotifikasiKuliahMulai(aktif);
    await NotificationService().sinkronkanNotifikasiJadwal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'NOTIFIKASI JADWAL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: _pengingat30Menit,
                        onChanged: _ubahPengingat30Menit,
                        secondary: const Icon(Icons.notifications_outlined),
                        title: const Text('30 menit sebelum kuliah'),
                        subtitle: const Text('Pengingat menjelang kelas dimulai'),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile.adaptive(
                        value: _notifikasiKuliahMulai,
                        onChanged: _ubahNotifikasiKuliahMulai,
                        secondary: const Icon(Icons.school_outlined),
                        title: const Text('Saat kuliah dimulai'),
                        subtitle: const Text('Pengingat pada jam mulai kelas'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pengingat berulang setiap minggu sesuai hari dan jam pada jadwal kuliah.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}