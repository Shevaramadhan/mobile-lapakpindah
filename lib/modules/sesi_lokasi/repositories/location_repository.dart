import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';

/// Error dari proses data lokasi (pesan siap ditampilkan ke pengguna).
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// Data layer lokasi .
/// SEMENTARA: data disimpan di MEMORI (sebuah List), belum di database.

class LocationRepository {
  // ── Penyimpanan di memori ──

  final List<Location> _locations = [];

  // ── Read ──\
  Future<List<Location>> fetchAll() async {

    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_locations);
  }
  /// true jika nama sudah dipakai lokasi lain (huruf besar/kecil dianggap sama).
  bool isNameTaken(String name) {
    final key = _normalize(name);
    return _locations.any((location) => _normalize(location.name) == key);
  }

  // ── Create ──
  Future<Location> add({required String name, String? note}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Aturan data: nama lokasi harus unik (pengaman kedua setelah validasi form).
    if (isNameTaken(name)) {
      throw LocationException('Nama lokasi "${name.trim()}" sudah ada.');
    }

    final trimmedNote = note?.trim();
    final location = Location(
      // id unik sederhana dari waktu sekarang
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
    );
    _locations.add(location);
    return location;
  }

  /// " CFD Jam Gadang " → "cfd jam gadang" (untuk membandingkan nama:
  /// spasi di awal/akhir dibuang, huruf besar/kecil dianggap sama).
  static String _normalize(String name) => name.trim().toLowerCase();
}
