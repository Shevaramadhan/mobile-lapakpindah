import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense_limit.dart';
import 'package:lapakpindah/modules/pengeluaran/models/session_info.dart';

/// Error dari proses data pengeluaran (pesan siap ditampilkan ke pengguna).
class PengeluaranException implements Exception {
  final String message;
  const PengeluaranException(this.message);

  @override
  String toString() => message;
}

/// Data layer pengeluaran (lapisan Data pada MVVM Modul 2).
///
/// Menyimpan data di memori dengan seed data sesuai desain Figma (Frame 1):
/// - Sesi aktif di "CFD Jam Gadang" (06.10 - 10.30)
/// - Batas pengeluaran Rp 200.000
/// - 5 catatan pengeluaran awal (total Rp 160.000, 80% terpakai)
///
/// Menggunakan simulasi Future.delayed agar transisi state loading terlihat.
class PengeluaranRepository {
  // ── Sesi aktif saat ini (null jika tidak ada sesi berjalan) ──
  SessionInfo? _activeSession = SessionInfo(
    id: 'session-cfd-01',
    locationName: 'CFD Jam Gadang',
    openTime: DateTime(2026, 10, 13, 6, 10),
    plannedCloseTime: DateTime(2026, 10, 13, 10, 30),
  );

  // ── Batas pengeluaran per sesi ──
  final Map<String, ExpenseLimit> _limits = {
    'session-cfd-01': const ExpenseLimit(
      sessionId: 'session-cfd-01',
      limitAmount: 200000,
    ),
  };

  // ── Daftar pengeluaran (dimulai dengan 5 item seperti di Figma) ──
  final List<Expense> _expenses = [
    Expense(
      id: 'exp-01',
      sessionId: 'session-cfd-01',
      description: 'Gas LPG',
      amount: 40000,
      category: ExpenseCategory.operasional,
      recordedAt: DateTime(2026, 10, 13, 9, 10),
    ),
    Expense(
      id: 'exp-02',
      sessionId: 'session-cfd-01',
      description: 'Plastik dan sedotan',
      amount: 25000,
      category: ExpenseCategory.kemasan,
      recordedAt: DateTime(2026, 10, 13, 8, 5),
    ),
    Expense(
      id: 'exp-03',
      sessionId: 'session-cfd-01',
      description: 'Belanja es batu',
      amount: 35000,
      category: ExpenseCategory.bahanBaku,
      recordedAt: DateTime(2026, 10, 13, 7, 25),
    ),
    Expense(
      id: 'exp-04',
      sessionId: 'session-cfd-01',
      description: 'Retribusi',
      amount: 10000,
      category: ExpenseCategory.sewaRetribusi,
      recordedAt: DateTime(2026, 10, 13, 6, 10),
      isFixedCost: true,
    ),
    Expense(
      id: 'exp-05',
      sessionId: 'session-cfd-01',
      description: 'Sewa tempat',
      amount: 50000,
      category: ExpenseCategory.sewaRetribusi,
      recordedAt: DateTime(2026, 10, 13, 6, 10),
      isFixedCost: true,
    ),
    // Sesi kemarin di Pasar Atas (FR-10: Riwayat)
    Expense(
      id: 'exp-h01',
      sessionId: 'session-pasar-02',
      description: 'Retribusi kebersihan',
      amount: 5000,
      category: ExpenseCategory.sewaRetribusi,
      recordedAt: DateTime(2026, 10, 12, 7, 0),
      isFixedCost: true,
    ),
    Expense(
      id: 'exp-h02',
      sessionId: 'session-pasar-02',
      description: 'Bahan baku jeruk 5kg',
      amount: 75000,
      category: ExpenseCategory.bahanBaku,
      recordedAt: DateTime(2026, 10, 12, 7, 30),
    ),
    // Sesi 2 hari lalu di GOR Agus Salim (FR-10: Riwayat)
    Expense(
      id: 'exp-h03',
      sessionId: 'session-gor-03',
      description: 'Sewa stan mingguan',
      amount: 100000,
      category: ExpenseCategory.sewaRetribusi,
      recordedAt: DateTime(2026, 10, 11, 6, 0),
      isFixedCost: true,
    ),
    Expense(
      id: 'exp-h04',
      sessionId: 'session-gor-03',
      description: 'Cup plastik 100 pcs',
      amount: 30000,
      category: ExpenseCategory.kemasan,
      recordedAt: DateTime(2026, 10, 11, 8, 15),
    ),
  ];

