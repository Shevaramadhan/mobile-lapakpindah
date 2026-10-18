// foundation.dart (bukan material.dart): ViewModel tidak bergantung widget UI.
import 'package:flutter/foundation.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense_limit.dart';
import 'package:lapakpindah/modules/pengeluaran/models/location_fixed_cost.dart';
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

  /// Kategori yang sedang difilter pada daftar (FR-07). null = semua.
  ExpenseCategory? _selectedCategory;

  /// Riwayat seluruh sesi (FR-10).
  List<ExpenseHistoryGroup> _historyGroups = [];
  ViewStatus _historyStatus = ViewStatus.loading;

  /// Daftar biaya tetap seluruh lokasi (FR-08).
  List<LocationFixedCost> _fixedCosts = [];
  ViewStatus _fixedCostsStatus = ViewStatus.loading;

  // ── Getter untuk UI ──
  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  SessionInfo? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSession != null;
  String? get activeSessionId => _activeSession?.id;
  List<Expense> get expenses => _expenses;
  ExpenseLimit? get limit => _limit;
  bool get hasLimit => _limit != null;

  /// Kategori terpilih untuk filter (null = semua).
  ExpenseCategory? get selectedCategory => _selectedCategory;

  /// Daftar pengeluaran sesi aktif setelah difilter kategori (FR-07).
  List<Expense> get filteredExpenses {
    if (_selectedCategory == null) return _expenses;
    return _expenses.where((e) => e.category == _selectedCategory).toList();
  }

  /// Riwayat seluruh sesi (FR-10).
  List<ExpenseHistoryGroup> get historyGroups => _historyGroups;
  ViewStatus get historyStatus => _historyStatus;

  /// Daftar biaya tetap lokasi (FR-08).
  List<LocationFixedCost> get fixedCosts => _fixedCosts;
  ViewStatus get fixedCostsStatus => _fixedCostsStatus;

  // ═══ [STATE] Kalkulasi total pengeluaran sesi ═══
  /// Total seluruh pengeluaran sesi aktif.
  double get totalExpense =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);

  // ═══ [STATE] Kalkulasi sisa batas ═══
  /// Sisa batas pengeluaran (tidak pernah negatif).
  double get remainingLimit {
    final limitAmount = _limit?.limitAmount;
    if (limitAmount == null) return 0;
    final sisa = limitAmount - totalExpense;
    return sisa < 0 ? 0 : sisa;
  }

  // ═══ [STATE] Kalkulasi persentase pemakaian batas (0-100) ═══
  /// Persentase pemakaian batas (0–100). 0 jika belum ada batas.
  double get usagePercent {
    final limitAmount = _limit?.limitAmount;
    if (limitAmount == null || limitAmount <= 0) return 0;
    final percent = (totalExpense / limitAmount) * 100;
    return percent > 100 ? 100 : percent;
  }

  // ═══ [STATE] Flag: apakah total sudah tembus batas? (FR-09) ═══
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

  /// Mengatur sesi aktif baru dan otomatis mengaplikasikan biaya tetap lokasi (FR-08).
  Future<void> setActiveSession(SessionInfo? session, {bool autoApplyFixedCosts = true}) async {
    await _repository.setActiveSession(session, autoApplyFixedCosts: autoApplyFixedCosts);
    await loadData();
  }

  // ── Setelah form berhasil menyimpan (Frame 10) ──

  // ═══ [RESULT] Item baru langsung diselipkan ke daftar tanpa reload ═══
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

  // ── Ubah batas (FR-08/FR-09) ──

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

  // ── Update & Delete pengeluaran (FR-06) ──

  /// Mengubah pengeluaran. Mengembalikan true jika berhasil.
  Future<bool> updateExpense({
    required String id,
    required String description,
    required double amount,
    ExpenseCategory? category,
    String? receiptPhotoPath,
  }) async {
    try {
      final updated = await _repository.updateExpense(
        id: id,
        description: description,
        amount: amount,
        category: category,
        receiptPhotoPath: receiptPhotoPath,
      );
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses = [..._expenses]..[index] = updated;
      }
      notifyListeners();
      return true;
    } on PengeluaranException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Menghapus pengeluaran. Mengembalikan true jika berhasil.
  Future<bool> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      _expenses = _expenses.where((e) => e.id != id).toList();
      notifyListeners();
      return true;
    } on PengeluaranException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Filter kategori (FR-07) ──

  /// Memilih kategori filter. null = tampilkan semua.
  void setCategoryFilter(ExpenseCategory? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  // ── Riwayat seluruh sesi (FR-10) ──

  /// Memuat riwayat pengeluaran seluruh sesi, dikelompokkan per sesi.
  Future<void> loadHistory() async {
    _historyStatus = ViewStatus.loading;
    notifyListeners();

    try {
      _historyGroups = await _repository.fetchHistoryGroupedBySession();
      _historyStatus = ViewStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _historyStatus = ViewStatus.error;
    }
    notifyListeners();
  }

  // ── Biaya Tetap Lokasi (FR-08) ──

  /// Memuat daftar biaya tetap seluruh lokasi.
  Future<void> loadFixedCosts() async {
    _fixedCostsStatus = ViewStatus.loading;
    notifyListeners();

    try {
      _fixedCosts = await _repository.fetchAllFixedCosts();
      _fixedCostsStatus = ViewStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _fixedCostsStatus = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Menambah biaya tetap baru untuk lokasi. Mengembalikan true jika berhasil.
  Future<bool> addFixedCost({
    required String locationId,
    required String locationName,
    required String description,
    required double amount,
  }) async {
    try {
      final newFc = await _repository.addLocationFixedCost(
        locationId: locationId,
        locationName: locationName,
        description: description,
        amount: amount,
      );
      _fixedCosts = [..._fixedCosts, newFc];
      notifyListeners();
      return true;
    } on PengeluaranException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Menghapus biaya tetap lokasi. Mengembalikan true jika berhasil.
  Future<bool> deleteFixedCost(String id) async {
    try {
      await _repository.deleteLocationFixedCost(id);
      _fixedCosts = _fixedCosts.where((fc) => fc.id != id).toList();
      notifyListeners();
      return true;
    } on PengeluaranException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}