// ============================================================
// FILE: lib/screens/semua_jadwal_screen.dart
// FUNGSI: Halaman daftar semua jadwal kuliah mingguan (Senin - Jumat)
// ============================================================

import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../utils/app_theme.dart';
import '../services/schedule_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/detail_jadwal_sheet.dart';
import 'tambah_jadwal_screen.dart';

class SemuaJadwalScreen extends StatefulWidget {
  const SemuaJadwalScreen({super.key});

  @override
  State<SemuaJadwalScreen> createState() => _SemuaJadwalScreenState();
}

class _SemuaJadwalScreenState extends State<SemuaJadwalScreen> {
  // Hari kerja yang ditampilkan pada tab
  final List<Hari> _daftarHari = [
    Hari.senin,
    Hari.selasa,
    Hari.rabu,
    Hari.kamis,
    Hari.jumat,
  ];

  late Hari _hariTerpilih;

  @override
  void initState() {
    super.initState();
    // Default hari yang dipilih:
    // Jika hari ini Senin-Jumat, pilih hari ini.
    // Jika akhir pekan (Sabtu/Minggu), default ke Senin.
    final hariIni = hariSekarang();
    if (_daftarHari.contains(hariIni)) {
      _hariTerpilih = hariIni;
    } else {
      _hariTerpilih = Hari.senin;
    }
    ScheduleService.instance.perubahan.addListener(_jadwalBerubah);
  }

  void _jadwalBerubah() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ScheduleService.instance.perubahan.removeListener(_jadwalBerubah);
    super.dispose();
  }

  Future<void> _tambahJadwal() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TambahJadwalScreen()),
    );
  }

  Future<void> _bukaDetail(Jadwal jadwal) async {
    final aksi = await DetailJadwalSheet.tampilkan(context, jadwal);
    if (!mounted || aksi == null) return;

    if (aksi == AksiDetailJadwal.edit) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TambahJadwalScreen(jadwal: jadwal)),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    // Ambil jadwal untuk hari yang sedang dipilih di tab
    final jadwalHariIni = jadwalUntukHari(
      ScheduleService.instance.semuaJadwal,
      _hariTerpilih,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            _buildHeader(),

            // ── SELECTOR HARI (SEN, SEL, RAB, KAM, JUM) ──
            _buildDaySelector(),

            const SizedBox(height: 12),

            // ── INFO JUMLAH JADWAL ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    _hariTerpilih.nama.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${jadwalHariIni.length} Kelas',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── DAFTAR CARD JADWAL ──
            Expanded(
              child: jadwalHariIni.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: jadwalHariIni.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final jadwal = jadwalHariIni[index];
                        return _buildCardJadwal(jadwal);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahJadwal,
        icon: const Icon(Icons.add),
        label: const Text('Tambah jadwal'),
      ),
    );
  }

  // ──────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Semua Jadwal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '$namaProdi • $jenjang',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // DAY SELECTOR: Tombol Tab Hari SEN - JUM
  // ──────────────────────────────────────────
  Widget _buildDaySelector() {
    final hariIni = hariSekarang();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: _daftarHari.map((hari) {
            final isSelected = hari == _hariTerpilih;
            final isToday = hari == hariIni;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hariTerpilih = hari;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hari.singkatan,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.primary : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Titik kecil jika hari tersebut adalah hari ini
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isToday
                              ? (isSelected ? Colors.white : AppColors.primary)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // CARD JADWAL
  // ──────────────────────────────────────────
  Widget _buildCardJadwal(Jadwal jadwal) {
    final status = statusJadwal(jadwal);
    final isHariIni = jadwal.hari == hariSekarang();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isHariIni && status == StatusJadwal.sedangBerlangsung)
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _bukaDetail(jadwal),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Jam Kuliah + Status Badge (jika hari ini)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            jadwal.tampilJam,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isHariIni)
                      StatusBadge(status: status, compact: true)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${jadwal.sks} SKS',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Nama Mata Kuliah
                Text(
                  jadwal.mataKuliah,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Gedung & Ruangan
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        jadwal.tampilLokasi,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Dosen Pengampu
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        jadwal.dosen,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Tag Jenis Kuliah
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    jadwal.jenis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // EMPTY STATE JADWAL
  // ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access_outlined,
            size: 56,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada kuliah hari ${_hariTerpilih.nama}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tidak ada jadwal kelas yang terdaftar.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

