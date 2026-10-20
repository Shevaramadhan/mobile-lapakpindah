/// Koordinat [latitude] & [longitude] masih null karena fitur GPS (FR-02)
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
