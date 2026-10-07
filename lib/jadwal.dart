// ============================================================
// FILE: lib/models/jadwal.dart
// FUNGSI: Mendefinisikan struktur data (model) untuk satu jadwal kuliah
// ============================================================

// Enum adalah tipe data khusus yang nilainya sudah ditentukan/terbatas.
// Kita pakai enum untuk Hari agar tidak bisa salah ketik (misal "senin" vs "Senin").
enum Hari {
  senin,
  selasa,
  rabu,
  kamis,
  jumat,
  sabtu,
  minggu,
}

// Extension menambahkan fungsi/property baru ke tipe yang sudah ada.
// Di sini kita tambahkan .nama dan .urutan ke enum Hari.
extension HariExtension on Hari {
  // .nama mengembalikan teks nama hari dalam Bahasa Indonesia
  String get nama {
    switch (this) {
      case Hari.senin:
        return 'Senin';
      case Hari.selasa:
        return 'Selasa';
      case Hari.rabu:
        return 'Rabu';
      case Hari.kamis:
        return 'Kamis';
      case Hari.jumat:
        return 'Jumat';
      case Hari.sabtu:
        return 'Sabtu';
      case Hari.minggu:
        return 'Minggu';
    }
  }

  // .singkatan mengembalikan singkatan 3 huruf untuk tab navigasi
  String get singkatan {
    switch (this) {
      case Hari.senin:
        return 'SEN';
      case Hari.selasa:
        return 'SEL';
      case Hari.rabu:
        return 'RAB';
      case Hari.kamis:
        return 'KAM';
      case Hari.jumat:
        return 'JUM';
      case Hari.sabtu:
        return 'SAB';
      case Hari.minggu:
        return 'MIN';
    }
  }

  // .urutan mengembalikan urutan hari (Senin = 1, ..., Minggu = 7)
  // Dart's DateTime.weekday juga menggunakan 1 = Senin, 7 = Minggu
  int get urutan {
    switch (this) {
      case Hari.senin:
        return 1;
      case Hari.selasa:
        return 2;
      case Hari.rabu:
        return 3;
      case Hari.kamis:
        return 4;
      case Hari.jumat:
        return 5;
      case Hari.sabtu:
        return 6;
      case Hari.minggu:
        return 7;
    }
  }

  // Fungsi statis untuk mengkonversi dari int weekday ke enum Hari
  // Berguna ketika kita mendapatkan hari dari DateTime.now().weekday
  static Hari dariWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return Hari.senin;
      case 2:
        return Hari.selasa;
      case 3:
        return Hari.rabu;
      case 4:
        return Hari.kamis;
      case 5:
        return Hari.jumat;
      case 6:
        return Hari.sabtu;
      case 7:
        return Hari.minggu;
      default:
        return Hari.senin;
    }
  }
}

// ============================================================
// CLASS: JamWaktu
// Menyimpan jam dan menit sebagai angka integer.
//
// ALASAN pakai integer bukan String:
// - "07.00" sebagai teks tidak bisa dibandingkan langsung dengan waktu sekarang
// - Dengan jam=7, menit=0, kita bisa langsung buat DateTime dan bandingkan
// - Lebih mudah untuk scheduling notifikasi nanti
// ============================================================
class JamWaktu {
  final int jam;   // 0-23
  final int menit; // 0-59

  const JamWaktu({required this.jam, required this.menit});

  // Mengubah JamWaktu menjadi teks "07.00" untuk ditampilkan di UI
  String get teks {
    final jamStr = jam.toString().padLeft(2, '0');
    final menitStr = menit.toString().padLeft(2, '0');
    return '$jamStr.$menitStr';
  }

  // Mengkonversi ke DateTime hari ini dengan jam dan menit ini
  // Berguna untuk membandingkan dengan DateTime.now()
  DateTime keDateTime({DateTime? tanggal}) {
    final hari = tanggal ?? DateTime.now();
    return DateTime(hari.year, hari.month, hari.day, jam, menit);
  }

  // Serialisasi ke Map (untuk penyimpanan lokal nanti)
  Map<String, dynamic> keMap() {
    return {'jam': jam, 'menit': menit};
  }

