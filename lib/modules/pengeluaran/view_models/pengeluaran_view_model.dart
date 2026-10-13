// foundation.dart (bukan material.dart): ViewModel tidak bergantung widget UI.
import 'package:flutter/foundation.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense_limit.dart';
import 'package:lapakpindah/modules/pengeluaran/models/session_info.dart';
import 'package:lapakpindah/modules/pengeluaran/repositories/pengeluaran_repository.dart';

/// ViewModel DAFTAR Pengeluaran (M3: MVVM, Modul 2).
///
/// Menyediakan state untuk Frame 1 / 10 / 11:
/// - sesi aktif (null → Frame 11 "Belum ada sesi berjalan")
/// - daftar pengeluaran sesi aktif
/// - total pengeluaran, batas, sisa batas, dan persentase terpakai
///
/// Setelah form berhasil menyimpan (Frame 10), layar memanggil
/// [applyNewExpense] supaya item baru langsung muncul di urutan teratas
/// tanpa memuat ulang seluruh data.
class PengeluaranViewModel extends ChangeNotifier {
  PengeluaranViewModel({PengeluaranRepository? repository})
      : _repository = repository ?? PengeluaranRepository();

  final PengeluaranRepository _repository;

  // ── State layar ──
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  SessionInfo? _activeSession;
  List<Expense> _expenses = [];
  ExpenseLimit? _limit;

  // ── Getter untuk UI ──
  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  SessionInfo? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSession != null;
  String? get activeSessionId => _activeSession?.id;
  List<Expense> get expenses => _expenses;
  ExpenseLimit? get limit => _limit;
  bool get hasLimit => _limit != null;

  /// Total seluruh pengeluaran sesi aktif.
  double get totalExpense =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);

  /// Sisa batas pengeluaran (tidak pernah negatif).
  double get remainingLimit {
    final limitAmount = _limit?.limitAmount;
    if (limitAmount == null) return 0;
    final sisa = limitAmount - totalExpense;
    return sisa < 0 ? 0 : sisa;
  }

  /// Persentase pemakaian batas (0–100). 0 jika belum ada batas.
  double get usagePercent {
    final limitAmount = _limit?.limitAmount;
    if (limitAmount == null || limitAmount <= 0) return 0;
    final percent = (totalExpense / limitAmount) * 100;
    return percent > 100 ? 100 : percent;
  }

  /// true jika total pengeluaran sudah mencapai/melewati batas (FR-10).
  bool get isLimitReached {
    final limitAmount = _limit?.limitAmount;
    if (limitAmount == null) return false;
    return totalExpense >= limitAmount;
  }

  // ── Memuat data layar (Frame 1 / 11) ──

  Future<void> loadData() async {
    _status = ViewStatus.loading;
    notifyListeners();

    try {
      _activeSession = await _repository.getActiveSession();

      if (_activeSession == null) {
        // Frame 11: tidak ada sesi berjalan
        _expenses = [];
        _limit = null;
      } else {
        final sessionId = _activeSession!.id;
        _expenses = await _repository.fetchExpensesBySession(sessionId);
        _limit = await _repository.getLimit(sessionId);
      }
      _status = ViewStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  // ── Setelah form berhasil menyimpan (Frame 10) ──

  /// Menambahkan pengeluaran baru ke state sehingga daftar & total langsung
  /// berubah tanpa memuat ulang dari repository (feedback instan).
  void applyNewExpense(Expense expense) {
    _expenses = [expense, ..._expenses];
    _status = ViewStatus.success;
    notifyListeners();
  }

  /// Memuat ulang daftar dari repository (dipakai saat mau menyegarkan).
  Future<void> refresh() async {
    await loadData();
  }

  // ── Ubah batas (FR-09) ──

  /// Menyimpan batas pengeluaran baru. Mengembalikan true jika berhasil.
  Future<bool> setLimit(double limitAmount) async {
    final sessionId = _activeSession?.id;
    if (sessionId == null) return false;

    try {
      _limit = await _repository.setLimit(
        sessionId: sessionId,
        limitAmount: limitAmount,
      );
      notifyListeners();
      return true;
    } on PengeluaranException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}