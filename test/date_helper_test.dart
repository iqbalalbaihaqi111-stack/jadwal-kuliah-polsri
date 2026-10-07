import 'package:flutter_test/flutter_test.dart';
import 'package:jadwal_kuliah/models/jadwal.dart';
import 'package:jadwal_kuliah/utils/date_helper.dart';

void main() {
  Jadwal jadwal({required Hari hari, required int jam, required int menit}) {
    return Jadwal(
      id: 'uji',
      hari: hari,
      mataKuliah: 'Uji',
      dosen: '',
      gedung: '',
      ruangan: '',
      jamMulai: JamWaktu(jam: jam, menit: menit),
      jamSelesai: const JamWaktu(jam: 1, menit: 0),
      sks: 1,
      jenis: 'Teori',
    );
  }

  test('menghitung pengingat setengah jam sebelum kelas', () {
    final hasil = waktuNotifikasiJadwalBerikutnya(
      jadwal(hari: Hari.senin, jam: 7, menit: 0),
      DateTime(2026, 10, 4, 12),
      menitSebelum: 30,
    );

    expect(hasil, DateTime(2026, 10, 5, 6, 30));
  });

  test('menggeser pengingat ke hari sebelumnya untuk kelas dini hari', () {
    final hasil = waktuNotifikasiJadwalBerikutnya(
      jadwal(hari: Hari.senin, jam: 0, menit: 15),
      DateTime(2026, 10, 4, 20),
      menitSebelum: 30,
    );

    expect(hasil, DateTime(2026, 10, 4, 23, 45));
  });

  test('memilih minggu berikutnya jika waktu pengingat sudah lewat', () {
    final hasil = waktuNotifikasiJadwalBerikutnya(
      jadwal(hari: Hari.senin, jam: 7, menit: 0),
      DateTime(2026, 10, 5, 7),
      menitSebelum: 30,
    );

    expect(hasil, DateTime(2026, 10, 12, 6, 30));
  });
}