  // Deserialisasi dari Map (untuk membaca dari penyimpanan lokal nanti)
  factory JamWaktu.dariMap(Map<String, dynamic> map) {
    return JamWaktu(
      jam: map['jam'] as int,
      menit: map['menit'] as int,
    );
  }

  @override
  String toString() => teks;
}

// ============================================================
// CLASS: Jadwal
// Model utama yang merepresentasikan satu jadwal kuliah.
// ============================================================
class Jadwal {
  final String id;           // ID unik, digunakan untuk update/delete
  final Hari hari;           // Enum Hari (Senin, Selasa, dst.)
  final String mataKuliah;   // Nama mata kuliah
  final String dosen;        // Nama dosen lengkap
  final String gedung;       // Nama gedung
  final String ruangan;      // Nama ruangan
  final JamWaktu jamMulai;   // Jam kuliah dimulai (integer jam & menit)
  final JamWaktu jamSelesai; // Jam kuliah selesai (integer jam & menit)
  final int sks;             // Jumlah SKS
  final String jenis;        // Contoh: "Teori", "1 Teori, 1 Praktek", dll.

  const Jadwal({
    required this.id,
    required this.hari,
    required this.mataKuliah,
    required this.dosen,
    required this.gedung,
    required this.ruangan,
    required this.jamMulai,
    required this.jamSelesai,
    required this.sks,
    required this.jenis,
  });

  // copyWith memungkinkan kita membuat salinan objek dengan beberapa field diubah
  // Berguna untuk fitur Edit Jadwal nanti
  Jadwal copyWith({
    String? id,
    Hari? hari,
    String? mataKuliah,
    String? dosen,
    String? gedung,
    String? ruangan,
    JamWaktu? jamMulai,
    JamWaktu? jamSelesai,
    int? sks,
    String? jenis,
  }) {
    return Jadwal(
      id: id ?? this.id,
      hari: hari ?? this.hari,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      dosen: dosen ?? this.dosen,
      gedung: gedung ?? this.gedung,
      ruangan: ruangan ?? this.ruangan,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      sks: sks ?? this.sks,
      jenis: jenis ?? this.jenis,
    );
  }

  // Serialisasi ke Map untuk disimpan ke storage lokal
  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'hari': hari.index, // menyimpan sebagai angka (0=senin, 1=selasa, dst.)
      'mataKuliah': mataKuliah,
      'dosen': dosen,
      'gedung': gedung,
      'ruangan': ruangan,
      'jamMulai': jamMulai.keMap(),
      'jamSelesai': jamSelesai.keMap(),
      'sks': sks,
      'jenis': jenis,
    };
  }

  // Deserialisasi dari Map (membaca dari storage lokal)
  factory Jadwal.dariMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'] as String,
      hari: Hari.values[map['hari'] as int],
      mataKuliah: map['mataKuliah'] as String,
      dosen: map['dosen'] as String,
      gedung: map['gedung'] as String,
      ruangan: map['ruangan'] as String,
      jamMulai: JamWaktu.dariMap(Map<String, dynamic>.from(map['jamMulai'])),
      jamSelesai: JamWaktu.dariMap(Map<String, dynamic>.from(map['jamSelesai'])),
      sks: map['sks'] as int,
      jenis: map['jenis'] as String,
    );
  }

  // Tampilan teks jam kuliah: "07.00 — 09.30"
  String get tampilJam => '${jamMulai.teks} — ${jamSelesai.teks}';

  // Tampilan lokasi: "Gedung B.Inggris Lt.3 • Teori 2"
  String get tampilLokasi => '$gedung • $ruangan';

  // Tampilan SKS dan jenis: "3 SKS • Teori"
  String get tampilSks => '$sks SKS • $jenis';

  @override
  String toString() {
    return 'Jadwal($mataKuliah, ${hari.nama}, ${jamMulai.teks}-${jamSelesai.teks})';
  }
}

// ============================================================
// Enum StatusJadwal
// Menentukan status sebuah jadwal berdasarkan waktu sekarang
// ============================================================
enum StatusJadwal {
  belumMulai,       // Kelas belum dimulai
  sedangBerlangsung, // Kelas sedang berlangsung sekarang
  selesai,          // Kelas sudah selesai
}
