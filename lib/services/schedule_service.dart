import 'package:flutter/foundation.dart';

import '../models/jadwal.dart';
import 'storage_service.dart';

class ScheduleService {
	ScheduleService._();

	static final ScheduleService instance = ScheduleService._();

	final StorageService _storage = StorageService.instance;
	List<Jadwal> _jadwal = [];
	bool _sudahDiinisialisasi = false;
	final ValueNotifier<List<Jadwal>> perubahan = ValueNotifier(const []);

	bool get sudahDiinisialisasi => _sudahDiinisialisasi;
	List<Jadwal> get semuaJadwal => List.unmodifiable(_jadwal);

	Future<void> inisialisasi() async {
		if (_sudahDiinisialisasi) return;
		_jadwal = _urutkan(await _storage.ambilJadwal());
		_sudahDiinisialisasi = true;
		perubahan.value = List.unmodifiable(_jadwal);
	}

	Future<void> tambahJadwal(Jadwal jadwal) async {
		if (_jadwal.any((item) => item.id == jadwal.id)) {
			throw ArgumentError('ID jadwal sudah digunakan: ${jadwal.id}');
		}
		await simpanSemua([..._jadwal, jadwal]);
	}

	Future<void> ubahJadwal(Jadwal jadwal) async {
		final index = _jadwal.indexWhere((item) => item.id == jadwal.id);
		if (index == -1) throw ArgumentError('Jadwal tidak ditemukan.');
		final jadwalBaru = List<Jadwal>.of(_jadwal)..[index] = jadwal;
		await simpanSemua(jadwalBaru);
	}

	Future<void> hapusJadwal(String id) async {
		await simpanSemua(_jadwal.where((item) => item.id != id).toList());
	}

	Future<void> simpanSemua(List<Jadwal> jadwal) async {
		final jadwalUrut = _urutkan(jadwal);
		await _storage.simpanJadwal(jadwalUrut);
		_jadwal = jadwalUrut;
		perubahan.value = List.unmodifiable(_jadwal);
	}

	List<Jadwal> _urutkan(List<Jadwal> jadwal) {
		final hasil = List<Jadwal>.of(jadwal);
		hasil.sort((a, b) {
			final bandingHari = a.hari.urutan.compareTo(b.hari.urutan);
			if (bandingHari != 0) return bandingHari;
			final menitA = a.jamMulai.jam * 60 + a.jamMulai.menit;
			final menitB = b.jamMulai.jam * 60 + b.jamMulai.menit;
			return menitA.compareTo(menitB);
		});
		return hasil;
	}
}
