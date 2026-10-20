import 'package:lapakpindah/modules/penjualan/models/location_price.dart';

/// Penyimpanan harga khusus produk per lokasi (FR-13).
/// Sementara disimpan di memori, sama seperti repository lain di Modul 3.
class LocationPriceRepository {
  static final List<LocationPrice> _prices = [];
  static int _nextId = 1;

  /// Harga khusus produk di lokasi tersebut, atau null jika tidak ada.
  int? getPrice({required int productId, required int locationId}) {
    for (final p in _prices) {
      if (p.productId == productId && p.locationId == locationId) {
        return p.price;
      }
    }
    return null;
  }

  /// Menambah atau memperbarui harga khusus.
  LocationPrice setPrice({
    required int productId,
    required int locationId,
    required int price,
  }) {
    if (price <= 0) {
      throw ArgumentError('Harga khusus harus lebih dari Rp0.');
    }
    final index = _prices.indexWhere(
      (p) => p.productId == productId && p.locationId == locationId,
    );
    if (index >= 0) {
      return _prices[index] = _prices[index].copyWith(price: price);
    }
    final created = LocationPrice(
      id: _nextId++,
      productId: productId,
      locationId: locationId,
      price: price,
    );
    _prices.add(created);
    return created;
  }

  /// Menghapus harga khusus agar produk kembali memakai harga normal.
  void removePrice({required int productId, required int locationId}) {
    _prices.removeWhere(
      (p) => p.productId == productId && p.locationId == locationId,
    );
  }
}
