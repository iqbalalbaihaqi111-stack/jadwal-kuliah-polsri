// ============================================================
// FILE: lib/widgets/section_header.dart
// FUNGSI: Widget judul section (contoh: "JADWAL HARI INI")
//         Bisa dipakai berulang kali di mana saja.
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  // trailing: widget opsional di kanan header (contoh: tombol "Lihat semua")
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Teks judul section — semua huruf kapital, spasi antar huruf
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),

          // Jika ada trailing widget, tampilkan di kanan
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
