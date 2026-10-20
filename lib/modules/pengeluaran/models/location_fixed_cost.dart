/// Biaya tetap lokasi (entitas `LocationFixedCost` di PRD v2).
///
/// Biaya tetap adalah pengeluaran berulang yang pasti muncul setiap berjualan
/// di lokasi tertentu (mis. sewa tempat, retribusi, parkir, izin).
/// Saat sesi dibuka di lokasi ini, sistem otomatis mencatat biaya tetap
/// ini sebagai pengeluaran sesi (FR-08).
class LocationFixedCost {
  final String id;
  final String locationId;
  final String locationName;
  final String description;
  final double amount;

  const LocationFixedCost({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.description,
    required this.amount,
  });

  /// Konversi dari Map (row SQLite) ke objek LocationFixedCost.
  factory LocationFixedCost.fromMap(Map<String, dynamic> map) {
    return LocationFixedCost(
      id: map['id'] as String,
      locationId: map['location_id'] as String,
      locationName: (map['location_name'] as String?) ?? '',
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }

  /// Konversi dari objek LocationFixedCost ke Map (untuk INSERT/UPDATE SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'location_name': locationName,
      'description': description,
      'amount': amount,
    };
  }
}
