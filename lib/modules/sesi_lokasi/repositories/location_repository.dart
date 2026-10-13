import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';

/// Error dari proses data lokasi (pesan siap ditampilkan ke pengguna).
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// Data layer lokasi (M3: lapisan Data pada MVVM).
///
/// SEMENTARA: data disimpan di MEMORI (sebuah List), belum di database.
/// Daftar dimulai kosong dan akan kosong lagi setiap aplikasi dijalankan ulang.
/// Nanti cukup isi kelas ini yang diganti ke SQLite; ViewModel & UI tidak berubah.
class LocationRepository {
  // ── Penyimpanan di memori ──
  // Bukan `static`: list ikut hilang saat aplikasi ditutup.
  final List<Location> _locations = [];

  // ── Read ──

  /// Mengambil semua lokasi tersimpan.
  Future<List<Location>> fetchAll() async {
    // Simulasi waktu proses agar loading state di UI bisa terlihat.
    await Future.delayed(const Duration(milliseconds: 300));
    // Kirim salinan agar list asli tidak bisa diubah dari luar repository.
    return List.unmodifiable(_locations);
  }

  /// true jika nama sudah dipakai lokasi lain (huruf besar/kecil dianggap sama).
  bool isNameTaken(String name) {
    final key = _normalize(name);
    return _locations.any((location) => _normalize(location.name) == key);
  }

  // ── Create ──

  /// Menyimpan lokasi baru lalu mengembalikan data yang tersimpan.
  /// Melempar [LocationException] jika nama sudah dipakai.
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

  /// "  CFD  Jam Gadang " → "cfd jam gadang" (untuk membandingkan nama).
  static String _normalize(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
