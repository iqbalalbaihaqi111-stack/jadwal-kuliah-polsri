import 'package:flutter/material.dart';

import '../models/jadwal.dart';
import '../services/schedule_service.dart';

class TambahJadwalScreen extends StatefulWidget {
  const TambahJadwalScreen({super.key, this.jadwal});

  final Jadwal? jadwal;

  @override
  State<TambahJadwalScreen> createState() => _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mataKuliahController;
  late final TextEditingController _dosenController;
  late final TextEditingController _gedungController;
  late final TextEditingController _ruanganController;
  late final TextEditingController _sksController;
  late final TextEditingController _jenisController;
  late Hari _hari;
  late TimeOfDay _jamMulai;
  late TimeOfDay _jamSelesai;
  bool _menyimpan = false;

  bool get _modeEdit => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    final jadwal = widget.jadwal;
    _mataKuliahController = TextEditingController(text: jadwal?.mataKuliah);
    _dosenController = TextEditingController(text: jadwal?.dosen);
    _gedungController = TextEditingController(text: jadwal?.gedung);
    _ruanganController = TextEditingController(text: jadwal?.ruangan);
    _sksController = TextEditingController(text: jadwal?.sks.toString());
    _jenisController = TextEditingController(text: jadwal?.jenis);
    _hari = jadwal?.hari ?? Hari.senin;
    _jamMulai = TimeOfDay(
      hour: jadwal?.jamMulai.jam ?? 7,
      minute: jadwal?.jamMulai.menit ?? 0,
    );
    _jamSelesai = TimeOfDay(
      hour: jadwal?.jamSelesai.jam ?? 8,
      minute: jadwal?.jamSelesai.menit ?? 0,
    );
  }

  @override
  void dispose() {
    _mataKuliahController.dispose();
    _dosenController.dispose();
    _gedungController.dispose();
    _ruanganController.dispose();
    _sksController.dispose();
    _jenisController.dispose();
    super.dispose();
  }

  Future<void> _pilihWaktu({required bool mulai}) async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: mulai ? _jamMulai : _jamSelesai,
    );
    if (hasil == null || !mounted) return;
    setState(() {
      if (mulai) {
        _jamMulai = hasil;
      } else {
        _jamSelesai = hasil;
      }
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate() || _menyimpan) return;
    final menitMulai = _jamMulai.hour * 60 + _jamMulai.minute;
    final menitSelesai = _jamSelesai.hour * 60 + _jamSelesai.minute;
    if (menitSelesai <= menitMulai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam selesai harus setelah jam mulai.')),
      );
      return;
    }

    setState(() => _menyimpan = true);
    final jadwal = Jadwal(
      id: widget.jadwal?.id ??
          'jadwal_${DateTime.now().microsecondsSinceEpoch}',
      hari: _hari,
      mataKuliah: _mataKuliahController.text.trim(),
      dosen: _dosenController.text.trim(),
      gedung: _gedungController.text.trim(),
      ruangan: _ruanganController.text.trim(),
      jamMulai: JamWaktu(jam: _jamMulai.hour, menit: _jamMulai.minute),
      jamSelesai: JamWaktu(jam: _jamSelesai.hour, menit: _jamSelesai.minute),
      sks: int.parse(_sksController.text),
      jenis: _jenisController.text.trim(),
    );

    try {
      if (_modeEdit) {
        await ScheduleService.instance.ubahJadwal(jadwal);
      } else {
        await ScheduleService.instance.tambahJadwal(jadwal);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _menyimpan = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan jadwal: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modeEdit ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _field(_mataKuliahController, 'Mata kuliah'),
            _field(_dosenController, 'Dosen'),
            DropdownButtonFormField<Hari>(
              value: _hari,
              decoration: const InputDecoration(labelText: 'Hari'),
              items: Hari.values
                  .map((hari) => DropdownMenuItem(
                        value: hari,
                        child: Text(hari.nama),
                      ))
                  .toList(),
              onChanged: (hari) {
                if (hari != null) setState(() => _hari = hari);
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _timeField(
                    label: 'Mulai',
                    time: _jamMulai,
                    onTap: () => _pilihWaktu(mulai: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeField(
                    label: 'Selesai',
                    time: _jamSelesai,
                    onTap: () => _pilihWaktu(mulai: false),
                  ),
                ),
              ],
            ),
            _field(_gedungController, 'Gedung'),
            _field(_ruanganController, 'Ruangan'),
            _field(
              _sksController,
              'SKS',
              keyboardType: TextInputType.number,
              validator: (value) {
                final sks = int.tryParse(value ?? '');
                if (sks == null || sks < 1 || sks > 20) {
                  return 'Masukkan SKS antara 1 sampai 20';
                }
                return null;
              },
            ),
            _field(_jenisController, 'Jenis kelas'),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _menyimpan ? null : _simpan,
                icon: _menyimpan
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_modeEdit ? 'Simpan perubahan' : 'Simpan jadwal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        validator: validator ??
            (value) => value == null || value.trim().isEmpty
                ? '$label wajib diisi'
                : null,
      ),
    );
  }

  Widget _timeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(time.format(context)),
      ),
    );
  }
}