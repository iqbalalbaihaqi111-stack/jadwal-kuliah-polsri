// ============================================================
// FILE: lib/widgets/status_badge.dart
// FUNGSI: Widget badge status jadwal yang bisa dipakai di mana saja.
//         Menampilkan status dengan warna yang sesuai.
// ============================================================

import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../utils/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final StatusJadwal status;

  // compact: jika true, badge lebih kecil (untuk list/timeline)
  // jika false, badge lebih besar (untuk card utama)
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna dan teks berdasarkan status
    Color bgColor;
    Color textColor;
    String teks;
    bool showDot;

    switch (status) {
      case StatusJadwal.sedangBerlangsung:
        bgColor = AppColors.statusGreenBg;
        textColor = AppColors.statusGreen;
        teks = 'SEDANG BERLANGSUNG';
        showDot = true;
        break;
      case StatusJadwal.belumMulai:
        bgColor = AppColors.statusBlueBg;
        textColor = AppColors.statusBlue;
        teks = 'BERIKUTNYA';
        showDot = false;
        break;
      case StatusJadwal.selesai:
        bgColor = AppColors.statusGreyBg;
        textColor = AppColors.statusGrey;
        teks = 'SELESAI';
        showDot = false;
        break;
    }

    final double fontSize = compact ? 10 : 11;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // badge hanya selebar isinya
        children: [
          // Titik animasi hijau untuk "sedang berlangsung"
          if (showDot) ...[
            Container(
              width: compact ? 6 : 7,
              height: compact ? 6 : 7,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            teks,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
