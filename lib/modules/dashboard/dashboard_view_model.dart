import 'package:flutter/material.dart';
import 'package:lapakpindah/core/database/db_helper.dart';

/// ViewModel dashboard — MVVM pattern.
class DashboardViewModel extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper.instance;

  double _todayNetIncome = 0;
  double _todayTotalRevenue = 0;
  double _todayTotalExpense = 0;
  double _percentageChange = 0;
  String? _currentLocation;

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

  /// Load ringkasan pendapatan hari ini dari SQLite.
  Future<void> loadTodaySummary() async {
    try {
      _todayTotalRevenue = await _dbHelper.getTodayRevenue();
      _todayTotalExpense = await _dbHelper.getTodayExpense();
      _todayNetIncome = _todayTotalRevenue - _todayTotalExpense;

      // Hitung persentase (placeholder logic, nanti bisa dibandingkan dgn kemarin)
      if (_todayTotalRevenue > 0) {
        _percentageChange = ((_todayNetIncome / _todayTotalRevenue) * 100);
      } else {
        _percentageChange = 0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard summary: $e');
    }
  }

  /// Set lokasi aktif.
  void setCurrentLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }
}
