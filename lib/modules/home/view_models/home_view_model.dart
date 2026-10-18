// foundation.dart (bukan material.dart): ViewModel hanya butuh ChangeNotifier,
// tidak bergantung pada widget UI.
import 'package:flutter/foundation.dart';
import 'package:lapakpindah/core/utils/view_status.dart'; // murni Dart, bukan file UI
import 'package:lapakpindah/modules/home/models/dashboard_summary.dart';
import 'package:lapakpindah/modules/home/repositories/home_repository.dart';

/// ViewModel Beranda (M3: MVVM).
///
/// View (HomeScreen) → ViewModel (kelas ini) → Model/Data (HomeRepository).
/// ViewModel menyimpan state tampilan dan memberi tahu View lewat
/// `notifyListeners()` setiap kali state berubah.
class HomeViewModel extends ChangeNotifier {
  // ── Sumber data ──
  final _repository = HomeRepository();

  // ── State ──
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  DashboardSummary _summary = DashboardSummary.closed;

  // ── Getter untuk UI (UI hanya membaca, tidak mengubah langsung) ──
  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  DashboardSummary get summary => _summary;

  // ── Memuat data dashboard ──

  /// Memuat ringkasan dashboard. [simulateError] untuk menguji error state.
  Future<void> loadDashboard({bool simulateError = false}) async {
    // 1. Masuk loading state
    _status = ViewStatus.loading;
    notifyListeners();

    try {
      // 2. Ambil ringkasan dari repository
      _summary = await _repository.fetchSummary(simulateError: simulateError);
      _status = ViewStatus.success;
    } catch (e) {
      // 3. Gagal: simpan pesan error untuk ditampilkan ErrorView
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  // ── Tutup lapak ──

  /// Menutup sesi aktif lalu memuat ulang dashboard
  /// (tampilan berubah menjadi "Lapak sedang tutup").
  Future<void> closeSession() async {
    await _repository.closeActiveSession();
    await loadDashboard();
  }
}
