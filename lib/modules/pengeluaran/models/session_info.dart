/// Informasi minimal sesi jualan aktif untuk ditampilkan di Modul 2.
///
/// Data lengkap sesi ada di Modul 1 (SalesSession), tapi Modul 2
/// hanya butuh [id], [locationName], [openTime], dan [plannedCloseTime]
/// untuk tampil di kartu sesi aktif (Frame 1 Figma).
class SessionInfo {
  final String id;
  final String locationName;
  final DateTime openTime;
  final DateTime plannedCloseTime;

  const SessionInfo({
    required this.id,
    required this.locationName,
    required this.openTime,
    required this.plannedCloseTime,
  });

  /// Konversi dari Map (hasil JOIN SQLite antara sales_sessions & locations).
  factory SessionInfo.fromMap(Map<String, dynamic> map) {
    return SessionInfo(
      id: map['id'] as String,
      locationName: map['location_name'] as String,
      openTime: DateTime.parse(map['open_time'] as String),
      plannedCloseTime: DateTime.parse(map['planned_close_time'] as String),
    );
  }
}
