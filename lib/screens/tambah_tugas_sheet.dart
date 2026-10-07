// ============================================================
// FILE: lib/screens/tambah_tugas_sheet.dart
// FUNGSI: Modal form modern untuk menambahkan tugas kuliah baru
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tugas.dart';
import '../services/tugas_service.dart';
import '../services/schedule_service.dart';
import '../utils/app_theme.dart';

class TambahTugasSheet extends StatefulWidget {
  final VoidCallback onTugasDitambahkan;

  const TambahTugasSheet({super.key, required this.onTugasDitambahkan});

  static void tampilkan(BuildContext context, {required VoidCallback onTugasDitambahkan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TambahTugasSheet(onTugasDitambahkan: onTugasDitambahkan),
    );
  }

  @override
  State<TambahTugasSheet> createState() => _TambahTugasSheetState();
}

class _TambahTugasSheetState extends State<TambahTugasSheet> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _mataKuliahTerpilih;
  late DateTime _tanggalDeadline;
  late TimeOfDay _jamDeadline;

  // Daftar nama mata kuliah unik dari data jadwal yang ada
  late List<String> _daftarMataKuliah;

  @override
  void initState() {
    super.initState();
    // Ambil daftar mata kuliah dari jadwalSeedData
    final setMatkul = ScheduleService.instance.semuaJadwal
      .map((jadwal) => jadwal.mataKuliah)
      .toSet()
      .toList();
    setMatkul.sort();
    setMatkul.add('Lainnya / Umum');
    _daftarMataKuliah = setMatkul;
    _mataKuliahTerpilih = _daftarMataKuliah.first;

    // Default deadline: Besok jam 23.59
    final besok = DateTime.now().add(const Duration(days: 1));
    _tanggalDeadline = DateTime(besok.year, besok.month, besok.day);
    _jamDeadline = const TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Pilih Tanggal
  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDeadline,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hasil != null) {
      setState(() {
        _tanggalDeadline = hasil;
      });
    }
  }

  // Pilih Jam
  Future<void> _pilihJam() async {
    final TimeOfDay? hasil = await showTimePicker(
      context: context,
      initialTime: _jamDeadline,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hasil != null) {
      setState(() {
        _jamDeadline = hasil;
      });
    }
  }

  // Simpan Tugas ke Hive
  Future<void> _simpanTugas() async {
    if (!_formKey.currentState!.validate()) return;

    final deadlineLengkap = DateTime(
      _tanggalDeadline.year,
      _tanggalDeadline.month,
      _tanggalDeadline.day,
      _jamDeadline.hour,
      _jamDeadline.minute,
    );

    final tugasBaru = Tugas(
      id: 'tugas_${DateTime.now().millisecondsSinceEpoch}',
      judul: _judulController.text.trim(),
      mataKuliah: _mataKuliahTerpilih ?? 'Umum',
      deadline: deadlineLengkap,
      catatan: _catatanController.text.trim(),
    );

    await TugasService().tambahTugas(tugasBaru);

    if (mounted) {
      Navigator.pop(context);
      widget.onTugasDitambahkan();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas "${tugasBaru.judul}" berhasil disimpan!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatTanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Judul Form
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Tugas Kuliah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 1. INPUT NAMA TUGAS
              const Text(
                'NAMA TUGAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Makalah Bab 3, Tugas Modul 4...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 2. PILIH MATA KULIAH
              const Text(
                'MATA KULIAH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _mataKuliahTerpilih,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                    items: _daftarMataKuliah.map((matkul) {
                      return DropdownMenuItem<String>(
                        value: matkul,
                        child: Text(
                          matkul,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _mataKuliahTerpilih = val;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. PILIH DEADLINE (TANGGAL & WAKTU)
              const Text(
                'DEADLINE PENGUMPULAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Tombol Tanggal
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _pilihTanggal,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formatTanggal.format(_tanggalDeadline),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Tombol Jam
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _pilihJam,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${_jamDeadline.hour.toString().padLeft(2, '0')}:${_jamDeadline.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. CATATAN TAMBAHAN (OPSIONAL)
              const Text(
                'CATATAN (OPSIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _catatanController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Misal: Dikirim ke email dosen atau format PDF',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. TOMBOL CONFIRM SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _simpanTugas,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Tugas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

