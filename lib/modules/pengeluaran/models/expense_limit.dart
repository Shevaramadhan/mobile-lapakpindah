/// Batas pengeluaran untuk satu sesi jualan (entitas `ExpenseLimit` di PRD v2).
///
/// Hanya menyimpan [sessionId] dan [limitAmount] (FR-09).
/// Tidak ada ID terpisah karena relasi one-to-one dengan SalesSession.
class ExpenseLimit {
  final String sessionId;
  final double limitAmount;

  const ExpenseLimit({
    required this.sessionId,
    required this.limitAmount,
  });

  /// Konversi dari Map (row SQLite) ke objek ExpenseLimit.
  factory ExpenseLimit.fromMap(Map<String, dynamic> map) {
    return ExpenseLimit(
      sessionId: map['session_id'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
    );
  }

  /// Konversi dari objek ExpenseLimit ke Map (untuk INSERT/UPDATE SQLite).
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'limit_amount': limitAmount,
    };
  }
}
