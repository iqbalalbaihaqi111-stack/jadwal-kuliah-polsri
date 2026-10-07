// ============================================================
// FILE: lib/widgets/detail_jadwal_sheet.dart
// FUNGSI: Modal BottomSheet untuk menampilkan informasi lengkap jadwal
// ============================================================

import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import 'status_badge.dart';

enum AksiDetailJadwal { edit, hapus }

class DetailJadwalSheet extends StatelessWidget {
  final Jadwal jadwal;

  const DetailJadwalSheet({super.key, required this.jadwal});

  // Fungsi helper untuk membuka bottom sheet ini dengan mudah
  static Future<AksiDetailJadwal?> tampilkan(
    BuildContext context,
    Jadwal jadwal,
  ) {
    return showModalBottomSheet<AksiDetailJadwal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailJadwalSheet(jadwal: jadwal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = statusJadwal(jadwal);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis pegangan (handle bar) di bagian atas pop-up
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Baris status & hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jadwal.hari.nama.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              StatusBadge(status: status, compact: true),
            ],
          ),

          const SizedBox(height: 12),

          // Nama Mata Kuliah
          Text(
            jadwal.mataKuliah,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          // Waktu Kuliah
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                jadwal.tampilJam,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 20),

          // Detail Info: Dosen
          _buildInfoTile(
            icon: Icons.person_outline,
            label: 'DOSEN PENGAMPU',
            value: jadwal.dosen,
          ),

          const SizedBox(height: 16),

          // Detail Info: Lokasi (Gedung & Ruangan)
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            label: 'LOKASI KULIAH',
            value: '${jadwal.gedung}\nRuangan: ${jadwal.ruangan}',
          ),

          const SizedBox(height: 16),

          // Detail Info: SKS & Jenis Kuliah
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.menu_book_outlined,
                  label: 'BEBAN KULIAH',
                  value: '${jadwal.sks} SKS',
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.category_outlined,
                  label: 'JENIS KELAS',
                  value: jadwal.jenis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Hapus jadwal',
                onPressed: () =>
                    Navigator.pop(context, AksiDetailJadwal.hapus),
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.pop(context, AksiDetailJadwal.edit),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Jadwal'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

