// ============================================================
// FILE: lib/models/tugas.dart
// FUNGSI: Model data untuk satu tugas kuliah, beserta logika
//         status urgensi (Merah < 1 hari, Kuning < 3 hari, Hijau >= 3 hari)
// ============================================================

import 'package:flutter/material.dart';

enum UrgensiTugas {
  mepet,    // < 1 hari (Merah)
  mendekati,// < 3 hari (Kuning/Orange)
  santai,   // >= 3 hari (Hijau)
  lewat,    // Deadline sudah terlewati
}

class Tugas {
  final String id;
  final String judul;
  final String mataKuliah;
  final DateTime deadline;
  final String catatan;
  final bool isSelesai;

  const Tugas({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.deadline,
    this.catatan = '',
    this.isSelesai = false,
  });

  // Salinan dengan perubahan (immutable update)
  Tugas copyWith({
    String? id,
    String? judul,
    String? mataKuliah,
    DateTime? deadline,
    String? catatan,
    bool? isSelesai,
  }) {
    return Tugas(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      deadline: deadline ?? this.deadline,
      catatan: catatan ?? this.catatan,
      isSelesai: isSelesai ?? this.isSelesai,
    );
  }

  // Menghitung status urgensi berdasarkan selisih waktu dari sekarang
  UrgensiTugas get urgensi {
    if (isSelesai) return UrgensiTugas.santai;
    final sekarang = DateTime.now();
    final selisih = deadline.difference(sekarang);

    if (selisih.isNegative) {
      return UrgensiTugas.lewat;
    } else if (selisih.inHours < 24) {
      // Kurang dari 1 hari -> Merah (Mepet)
      return UrgensiTugas.mepet;
    } else if (selisih.inDays < 3) {
      // Kurang dari 3 hari -> Kuning/Orange (Mendekati)
      return UrgensiTugas.mendekati;
    } else {
      // 3 hari atau lebih -> Hijau (Santai)
      return UrgensiTugas.santai;
    }
  }

  // Warna indikator urgensi
  Color get warnaUrgensi {
    if (isSelesai) return const Color(0xFF9E9E9E);
    switch (urgensi) {
      case UrgensiTugas.lewat:
        return const Color(0xFFD32F2F); // Merah tua
      case UrgensiTugas.mepet:
        return const Color(0xFFE53935); // Merah cerah
      case UrgensiTugas.mendekati:
        return const Color(0xFFFFA000); // Kuning / Amber
      case UrgensiTugas.santai:
        return const Color(0xFF2E7D32); // Hijau
    }
  }

  // Background tipis untuk badge urgensi
  Color get warnaUrgensiBg {
    if (isSelesai) return const Color(0xFFF5F5F5);
    switch (urgensi) {
      case UrgensiTugas.lewat:
        return const Color(0xFFFFEBEE);
      case UrgensiTugas.mepet:
        return const Color(0xFFFFEBEE);
      case UrgensiTugas.mendekati:
        return const Color(0xFFFFF8E1);
      case UrgensiTugas.santai:
        return const Color(0xFFE8F5E9);
    }
  }

  // Label teks sisa waktu
  String get teksSisaWaktu {
    if (isSelesai) return 'Selesai';
    final sekarang = DateTime.now();
    final selisih = deadline.difference(sekarang);

    if (selisih.isNegative) {
      final lewat = sekarang.difference(deadline);
      if (lewat.inDays > 0) {
        return 'Lewat ${lewat.inDays} hari';
      } else if (lewat.inHours > 0) {
        return 'Lewat ${lewat.inHours} jam';
      } else {
        return 'Lewat ${lewat.inMinutes} menit';
      }
    }

    if (selisih.inDays > 0) {
      final sisaJam = selisih.inHours % 24;
      if (sisaJam > 0 && selisih.inDays < 3) {
        return '${selisih.inDays} hari ${sisaJam} jam lagi';
      }
      return '${selisih.inDays} hari lagi';
    } else if (selisih.inHours > 0) {
      final sisaMenit = selisih.inMinutes % 60;
      return '${selisih.inHours} jam ${sisaMenit} menit lagi';
    } else {
      return '${selisih.inMinutes} menit lagi';
    }
  }

  // Teks judul urgensi
  String get labelUrgensi {
    if (isSelesai) return 'SELESAI';
    switch (urgensi) {
      case UrgensiTugas.lewat:
        return 'TERLEWAT';
      case UrgensiTugas.mepet:
        return '< 1 HARI';
      case UrgensiTugas.mendekati:
        return '< 3 HARI';
      case UrgensiTugas.santai:
        return 'AMAN';
    }
  }

  // Serialisasi untuk penyimpanan Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'mataKuliah': mataKuliah,
      'deadline': deadline.millisecondsSinceEpoch,
      'catatan': catatan,
      'isSelesai': isSelesai,
    };
  }

  // Deserialisasi dari Hive
  factory Tugas.fromMap(Map<dynamic, dynamic> map) {
    return Tugas(
      id: map['id'] as String,
      judul: map['judul'] as String,
      mataKuliah: map['mataKuliah'] as String,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
      catatan: (map['catatan'] as String?) ?? '',
      isSelesai: (map['isSelesai'] as bool?) ?? false,
    );
  }
}

