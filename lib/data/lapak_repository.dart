import '../models/lapak.dart';

/// Sumber data sementara (dummy) untuk daftar lokasi jualan LapakPindah.
class LapakRepository {
  static const List<Lapak> _items = [
    Lapak(
      id: '1',
      title: 'Pasar Kaget Minggu - GOR',
      subtitle: 'Minggu, 20 September 2026',
      description: 'Jam Operasional: 06:00 - 11:00. Target omzet: Rp 500.000.',
    ),
    Lapak(
      id: '2',
      title: 'Bazar Kampus Unand',
      subtitle: 'Senin, 21 September 2026',
      description: 'Jam Operasional: 08:00 - 16:00. Bawa stok ekstra untuk menu minuman.',
    ),
    Lapak(
      id: '3',
      title: 'CFD Khatib Sulaiman',
      subtitle: 'Minggu, 27 September 2026',
      description: 'Jam Operasional: 06:00 - 10:00. Lokasi dekat pintu masuk utama.',
    ),
  ];

  /// Mengambil daftar item.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Lapak>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data lokasi. Periksa koneksi internet.');
    }
    return _items;
  }
}