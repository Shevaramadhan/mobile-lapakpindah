import '../models/item.dart';

/// Sumber data dummy untuk latihan 2.
/// Nanti dapat diganti dengan API/database tanpa mengubah UI.
class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Lapak Minuman Segar',
      subtitle: 'Es Teh & Minuman Kekinian',
      description:
          'Lapak minuman yang beroperasi di area kampus dan menyediakan berbagai minuman segar untuk pelanggan.',
    ),
    Item(
      id: '2',
      title: 'Lapak Makanan Ringan',
      subtitle: 'Camilan & Snack',
      description:
          'Lapak makanan ringan dengan pilihan camilan yang cocok untuk pelanggan saat beraktivitas.',
    ),
    Item(
      id: '3',
      title: 'Lapak Sarapan Pagi',
      subtitle: 'Nasi & Menu Pagi',
      description:
          'Lapak yang menyediakan menu sarapan sederhana dan praktis untuk pelanggan di pagi hari.',
    ),
  ];

  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));

    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }

    return _items;
  }
}