  // ── Daftar seluruh sesi untuk Riwayat (FR-10) ──
  final List<SessionInfo> _allSessions = [
    SessionInfo(
      id: 'session-cfd-01',
      locationName: 'CFD Jam Gadang',
      openTime: DateTime(2026, 10, 13, 6, 10),
      plannedCloseTime: DateTime(2026, 10, 13, 10, 30),
    ),
    SessionInfo(
      id: 'session-pasar-02',
      locationName: 'Pasar Atas Bukittinggi',
      openTime: DateTime(2026, 10, 12, 6, 30),
      plannedCloseTime: DateTime(2026, 10, 12, 12, 0),
    ),
    SessionInfo(
      id: 'session-gor-03',
      locationName: 'GOR Agus Salim',
      openTime: DateTime(2026, 10, 11, 5, 45),
      plannedCloseTime: DateTime(2026, 10, 11, 11, 0),
    ),
  ];

  // ── Read Sesi ──

  /// Mendapatkan sesi jualan aktif saat ini (bisa null jika belum ada sesi).
  Future<SessionInfo?> getActiveSession() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _activeSession;
  }

  /// Atur sesi aktif (untuk demo berganti antara ada sesi vs tanpa sesi).
  void setActiveSession(SessionInfo? session) {
    _activeSession = session;
  }

  // ── Read Batas Pengeluaran ──

  /// Mendapatkan batas pengeluaran untuk sesi tertentu.
  Future<ExpenseLimit?> getLimit(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _limits[sessionId];
  }

  // ── Read Pengeluaran ──

  /// Mengambil semua pengeluaran pada sesi tertentu, terurut terbaru di atas.
  Future<List<Expense>> fetchExpensesBySession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _expenses.where((e) => e.sessionId == sessionId).toList();
    // Urutkan dari yang terbaru (recordedAt desc)
    list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return List.unmodifiable(list);
  }

  // ── Create Pengeluaran (Core Workflow FR-06) ──

  /// Menambah pengeluaran baru. Melempar [PengeluaranException] jika gagal.
  Future<Expense> addExpense({
    required String sessionId,
    required String description,
    required double amount,
    ExpenseCategory category = ExpenseCategory.bahanBaku,
    String? receiptPhotoPath,
    bool isFixedCost = false,
  }) async {
    // Simulasi delay simpan agar animasi loading terlihat (Frame 8)
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      throw const PengeluaranException('Keterangan pengeluaran wajib diisi.');
    }
    if (amount <= 0) {
      throw const PengeluaranException('Jumlah biaya harus lebih dari Rp 0.');
    }

    final newExpense = Expense(
      id: 'exp-${DateTime.now().microsecondsSinceEpoch}',
      sessionId: sessionId,
      description: trimmed,
      amount: amount,
      category: category,
      receiptPhotoPath: receiptPhotoPath,
      recordedAt: DateTime.now(),
      isFixedCost: isFixedCost,
    );

    // Tambah ke daftar
    _expenses.add(newExpense);
    return newExpense;
  }

  // ── Read Riwayat (FR-10) ──

  /// Mengambil seluruh pengeluaran dari semua sesi, terurut terbaru di atas.
  /// Dipakai layar Riwayat untuk menampilkan catatan lintas sesi/lokasi.
  Future<List<Expense>> fetchAllExpenses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = [..._expenses];
    list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return List.unmodifiable(list);
  }

  /// Riwayat dikelompokkan per sesi (lokasi + tanggal), terbaru di atas.
  /// Setiap grup berisi daftar pengeluaran sesi tersebut.
  Future<List<ExpenseHistoryGroup>> fetchHistoryGroupedBySession() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final groups = <ExpenseHistoryGroup>[];

    // Urutkan sesi terbaru di atas
    final sessions = [..._allSessions]
      ..sort((a, b) => b.openTime.compareTo(a.openTime));

    for (final session in sessions) {
      final items = _expenses.where((e) => e.sessionId == session.id).toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      if (items.isEmpty) continue;
      final total = items.fold<double>(0, (sum, e) => sum + e.amount);
      groups.add(ExpenseHistoryGroup(
        session: session,
        expenses: List.unmodifiable(items),
        total: total,
      ));
    }
    return List.unmodifiable(groups);
  }

  // ── Update Batas (FR-08 / FR-09) ──

  /// Mengatur atau mengubah batas pengeluaran sebuah sesi.
  Future<ExpenseLimit> setLimit({
    required String sessionId,
    required double limitAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (limitAmount <= 0) {
      throw const PengeluaranException('Batas pengeluaran harus lebih dari Rp 0.');
    }
    final limit = ExpenseLimit(
      sessionId: sessionId,
      limitAmount: limitAmount,
    );
    _limits[sessionId] = limit;
    return limit;
  }
}

/// Satu kelompok riwayat: sesi + daftar pengeluaran + total (FR-10).
class ExpenseHistoryGroup {
  final SessionInfo session;
  final List<Expense> expenses;
  final double total;

  const ExpenseHistoryGroup({
    required this.session,
    required this.expenses,
    required this.total,
  });
}
