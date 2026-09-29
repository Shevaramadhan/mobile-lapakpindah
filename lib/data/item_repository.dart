import '../models/item.dart';

/// Sumber data sementara (dummy).
/// Nanti bisa diganti dengan API/database SQLite LapakPindah.
class ItemRepository {
  // Data dummy produk-produk yang dijual di lapak UMKM keliling
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Ayam Geprek Sambal Bawang',
      subtitle: 'Menu Utama • Rp 15.000',
      description: 'Ayam goreng crispy yang digeprek dan disajikan dengan sambal bawang pedas khas lapak. Tersedia pilihan level kepedasan 1–5.',
    ),
    Item(
      id: '2',
      title: 'Es Teh Manis Jumbo',
      subtitle: 'Minuman • Rp 5.000',
      description: 'Teh manis segar dengan es batu yang melimpah. Ukuran jumbo 500 ml, cocok menemani menu utama di hari panas.',
    ),
    Item(
      id: '3',
      title: 'Nasi Putih',
      subtitle: 'Pelengkap • Rp 3.000',
      description: 'Nasi putih pulen porsi standar. Dapat ditambahkan sebagai pelengkap menu utama manapun.',
    ),
    Item(
      id: '4',
      title: 'Tahu Tempe Goreng',
      subtitle: 'Lauk Tambahan • Rp 2.000',
      description: 'Tahu dan tempe goreng renyah, digoreng dengan bumbu kuning khas. Dijual per potong.',
    ),
    Item(
      id: '5',
      title: 'Paket Hemat Keluarga',
      subtitle: 'Paket • Rp 45.000',
      description: 'Berisi 3 ayam geprek + 3 nasi putih + 3 es teh manis jumbo. Cocok untuk makan bersama keluarga.',
    ),
  ];

  /// Mengambil daftar item (produk).
  /// [simulateError]: true → sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    // Simulasi waktu tunggu seperti request ke server
    await Future.delayed(const Duration(seconds: 2));

    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }

    return _items;
  }
}
