// ============================================================
// FILE: lib/utils/app_theme.dart
// FUNGSI: Semua warna dan tema terpusat di sini.
//         Jika ingin mengubah warna aplikasi, ubah di file ini saja.
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// AppColors: Semua warna yang digunakan di aplikasi
// ============================================================
class AppColors {
  // Warna utama: Deep Emerald Green
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primarySurface = Color(0xFFE8F5E9); // hijau sangat muda

  // Background & Card
  static const Color background = Color(0xFFF7F8FA); // off-white elegan
  static const Color cardBackground = Colors.white;

  // Teks
  static const Color textPrimary = Color(0xFF1C1C1E);   // hampir hitam
  static const Color textSecondary = Color(0xFF6B7280); // abu-abu

  // Status Warna
  static const Color statusGreen = Color(0xFF2E7D32);   // sedang berlangsung
  static const Color statusGreenBg = Color(0xFFE8F5E9);
  static const Color statusBlue = Color(0xFF0277BD);    // berikutnya
  static const Color statusBlueBg = Color(0xFFE1F5FE);
  static const Color statusGrey = Color(0xFF9E9E9E);    // selesai
  static const Color statusGreyBg = Color(0xFFF5F5F5);
  static const Color statusOrange = Color(0xFFF57C00);  // reminder
  static const Color statusOrangeBg = Color(0xFFFFF3E0);

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Dark mode versions
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE5E5E5);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color borderDark = Color(0xFF2A2A2A);
}

// ============================================================
// AppTheme: ThemeData lengkap untuk light dan dark mode
// Dipanggil dari main.dart
// ============================================================
class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // Card theme
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),

    // Bottom navigation bar theme (Material 3 menggunakan NavigationBar)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      indicatorColor: AppColors.primarySurface,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: AppColors.textSecondary);
      }),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF66BB6A), // lebih cerah di dark mode
      surface: AppColors.backgroundDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,

    cardTheme: CardTheme(
      color: AppColors.cardBackgroundDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark),
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.cardBackgroundDark,
      indicatorColor: AppColors.primary.withOpacity(0.3),
    ),
  );
}
