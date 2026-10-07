# Jadwal Kuliah POLSRI

[![Flutter CI](https://github.com/iqbalalbaihaqi111-stack/jadwal-kuliah-polsri/actions/workflows/flutter.yml/badge.svg)](https://github.com/iqbalalbaihaqi111-stack/jadwal-kuliah-polsri/actions/workflows/flutter.yml)

Aplikasi Android berbasis Flutter untuk melihat jadwal kuliah, mengelola tugas,
dan menerima pengingat tepat waktu. Data disimpan secara lokal di perangkat,
tanpa akun atau server.

> **Proyek portofolio mahasiswa** — dibuat untuk membantu kegiatan kuliah
> Manajemen Informatika di POLSRI.

[Unduh APK Android](https://github.com/iqbalalbaihaqi111-stack/jadwal-kuliah-polsri/releases/latest/download/JADWAL_1IB.apk)

## Fitur

- Dashboard jadwal hari ini dengan status kelas yang sedang berlangsung dan
  kelas berikutnya.
- Lihat, tambah, ubah, dan hapus jadwal mata kuliah.
- Kelola tugas, deadline, tingkat urgensi, dan status selesai.
- Pengingat kelas mingguan 30 menit sebelum mulai dan/atau tepat saat kelas
  dimulai; masing-masing dapat diatur dari Pengaturan.
- Pengingat deadline tugas 24, 18, 12, dan 6 jam sebelumnya.
- Tema terang atau gelap mengikuti pengaturan sistem.
- Akses cepat ke LMS POLSRI.
- Penyimpanan lokal: jadwal menggunakan SharedPreferences/JSON dan tugas
  menggunakan Hive. Data setiap pemasangan aplikasi terpisah dan tidak
  tersinkronisasi antarperangkat.

## Teknologi

- Flutter dan Dart
- Material 3
- SharedPreferences dan Hive
- Flutter Local Notifications dan timezone
- `url_launcher`

## Menjalankan proyek

Persyaratan: Flutter SDK yang cocok dengan batas Dart di `pubspec.yaml`, serta
Android SDK untuk menjalankan atau membangun aplikasi Android.

```powershell
flutter pub get
flutter run
```

Jalankan tes dan analisis kode:

```powershell
flutter test
flutter analyze
```

## Membuat APK release

APK release untuk pengguna tersedia di [GitHub Releases](https://github.com/iqbalalbaihaqi111-stack/jadwal-kuliah-polsri/releases).

Untuk membangun pembaruan, clone/unduh source code ini, lalu gunakan keystore
release pribadi yang sama dengan yang dipakai untuk versi sebelumnya. Buat
`android/key.properties` lokal dengan format berikut:

```properties
storePassword=<sandi keystore>
keyPassword=<sandi kunci>
keyAlias=jadwal-kuliah
storeFile=app/upload-keystore.jks
```

Simpan keystore sebagai `android/app/upload-keystore.jks` dan jalankan:

```powershell
flutter pub get
flutter build apk --release
```

APK hasil build berada di `build/app/outputs/flutter-apk/app-release.apk`.
Naikkan nomor build di `pubspec.yaml` sebelum menerbitkan pembaruan.

**Penting:** Keystore dan kata sandinya tidak ada di repository. Jangan unggah,
commit, atau bagikan `android/key.properties` maupun file keystore. Buat
cadangan keystore dan sandinya di tempat aman; tanpa keduanya, APK pembaruan
tidak dapat ditandatangani dengan identitas aplikasi yang sama.

## Catatan privasi

Aplikasi tidak mengirim jadwal atau tugas ke internet. Seed jadwal di source
code adalah data awal proyek untuk konteks penggunaan POLSRI. Setelah aplikasi
dipasang, perubahan jadwal dan data tugas hanya tersimpan pada perangkat itu.
