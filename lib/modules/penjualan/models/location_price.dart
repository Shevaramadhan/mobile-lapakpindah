/// Harga khusus sebuah produk di lokasi tertentu (FR-13).
/// Jika tidak ada data untuk lokasi tersebut, produk memakai harga normal.
class LocationPrice {
  final int id;
  final int productId;
  final int locationId;
  final int price;

  const LocationPrice({
    required this.id,
    required this.productId,
    required this.locationId,
    required this.price,
  });

  LocationPrice copyWith({int? price}) => LocationPrice(
        id: id,
        productId: productId,
        locationId: locationId,
        price: price ?? this.price,
      );

  factory LocationPrice.fromMap(Map<String, Object?> map) => LocationPrice(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        locationId: map['location_id'] as int,
        price: map['price'] as int,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'product_id': productId,
        'location_id': locationId,
        'price': price,
      };
}
