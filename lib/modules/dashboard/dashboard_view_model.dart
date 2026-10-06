import 'package:flutter/material.dart';
import 'package:lapakpindah/data/dashboard_repository.dart';
import 'package:lapakpindah/models/dashboard_summary.dart';
import 'package:lapakpindah/widgets/state_views.dart';

/// ViewModel dashboard / Beranda (M3: MVVM).
///
/// View (HomeScreen) → ViewModel (kelas ini) → Model/Data (DashboardRepository).
/// ViewModel menyimpan state tampilan dan memberi tahu View lewat
/// `notifyListeners()` setiap kali state berubah.
class DashboardViewModel extends ChangeNotifier {
  // ── Sumber data ──
  final _repository = DashboardRepository();

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
