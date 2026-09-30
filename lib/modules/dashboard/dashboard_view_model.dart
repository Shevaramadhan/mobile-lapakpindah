import 'package:flutter/material.dart';

// (1) Status tampilan sesuai Langkah 5
enum ViewStatus { loading, success, error }

/// ViewModel dashboard - MVVM pattern.
class DashboardViewModel extends ChangeNotifier {
  // Variabel state untuk Langkah 5
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  // Ubah ke true untuk menguji error state (Langkah 5)
  bool _simulateError = false; 

  double _todayNetIncome = 0;
  double _todayTotalRevenue = 0;
  double _todayTotalExpense = 0;
  double _percentageChange = 0;
  String? _currentLocation;

  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  double get todayNetIncome => _todayNetIncome;
  double get todayTotalRevenue => _todayTotalRevenue;
  double get todayTotalExpense => _todayTotalExpense;
  double get percentageChange => _percentageChange;
  String? get currentLocation => _currentLocation;

  /// Greeting berdasarkan jam saat ini.
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  /// Load ringkasan pendapatan hari ini (Simulasi Langkah 5).
  Future<void> loadTodaySummary() async {
    if (_status != ViewStatus.loading) {
      _status = ViewStatus.loading;
      notifyListeners();
    }

    try {
      // (2) Simulasi waktu tunggu server (Langkah 5)
      await Future.delayed(const Duration(seconds: 2));
      
      if (_simulateError) {
        // Reset simulateError agar kalau ditekan "Coba Lagi" bisa berhasil
        _simulateError = false;
        throw Exception('Gagal memuat data. Periksa koneksi internet.');
      }

      // Bypass database agar bisa berjalan di Chrome (Web)
      _todayTotalRevenue = 150000;
      _todayTotalExpense = 50000;
      _todayNetIncome = _todayTotalRevenue - _todayTotalExpense;

      if (_todayTotalRevenue > 0) {
        _percentageChange = ((_todayNetIncome / _todayTotalRevenue) * 100);
      } else {
        _percentageChange = 0;
      }

      _status = ViewStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = ViewStatus.error;
      notifyListeners();
    }
  }

  /// Toggle simulasi error (Untuk pengujian)
  void toggleSimulateError(bool value) {
    _simulateError = value;
    loadTodaySummary();
  }

  /// Set lokasi aktif.
  void setCurrentLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }
}
