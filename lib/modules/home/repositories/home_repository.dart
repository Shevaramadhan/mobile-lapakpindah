import 'package:lapakpindah/modules/home/models/dashboard_summary.dart';

/// Data layer Beranda (M3: lapisan Data pada MVVM).
///
/// SEMENTARA: belum memakai database dan belum terhubung ke modul lain.
/// Mengembalikan data jadi agar tampilan Beranda bisa dibangun dulu.
/// Saat Modul 1–3 selesai, isi method ini diganti dengan data asli
/// (memanggil repository modul lain); ViewModel dan UI tidak perlu diubah.
class HomeRepository {
  // ── State dummy ──
  // `static` agar status tetap sama walaupun repository dibuat ulang.
  static bool _isSessionActive = true;

  // ── Read ──

  /// Mengambil ringkasan dashboard hari ini.
  /// [simulateError] = true sengaja melempar Exception untuk menguji error state.
  Future<DashboardSummary> fetchSummary({bool simulateError = false}) async {
    // Simulasi waktu proses agar loading state di UI bisa diuji.
    await Future.delayed(const Duration(milliseconds: 600));
    if (simulateError) {
      throw Exception('Gagal memuat ringkasan dashboard.');
    }

    // Lapak sedang tutup → tidak ada data sesi.
    if (!_isSessionActive) return DashboardSummary.closed;

    // Contoh: lapak sedang buka di CFD Jam Gadang, Bukittinggi (sesuai desain).
    final today = DateTime.now();
    return DashboardSummary(
      isSessionActive: true,
      locationName: 'CFD Jam Gadang',
      latitude: -0.3051,
      longitude: 100.3694,
      openTime: DateTime(today.year, today.month, today.day, 6, 10),
      plannedCloseTime: DateTime(today.year, today.month, today.day, 10, 30),
      totalSales: 560000,
      totalExpense: 160000,
    );
  }

  // ── Update ──

  /// Menutup sesi aktif (dummy). Fungsi asli tutup sesi milik Modul 1 (FR-03).
  Future<void> closeActiveSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _isSessionActive = false;
  }
}
