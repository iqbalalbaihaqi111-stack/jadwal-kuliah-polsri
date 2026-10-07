import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jadwal_kuliah/main.dart';
import 'package:jadwal_kuliah/services/schedule_service.dart';
import 'package:jadwal_kuliah/services/storage_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.inisialisasi();
    await ScheduleService.instance.inisialisasi();

    expect(ScheduleService.instance.semuaJadwal, hasLength(13));

    final seed = ScheduleService.instance.semuaJadwal;
    await ScheduleService.instance.simpanSemua(seed);
    final hasilBaca = await StorageService.instance.ambilJadwal();
    expect(hasilBaca.map((jadwal) => jadwal.id), seed.map((jadwal) => jadwal.id));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const JadwalKuliahApp());
    await tester.pumpAndSettle();

    // Verifikasi bahwa teks "Jadwal Kuliah" muncul
    expect(find.text('Jadwal Kuliah'), findsWidgets);
  });
}

