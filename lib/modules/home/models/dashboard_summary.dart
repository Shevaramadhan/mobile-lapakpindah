/// Ringkasan yang ditampilkan di dashboard (Beranda).
///
/// SEMENTARA: berisi data jadi untuk tampilan saja. Nanti nilainya
/// diisi dari modul masing-masing: lokasi & sesi (Modul 1),
/// pengeluaran (Modul 2), dan penjualan (Modul 3).
class DashboardSummary {
  // ── Info sesi jualan yang sedang berjalan ──

  /// true jika lapak sedang buka (ada sesi aktif).
  final bool isSessionActive;

  /// Nama lokasi tempat lapak dibuka, misal "CFD Jam Gadang".
  final String? locationName;

  /// Koordinat lokasi untuk pin di peta. null = belum ditandai.
  final double? latitude;
  final double? longitude;

  /// Jam lapak dibuka dan rencana jam tutup.
  final DateTime? openTime;
  final DateTime? plannedCloseTime;

  // ── Info keuangan sesi ──
  final double totalSales;
  final double totalExpense;

  const DashboardSummary({
    required this.isSessionActive,
    this.locationName,
    this.latitude,
    this.longitude,
    this.openTime,
    this.plannedCloseTime,
    this.totalSales = 0,
    this.totalExpense = 0,
  });

  /// Ringkasan saat lapak sedang tutup (tidak ada sesi aktif).
  static const closed = DashboardSummary(isSessionActive: false);

  // ── Perhitungan ──

  /// true jika koordinat lokasi tersedia (peta bisa ditampilkan).
  bool get hasCoordinate => latitude != null && longitude != null;

  /// Estimasi bersih = penjualan - pengeluaran. Bisa negatif.
  double get netProfit => totalSales - totalExpense;

  /// Sudah balik modal jika penjualan MELEWATI pengeluaran (FR-14).
  bool get isBreakEven => totalSales > totalExpense;
}
