/// Model data utama aplikasi LapakPindah.
/// Merepresentasikan produk yang dijual oleh UMKM keliling.
class Item {
  final String id;
  final String title; // Nama produk
  final String subtitle; // Kategori / keterangan singkat
  final String description; // Deskripsi lengkap produk

  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
