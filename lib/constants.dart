// ============================================================
// FILE: lib/utils/constants.dart
// FUNGSI: Menyimpan data jadwal kuliah dan konstanta aplikasi
// ============================================================

import '../models/jadwal.dart';

// ============================================================
// INFORMASI MAHASISWA
// ============================================================
const String namaProdi = 'Manajemen Informatika';
const String jenjang = 'D3';
const String namaAplikasi = 'Jadwal Kuliah';
const String versiAplikasi = '1.0.0';

// ============================================================
// NOTIFICATION CHANNEL IDs
// (Akan digunakan di Tahap Notifikasi nanti)
// ============================================================
const String channelIdJadwal = 'jadwal_kuliah_channel';
const String channelIdReminder = 'jadwal_reminder_channel';
const String channelNamaJadwal = 'Jadwal Kuliah';
const String channelNamaReminder = 'Pengingat Kuliah';

// ============================================================
// DATA JADWAL KULIAH (SEED DATA)
//
// Ini adalah data awal yang dimasukkan ke aplikasi.
// Semua data jadwal kuliah kamu ada di sini.
//
// CATATAN TEKNIS:
// - id: string unik untuk membedakan setiap jadwal
// - jamMulai & jamSelesai: disimpan sebagai integer (jam, menit)
//   agar mudah dibandingkan dengan DateTime untuk scheduling notifikasi
// ============================================================
final List<Jadwal> jadwalSeedData = [
  // ──────────────────────────────────────────
  // SENIN
  // ──────────────────────────────────────────
  Jadwal(
    id: 'sen_01',
    hari: Hari.senin,
    mataKuliah: 'Matematika Dasar',
    dosen: 'Nurul Ilma Hasana Kurnia, S.Kom., M.Kom.',
    gedung: 'Gedung B.Inggris Lt.3',
    ruangan: 'Teori 2',
    jamMulai: const JamWaktu(jam: 7, menit: 0),
    jamSelesai: const JamWaktu(jam: 9, menit: 30),
    sks: 3,
    jenis: 'Teori',
  ),
  Jadwal(
    id: 'sen_02',
    hari: Hari.senin,
    mataKuliah: 'Sistem Komputer',
    dosen: 'Devi Sartika, S.Kom., M.AB',
    gedung: 'Gedung MI Lt.3',
    ruangan: 'Lab 7',
    jamMulai: const JamWaktu(jam: 10, menit: 0),
    jamSelesai: const JamWaktu(jam: 12, menit: 30),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),

  // ──────────────────────────────────────────
  // SELASA
  // ──────────────────────────────────────────
  Jadwal(
    id: 'sel_01',
    hari: Hari.selasa,
    mataKuliah: 'Agama',
    dosen: 'Lola Fadilah, M.Pd.',
    gedung: 'Gedung MI Lt.2',
    ruangan: 'Teori 4',
    jamMulai: const JamWaktu(jam: 7, menit: 0),
    jamSelesai: const JamWaktu(jam: 8, menit: 40),
    sks: 2,
    jenis: 'Teori',
  ),
  Jadwal(
    id: 'sel_02',
    hari: Hari.selasa,
    mataKuliah: 'Bahasa Indonesia',
    dosen: 'Ayu Octarina, S.Pd., M.Pd',
    gedung: 'Gedung MI Lt.2',
    ruangan: 'Teori 4',
    jamMulai: const JamWaktu(jam: 8, menit: 40),
    jamSelesai: const JamWaktu(jam: 10, menit: 50),
    sks: 2,
    jenis: 'Teori',
  ),
  Jadwal(
    id: 'sel_03',
    hari: Hari.selasa,
    mataKuliah: 'Aplikasi Bisnis',
    dosen: 'Marti Utari, S.Pd., M.Si',
    gedung: 'Gedung MI Lt.2',
    ruangan: 'Teori 4',
    jamMulai: const JamWaktu(jam: 10, menit: 50),
    jamSelesai: const JamWaktu(jam: 11, menit: 40),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),
  Jadwal(
    id: 'sel_04',
    hari: Hari.selasa,
    mataKuliah: 'Algoritma dan Pemrograman',
    dosen: 'Yusniatri, S.Kom., M.Kom',
    gedung: 'Gedung MI Lt.2',
    ruangan: 'Teori 4',
    jamMulai: const JamWaktu(jam: 11, menit: 40),
    jamSelesai: const JamWaktu(jam: 12, menit: 30),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),

  // ──────────────────────────────────────────
  // RABU
  // ──────────────────────────────────────────
  Jadwal(
    id: 'rab_01',
    hari: Hari.rabu,
    mataKuliah: 'Desain Grafis',
    dosen: 'Indra Satriadi, S.T., M.Kom',
    gedung: 'Gedung MI Lt.3',
    ruangan: 'Lab 7',
    jamMulai: const JamWaktu(jam: 7, menit: 0),
    jamSelesai: const JamWaktu(jam: 9, menit: 30),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),
  Jadwal(
    id: 'rab_02',
    hari: Hari.rabu,
    mataKuliah: 'Aplikasi Bisnis',
    dosen: 'Marti Utari, S.Pd., M.Si',
    gedung: 'Gedung MI Lt.3',
    ruangan: 'Lab 7',
    jamMulai: const JamWaktu(jam: 10, menit: 0),
    jamSelesai: const JamWaktu(jam: 12, menit: 30),
    sks: 2,
    // CATATAN: Data "2 SKS" dan "1 Teori, 2 Praktek" dipertahankan
    // sesuai permintaan tanpa perubahan meskipun terlihat tidak konsisten
    jenis: '1 Teori, 2 Praktek',
  ),

  // ──────────────────────────────────────────
  // KAMIS
  // ──────────────────────────────────────────
  Jadwal(
    id: 'kam_01',
    hari: Hari.kamis,
    mataKuliah: 'Bahasa Inggris Komunikasi',
    dosen: 'Darmaliana, M.Pd.',
    gedung: 'Gedung B.Inggris Lt.3',
    ruangan: 'Teori 4',
    jamMulai: const JamWaktu(jam: 7, menit: 0),
    jamSelesai: const JamWaktu(jam: 8, menit: 40),
    sks: 2,
    jenis: 'Teori',
  ),
  Jadwal(
    id: 'kam_02',
    hari: Hari.kamis,
    mataKuliah: 'Desain Grafis',
    dosen: 'Indra Satriadi, S.T., M.Kom',
    gedung: 'Gedung MI Lt.3',
    ruangan: 'Lab 3',
    jamMulai: const JamWaktu(jam: 8, menit: 40),
    jamSelesai: const JamWaktu(jam: 9, menit: 30),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),
  Jadwal(
    id: 'kam_03',
    hari: Hari.kamis,
    mataKuliah: 'Algoritma dan Pemrograman',
    dosen: 'Yusniatri, S.Kom., M.Kom',
    gedung: 'Gedung MI Lt.3',
    ruangan: 'Lab 6',
    jamMulai: const JamWaktu(jam: 10, menit: 0),
    jamSelesai: const JamWaktu(jam: 12, menit: 30),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),

  // ──────────────────────────────────────────
  // JUMAT
  // ──────────────────────────────────────────
  Jadwal(
    id: 'jum_01',
    hari: Hari.jumat,
    mataKuliah: 'Sistem Operasi',
    dosen: 'Robinson, S.Kom., M.Kom.',
    gedung: 'Gedung MI Lt.3',
    ruangan: 'Lab 4',
    jamMulai: const JamWaktu(jam: 7, menit: 0),
    jamSelesai: const JamWaktu(jam: 9, menit: 30),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),
  Jadwal(
    id: 'jum_02',
    hari: Hari.jumat,
    mataKuliah: 'Sistem Operasi',
    dosen: 'Devi Sartika, S.Kom., M.AB',
    gedung: 'Gedung MI Lt.2',
    ruangan: 'Teori 2',
    jamMulai: const JamWaktu(jam: 10, menit: 0),
    jamSelesai: const JamWaktu(jam: 10, menit: 50),
    sks: 2,
    jenis: '1 Teori, 1 Praktek',
  ),
];
