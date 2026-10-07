// ============================================================
// FILE: lib/utils/date_helper.dart
// FUNGSI: Fungsi-fungsi helper untuk tanggal, waktu, dan status jadwal
// ============================================================

import '../models/jadwal.dart';

// ============================================================
// FUNGSI: Mendapatkan hari sekarang sebagai enum Hari
// ============================================================
Hari hariSekarang() {
  // DateTime.now().weekday mengembalikan:
  // 1 = Senin, 2 = Selasa, ..., 7 = Minggu
  return HariExtension.dariWeekday(DateTime.now().weekday);
}

// ============================================================
// FUNGSI: Mendapatkan daftar jadwal untuk hari tertentu
// Mengurutkan berdasarkan jam mulai (yang paling pagi dulu)
// ============================================================
List<Jadwal> jadwalUntukHari(List<Jadwal> semuaJadwal, Hari hari) {
  final jadwalHariIni = semuaJadwal.where((j) => j.hari == hari).toList();

  // Urutkan berdasarkan jam mulai
  jadwalHariIni.sort((a, b) {
    // Bandingkan jam dulu
    if (a.jamMulai.jam != b.jamMulai.jam) {
      return a.jamMulai.jam.compareTo(b.jamMulai.jam);
    }
    // Kalau jamnya sama, bandingkan menit
    return a.jamMulai.menit.compareTo(b.jamMulai.menit);
  });

  return jadwalHariIni;
}

DateTime waktuNotifikasiJadwalBerikutnya(
  Jadwal jadwal,
  DateTime sekarang, {
  int menitSebelum = 0,
}) {
  var weekday = jadwal.hari.urutan;
  var menitDalamHari =
      jadwal.jamMulai.jam * 60 + jadwal.jamMulai.menit - menitSebelum;

  while (menitDalamHari < 0) {
    menitDalamHari += 24 * 60;
    weekday = weekday == DateTime.monday ? DateTime.sunday : weekday - 1;
  }

  final selisihHari = (weekday - sekarang.weekday + DateTime.daysPerWeek) %
      DateTime.daysPerWeek;
  var waktuJadwal = DateTime(
    sekarang.year,
    sekarang.month,
    sekarang.day + selisihHari,
    menitDalamHari ~/ 60,
    menitDalamHari % 60,
  );

  if (!waktuJadwal.isAfter(sekarang)) {
    waktuJadwal = waktuJadwal.add(const Duration(days: DateTime.daysPerWeek));
  }
  return waktuJadwal;
}

// ============================================================
// FUNGSI: Menentukan status sebuah jadwal berdasarkan waktu sekarang
// ============================================================
StatusJadwal statusJadwal(Jadwal jadwal) {
  final sekarang = DateTime.now();

  // Konversi jam mulai dan selesai ke DateTime hari ini
  final mulai = jadwal.jamMulai.keDateTime();
  final selesai = jadwal.jamSelesai.keDateTime();

  if (sekarang.isBefore(mulai)) {
    // Waktu sekarang sebelum jam mulai → belum dimulai
    return StatusJadwal.belumMulai;
  } else if (sekarang.isAfter(selesai)) {
    // Waktu sekarang setelah jam selesai → sudah selesai
    return StatusJadwal.selesai;
  } else {
    // Waktu sekarang di antara jam mulai dan selesai → sedang berlangsung
    return StatusJadwal.sedangBerlangsung;
  }
}

// ============================================================
// FUNGSI: Mencari jadwal yang sedang berlangsung sekarang
// Mengembalikan null jika tidak ada
// ============================================================
Jadwal? jadwalSedangBerlangsung(List<Jadwal> jadwalHariIni) {
  try {
    return jadwalHariIni.firstWhere(
      (j) => statusJadwal(j) == StatusJadwal.sedangBerlangsung,
    );
  } catch (_) {
    return null;
  }
}

// ============================================================
// FUNGSI: Mencari jadwal berikutnya (yang belum dimulai, terdekat)
// Mengembalikan null jika tidak ada jadwal berikutnya hari ini
// ============================================================
Jadwal? jadwalBerikutnya(List<Jadwal> jadwalHariIni) {
  final belumMulai = jadwalHariIni
      .where((j) => statusJadwal(j) == StatusJadwal.belumMulai)
      .toList();

  if (belumMulai.isEmpty) return null;

  // Jadwal pertama yang belum dimulai (sudah diurutkan, jadi ini yang terdekat)
  return belumMulai.first;
}

// ============================================================
// FUNGSI: Menghitung sisa waktu menuju kelas berikutnya
// Mengembalikan string seperti "1 jam 24 menit" atau "45 menit"
// ============================================================
String sisaWaktuMenuju(Jadwal jadwal) {
  final sekarang = DateTime.now();
  final mulai = jadwal.jamMulai.keDateTime();
  final selisih = mulai.difference(sekarang);

  if (selisih.isNegative) return '';

  final jam = selisih.inHours;
  final menit = selisih.inMinutes % 60;

  if (jam > 0 && menit > 0) {
    return '$jam jam $menit menit';
  } else if (jam > 0) {
    return '$jam jam';
  } else {
    return '$menit menit';
  }
}

// ============================================================
// FUNGSI: Format tanggal hari ini menjadi teks Bahasa Indonesia
// Contoh: "Senin, 5 Oktober 2026"
// ============================================================
String formatTanggalHariIni() {
  final sekarang = DateTime.now();

  // Nama hari dalam Bahasa Indonesia
  const namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  // Nama bulan dalam Bahasa Indonesia
  const namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // weekday: 1=Senin, 7=Minggu → index array: 0=Senin, 6=Minggu
  final hari = namaHari[sekarang.weekday - 1];
  final tanggal = sekarang.day;
  final bulan = namaBulan[sekarang.month - 1];

  return '$hari, $tanggal $bulan';
}

// ============================================================
// FUNGSI: Format tanggal singkat (untuk header)
// Contoh: "Senin, 5 Oktober"
// ============================================================
String formatTanggalSingkat() {
  final sekarang = DateTime.now();

  const namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];
  const namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final hari = namaHari[sekarang.weekday - 1];
  final tanggal = sekarang.day;
  final bulan = namaBulan[sekarang.month - 1];

  return '$hari, $tanggal $bulan';
}
