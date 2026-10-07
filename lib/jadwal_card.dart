// ============================================================
// FILE: lib/widgets/jadwal_card.dart
// FUNGSI: Widget card untuk item timeline jadwal.
//         Menampilkan satu baris jadwal dengan indikator waktu dan status.
// ============================================================

import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../utils/app_theme.dart';
import 'status_badge.dart';

class JadwalCard extends StatelessWidget {
  final Jadwal jadwal;
  final StatusJadwal status;

  // isLast: jika true, tidak tampilkan garis bawah di timeline
  final bool isLast;

  // onTap: fungsi yang dipanggil ketika card ditekan
  final VoidCallback? onTap;

  const JadwalCard({
    super.key,
    required this.jadwal,
    required this.status,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == StatusJadwal.sedangBerlangsung;
    final bool isSelesai = status == StatusJadwal.selesai;

    // Warna titik di timeline berdasarkan status
    Color dotColor;
    if (isActive) {
      dotColor = AppColors.statusGreen;
    } else if (isSelesai) {
      dotColor = AppColors.statusGrey.withOpacity(0.4);
    } else {
      dotColor = AppColors.primary;
    }

    // IntrinsicHeight memastikan Row memiliki tinggi yang sama
    // dengan child terpanjangnya. Diperlukan agar garis timeline
    // bisa menjangkau dari atas sampai bawah setiap item.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KIRI: Kolom timeline (jam + titik + garis) ──
          SizedBox(
            width: 56,
            child: Column(
              children: [
                // Label jam mulai
                Text(
                  jadwal.jamMulai.teks,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelesai
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Titik bulat di timeline
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),

                // Garis penghubung ke item berikutnya (tidak ditampilkan di item terakhir)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── KANAN: Konten card jadwal ──
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                // Margin bawah agar ada jarak antar card (kecuali yang terakhir)
                margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  // Card aktif punya background hijau muda
                  color: isActive
                      ? AppColors.primarySurface
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris atas: nama matakuliah + badge status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            jadwal.mataKuliah,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelesai
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: status, compact: true),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Jam kuliah
                    Text(
                      '${jadwal.jamMulai.teks} – ${jadwal.jamSelesai.teks}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelesai
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : AppColors.textSecondary,
                      ),
                    ),

                    // Ruangan
                    Text(
                      jadwal.ruangan,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelesai
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
