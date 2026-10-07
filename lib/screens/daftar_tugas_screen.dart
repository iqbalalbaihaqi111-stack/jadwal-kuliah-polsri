import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/tugas.dart';
import '../services/tugas_service.dart';
import '../utils/app_theme.dart';
import 'tambah_tugas_sheet.dart';

class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key});

  @override
  State<DaftarTugasScreen> createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  Timer? _timer;
  List<Tugas> _tugas = [];

  @override
  void initState() {
    super.initState();
    _muatTugas();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(_muatTugas);
    });
  }

  void _muatTugas() {
    _tugas = TugasService().ambilSemuaTugas();
  }

  void _bukaFormTambah() {
    TambahTugasSheet.tampilkan(
      context,
      onTugasDitambahkan: () => setState(_muatTugas),
    );
  }

  Future<void> _konfirmasiHapus(Tugas tugas) async {
    final hapus = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('"${tugas.judul}" akan dihapus dari daftar.'),
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
      await TugasService().hapusTugas(tugas.id);
      if (mounted) setState(_muatTugas);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tugasAktif = _tugas.where((tugas) => !tugas.isSelesai).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Tugas'),
      ),
      floatingActionButton: _tugas.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _bukaFormTambah,
              icon: const Icon(Icons.add),
              label: const Text('Tambah tugas'),
            ),
      body: _tugas.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                Text(
                  '$tugasAktif tugas belum selesai',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                for (final tugas in _tugas) _buildTugasCard(tugas),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 54,
              color: AppColors.primary.withOpacity(0.55),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tugas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan tugas kuliah agar deadline penting tidak terlewat.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _bukaFormTambah,
              icon: const Icon(Icons.add),
              label: const Text('Tambah tugas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTugasCard(Tugas tugas) {
    final tanggal = DateFormat('EEE, d MMM yyyy • HH:mm', 'id_ID')
        .format(tugas.deadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, color: tugas.warnaUrgensi),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: tugas.isSelesai,
                      onChanged: (_) async {
                        await TugasService().toggleSelesai(tugas.id);
                        if (mounted) setState(_muatTugas);
                      },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tugas.judul,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  decoration: tugas.isSelesai
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tugas.mataKuliah,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  tanggal,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: tugas.warnaUrgensiBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${tugas.labelUrgensi}  ·  ${tugas.teksSisaWaktu}',
                              style: TextStyle(
                                color: tugas.warnaUrgensi,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (tugas.catatan.isNotEmpty) ...[
                            const SizedBox(height: 9),
                            Text(
                              tugas.catatan,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _konfirmasiHapus(tugas),
                      tooltip: 'Hapus tugas',
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}