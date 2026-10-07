// ============================================================
// FILE: lib/main.dart
// FUNGSI: Titik masuk aplikasi + wrapper bottom navigation
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'services/schedule_service.dart';
import 'services/storage_service.dart';
import 'services/tugas_service.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/semua_jadwal_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/daftar_tugas_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await StorageService.instance.inisialisasi();
  await ScheduleService.instance.inisialisasi();
  await TugasService().inisialisasi();
  await NotificationService().inisialisasi();
  for (final tugas in TugasService().ambilSemuaTugas()) {
    await NotificationService().jadwalkanNotifikasiTugas(tugas);
  }
  runApp(const JadwalKuliahApp());
}

// ============================================================
// JadwalKuliahApp: Widget root aplikasi
// Mengatur tema light/dark dan halaman pertama
// ============================================================
class JadwalKuliahApp extends StatelessWidget {
  const JadwalKuliahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Kuliah',
      debugShowCheckedModeBanner: false,

      // Light theme (dari app_theme.dart)
      theme: AppTheme.lightTheme,

      // Dark theme (dari app_theme.dart)
      darkTheme: AppTheme.darkTheme,

      // ThemeMode.system = ikuti pengaturan HP
      themeMode: ThemeMode.system,

      // Halaman utama: MainScreen (yang punya bottom nav)
      home: const MainScreen(),
    );
  }
}

// ============================================================
// MainScreen: Wrapper dengan Bottom Navigation Bar
//
// Kenapa kita pisahkan MainScreen dari HomeScreen?
// - MainScreen mengurus pergantian halaman (tab)
// - HomeScreen, SemuaJadwalScreen, SettingsScreen tidak perlu
//   tahu tentang navigasi — mereka fokus menampilkan konten
// ============================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index tab yang sedang aktif (0=Beranda, 1=Jadwal, 2=Pengaturan)
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  // Daftar halaman untuk setiap tab
  // Menggunakan const agar widget tidak dibangun ulang setiap ganti tab
  static const List<Widget> _screens = [
    HomeScreen(),          // Tab 0: Beranda
    SemuaJadwalScreen(),   // Tab 1: Semua Jadwal
    DaftarTugasScreen(),   // Tab 2: Tugas
    SettingsScreen(),      // Tab 3: Pengaturan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: tampilkan halaman sesuai tab yang dipilih
      body: IndexedStack(
        // IndexedStack mempertahankan state semua tab
        // (berbeda dengan _screens[_currentIndex] yang rebuild setiap ganti tab)
        index: _currentIndex,
        children: List.generate(
          _screens.length,
          (index) => _visitedTabs.contains(index)
              ? _screens[index]
              : const SizedBox.shrink(),
        ),
      ),

      // Bottom Navigation Bar — Material 3 style
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _visitedTabs.add(index);
          });
        },
        // Animasi perpindahan tab
        animationDuration: const Duration(milliseconds: 300),
        // Tinggi navigation bar
        height: 65,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
