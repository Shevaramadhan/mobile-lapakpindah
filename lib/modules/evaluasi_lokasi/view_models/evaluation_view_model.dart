import 'package:flutter/foundation.dart';

import '../../../core/utils/view_status.dart';
import '../../sesi_lokasi/models/location.dart';
import '../../sesi_lokasi/repositories/location_repository.dart';
import '../models/profit_series.dart';
import '../models/profit_target.dart';
import '../repositories/evaluation_repository.dart';
import '../repositories/profit_target_repository.dart';

/// State halaman Evaluasi: lokasi, sesi, grafik, target, dan status memuat.
class EvaluationViewModel extends ChangeNotifier {
  EvaluationViewModel({
    required this.locationsRepository,
    required this.repository,
    required this.targetsRepository,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;
  final LocationRepository locationsRepository;
  final EvaluationRepository repository;
  final ProfitTargetRepository targetsRepository;
  final DateTime Function() _now;
  ViewStatus status = ViewStatus.loading;
  String errorMessage = '';
  List<Location> locations = [];
  List<ProfitTarget> targets = [];
  List<SessionProfit> _sessions = [];
  String? selectedLocationId;
  EvaluationPeriod period = EvaluationPeriod.week;
  TrendGrouping get grouping => period == EvaluationPeriod.week
      ? TrendGrouping.daily
      : TrendGrouping.weekly;
  bool deleting = false;
  int _request = 0;
  bool _disposed = false;

  /// Ambil ulang data setelah form target ditutup atau layar aktif kembali.
  Future<void> load() async {
    final request = ++_request;
    status = ViewStatus.loading;
    notifyListeners();
    try {
      final newLocations = await locationsRepository.fetchAll();
      final newSessions = await repository.fetchSessions();
      final newTargets = await targetsRepository.fetchAll();
      if (_disposed || request != _request) return;
      locations = newLocations;
      _sessions = newSessions;
      targets = newTargets;
      if (!locations.any((l) => l.id == selectedLocationId)) {
        selectedLocationId = locations.firstOrNull?.id;
      }
      status = ViewStatus.success;
    } catch (_) {
      if (_disposed || request != _request) return;
      errorMessage = 'Data evaluasi gagal dimuat. Coba lagi.';
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  List<SessionProfit> sessionsFor(String locationId) {
    // Filter week/month/all hanya memilih sesi untuk analisis; target tetap per sesi.
    final today = _now();
    final start = switch (period) {
      EvaluationPeriod.week => DateTime(today.year, today.month, today.day - 6),
      EvaluationPeriod.month => DateTime(today.year, today.month, 1),
      EvaluationPeriod.all => DateTime(1970),
    };
    final end = DateTime(today.year, today.month, today.day + 1);
    return _sessions
        .where(
          (s) =>
              s.locationId == locationId &&
              !s.date.isBefore(start) &&
              s.date.isBefore(end),
        )
        .toList();
  }

  /// Rata-rata laba per sesi untuk lokasi dalam periode tampilan terpilih.
  double? averageFor(String locationId) {
    final sessions = sessionsFor(locationId);
    // null berarti belum ada sesi, sehingga UI tidak menganggapnya laba nol.
    if (sessions.isEmpty) return null;
    return sessions.fold<int>(0, (sum, s) => sum + s.profit) / sessions.length;
  }

  List<ProfitPoint> get points => groupProfits(
    selectedLocationId == null ? [] : sessionsFor(selectedLocationId!),
    grouping,
  );

  /// Target aktif untuk lokasi yang sedang ditampilkan.
  ProfitTarget? targetFor(String id) =>
      targets.where((t) => t.locationId == id).firstOrNull;

  /// Event pilihan lokasi: ranking, grafik, dan kartu target ikut berubah.
  void selectLocation(String? id) {
    selectedLocationId = id;
    notifyListeners();
  }

  /// Event filter periode; grafik mingguan mengikuti periode selain 7 hari.
  void selectPeriod(EvaluationPeriod value) {
    period = value;
    notifyListeners();
  }

  /// Hapus target, bukan lokasi atau riwayat laba.
  Future<bool> deleteTarget(ProfitTarget target) async {
    if (deleting) return false;
    deleting = true;
    notifyListeners();
    try {
      await targetsRepository.delete(target.id);
      if (_disposed) return false;
      targets = targets.where((t) => t.id != target.id).toList();
      return true;
    } catch (_) {
      return false;
    } finally {
      deleting = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
