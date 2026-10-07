import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/jadwal.dart';
import '../utils/constants.dart';

class StorageService {
	StorageService._();

	static final StorageService instance = StorageService._();
	static const String _jadwalKey = 'jadwal_kuliah_data_v1';
	static const String _pengingat30MenitKey = 'pengingat_30_menit';
	static const String _notifikasiMulaiKey = 'notifikasi_kuliah_mulai';
	static const String _jadwalNotifikasiIdsKey = 'jadwal_notifikasi_ids';

	SharedPreferences? _preferences;

	Future<void> inisialisasi() async {
		_preferences ??= await SharedPreferences.getInstance();
	}

	SharedPreferences get _prefs {
		final preferences = _preferences;
		if (preferences == null) {
			throw StateError('StorageService belum diinisialisasi.');
		}
		return preferences;
	}

	Future<List<Jadwal>> ambilJadwal() async {
		final jsonJadwal = _prefs.getString(_jadwalKey);
		if (jsonJadwal == null) {
			await simpanJadwal(jadwalSeedData);
			return List<Jadwal>.of(jadwalSeedData);
		}

		final decoded = jsonDecode(jsonJadwal);
		if (decoded is! List) {
			throw const FormatException('Data jadwal harus berupa daftar JSON.');
		}

		return decoded
				.map((item) => Jadwal.dariMap(Map<String, dynamic>.from(item as Map)))
				.toList();
	}

	Future<void> simpanJadwal(List<Jadwal> jadwal) async {
		final jsonJadwal = jsonEncode(jadwal.map((item) => item.keMap()).toList());
		await _prefs.setString(_jadwalKey, jsonJadwal);
	}

	bool ambilPengingat30Menit() => _prefs.getBool(_pengingat30MenitKey) ?? true;

	Future<void> simpanPengingat30Menit(bool aktif) async {
		await _prefs.setBool(_pengingat30MenitKey, aktif);
	}

	bool ambilNotifikasiKuliahMulai() => _prefs.getBool(_notifikasiMulaiKey) ?? true;

	Future<void> simpanNotifikasiKuliahMulai(bool aktif) async {
		await _prefs.setBool(_notifikasiMulaiKey, aktif);
	}

	List<String> ambilIdJadwalNotifikasi() =>
			_prefs.getStringList(_jadwalNotifikasiIdsKey) ?? const [];

	Future<void> simpanIdJadwalNotifikasi(List<String> ids) async {
		await _prefs.setStringList(_jadwalNotifikasiIdsKey, ids);
	}
}
