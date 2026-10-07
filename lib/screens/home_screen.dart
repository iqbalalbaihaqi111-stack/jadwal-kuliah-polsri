// ============================================================
// FILE: lib/screens/home_screen.dart
// FUNGSI: Halaman utama (dashboard) aplikasi Jadwal Kuliah.
//         Menampilkan jadwal hari ini, kuliah yang sedang
//         berlangsung, kuliah berikutnya, dan timeline.
// ============================================================

import 'dart:async'; // untuk Timer
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/jadwal.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../utils/app_theme.dart';
import '../services/schedule_service.dart';
import '../widgets/section_header.dart';
import '../widgets/jadwal_card.dart';
import '../widgets/detail_jadwal_sheet.dart';
import 'tambah_jadwal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Timer untuk memperbarui UI setiap 30 detik
  // Ini HANYA untuk UI (countdown, status kelas)
  // BUKAN untuk notifikasi — notifikasi akan dibuat di Tahap Notifikasi
  Timer? _timer;

  // Data yang ditampilkan
  late Hari _hariIni;
  late List<Jadwal> _jadwalHariIni;

  @override
  void initState() {
    super.initState();
    _refreshData(); // muat data saat halaman pertama dibuka
    ScheduleService.instance.perubahan.addListener(_jadwalBerubah);

    // Perbarui tampilan setiap 30 detik agar status jadwal akurat
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(_refreshData);
      }
    });
  }

  // Memuat ulang data jadwal hari ini
  void _refreshData() {
    _hariIni = hariSekarang();
    _jadwalHariIni = jadwalUntukHari(
      ScheduleService.instance.semuaJadwal,
      _hariIni,
    );
  }

  void _jadwalBerubah() {
    if (mounted) setState(_refreshData);
  }

  Future<void> _bukaDetailJadwal(Jadwal jadwal) async {
    final aksi = await DetailJadwalSheet.tampilkan(context, jadwal);
    if (!mounted || aksi == null) return;
    if (aksi == AksiDetailJadwal.edit) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TambahJadwalScreen(jadwal: jadwal)),
      );
    } else {
      final hapus = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus jadwal?'),
          content: Text('Jadwal ${jadwal.mataKuliah} akan dihapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
      if (hapus == true) {
        await ScheduleService.instance.hapusJadwal(jadwal.id);
      }
    }
  }

  // Fungsi untuk membuka LMS POLSRI di browser eksternal HP
  Future<void> _bukaLmsPolsri() async {
    final uri = Uri.parse('https://lms1.polsri.ac.id/login/index.php?loginredirect=1');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka LMS POLSRI'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka link: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // PENTING: selalu cancel timer ketika widget dihapus dari tree
    // agar tidak terjadi memory leak
    _timer?.cancel();
    ScheduleService.instance.perubahan.removeListener(_jadwalBerubah);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil jadwal sedang berlangsung dan jadwal berikutnya
    final sedang = jadwalSedangBerlangsung(_jadwalHariIni);
    final berikutnya = jadwalBerikutnya(_jadwalHariIni);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER (tidak scroll) ──
            _buildHeader(),

            // ── KONTEN (bisa di-scroll) ──
            Expanded(
              child: RefreshIndicator(
                // Tarik ke bawah untuk refresh status jadwal
                onRefresh: () async {
                  setState(_refreshData);
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── SECTION: KULIAH SEKARANG ──
                      // Hanya ditampilkan jika ada kelas yang sedang berlangsung
                      if (sedang != null) ...[
                        const SectionHeader(title: 'KULIAH SEKARANG'),
                        _buildKuliahSekarangCard(sedang),
                        const SizedBox(height: 24),
                      ],

                      // ── SECTION: BERIKUTNYA ──
                      // Hanya ditampilkan jika ada kelas berikutnya
                      if (berikutnya != null) ...[
                        const SectionHeader(title: 'BERIKUTNYA'),
                        _buildBerikutnyaCard(berikutnya),
                        const SizedBox(height: 24),
                      ],

                      // ── SECTION: JADWAL HARI INI ──
                      // Selalu ditampilkan (atau empty state jika tidak ada jadwal)
                      const SectionHeader(title: 'JADWAL HARI INI'),
                      _jadwalHariIni.isEmpty
                          ? _buildEmptyState()
                          : _buildTimeline(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // WIDGET: Header halaman
  // ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        // Garis tipis di bawah header
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teks header
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama aplikasi + icon
                Row(
                  children: [
                    const Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Jadwal Kuliah',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Program studi
                const Text(
                  '$namaProdi • $jenjang',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),

                // Tanggal hari ini
                Text(
                  formatTanggalSingkat(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Buka LMS POLSRI dengan Logo & teks LMS
          Tooltip(
            message: 'Buka LMS POLSRI',
            child: InkWell(
              onTap: _bukaLmsPolsri,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_polsri.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.school,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'LMS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol refresh (opsional, bisa ditekan selain pull-to-refresh)
          IconButton(
            onPressed: () => setState(_refreshData),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            iconSize: 20,
            tooltip: 'Perbarui',
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // WIDGET: Card besar "Kuliah Sekarang"
  // Card dengan background warna hijau utama
  // ──────────────────────────────────────────
  Widget _buildKuliahSekarangCard(Jadwal jadwal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        // Gradient dari hijau gelap ke hijau sedikit lebih terang
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E20), // deep emerald
            Color(0xFF2E7D32), // sedikit lebih terang
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titik hijau cerah (indikator aktif)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF69F0AE), // hijau mint
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'SEDANG BERLANGSUNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Nama mata kuliah (paling besar dan paling mencolok)
          Text(
            jadwal.mataKuliah,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 14),

          // Jam kuliah
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                jadwal.tampilJam,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Lokasi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${jadwal.gedung}  •  ${jadwal.ruangan}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Dosen
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  jadwal.dosen,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Garis pemisah tipis
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),

          const SizedBox(height: 12),

          // SKS & jenis kuliah
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                jadwal.tampilSks,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // WIDGET: Card "Berikutnya"
  // Card putih dengan countdown waktu tersisa
  // ──────────────────────────────────────────
  Widget _buildBerikutnyaCard(Jadwal jadwal) {
    final sisa = sisaWaktuMenuju(jadwal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: badge + countdown
          Row(
            children: [
              // Badge "BERIKUTNYA"
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BERIKUTNYA',
                  style: TextStyle(
                    color: AppColors.statusBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Countdown sisa waktu
              if (sisa.isNotEmpty) ...[
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'dalam $sisa',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Nama mata kuliah
          Text(
            jadwal.mataKuliah,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          // Jam
          Row(
            children: [
              const Icon(Icons.schedule,
                  color: AppColors.textSecondary, size: 15),
              const SizedBox(width: 6),
              Text(
                jadwal.tampilJam,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Lokasi
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.textSecondary, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${jadwal.gedung}  •  ${jadwal.ruangan}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Dosen
          Row(
            children: [
              const Icon(Icons.person,
                  color: AppColors.textSecondary, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  jadwal.dosen,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // SKS & jenis
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              jadwal.tampilSks,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // WIDGET: Timeline jadwal hari ini
  // ──────────────────────────────────────────
  Widget _buildTimeline() {
    return Column(
      children: _jadwalHariIni.asMap().entries.map((entry) {
        final index = entry.key;
        final jadwal = entry.value;
        final isLast = index == _jadwalHariIni.length - 1;
        final status = statusJadwal(jadwal);

        return JadwalCard(
          jadwal: jadwal,
          status: status,
          isLast: isLast,
          onTap: () {
            _bukaDetailJadwal(jadwal);
          },
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────
  // WIDGET: Empty state (tidak ada jadwal hari ini)
  // ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            // Judul
            const Text(
              'Tidak ada kuliah hari ini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Subjudul
            const Text(
              'Manfaatkan waktumu untuk\nistirahat atau belajar mandiri.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
