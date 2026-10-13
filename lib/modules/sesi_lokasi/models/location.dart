/// Data satu lokasi jualan (entitas `Location` di PRD v2).
///
/// Koordinat [latitude] & [longitude] masih null karena fitur GPS (FR-02)
/// belum dibuat; nanti diisi lewat tombol "Ambil lokasi saat ini".
class Location {
  final String id;
  final String name;
  final String? note;
  final double? latitude;
  final double? longitude;

  const Location({
    required this.id,
    required this.name,
    this.note,
    this.latitude,
    this.longitude,
  });

  /// true jika koordinat lokasi sudah ditandai.
  bool get hasCoordinate => latitude != null && longitude != null;
}
