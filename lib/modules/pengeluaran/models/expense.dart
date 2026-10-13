/// Data satu catatan pengeluaran (entitas `Expense` di PRD v2).
///
/// Setiap pengeluaran terikat pada [sessionId] (satu sesi jualan di lokasi).
/// [receiptPhotoPath] kosong jika pengeluaran tanpa foto nota (FR-07 opsional).
class Expense {
  final String id;
  final String sessionId;
  final String description;
  final double amount;
  final String? receiptPhotoPath;
  final DateTime recordedAt;

  /// true jika pengeluaran ini berasal dari biaya tetap lokasi (FR-08).
  final bool isFixedCost;

  const Expense({
    required this.id,
    required this.sessionId,
    required this.description,
    required this.amount,
    this.receiptPhotoPath,
    required this.recordedAt,
    this.isFixedCost = false,
  });

  /// true jika pengeluaran memiliki foto nota.
  bool get hasReceipt => receiptPhotoPath != null && receiptPhotoPath!.isNotEmpty;

  /// Konversi dari Map (row SQLite) ke objek Expense.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      receiptPhotoPath: map['receipt_photo_path'] as String?,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      isFixedCost: (map['is_fixed_cost'] as int) == 1,
    );
  }

  /// Konversi dari objek Expense ke Map (untuk INSERT/UPDATE SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'description': description,
      'amount': amount,
      'receipt_photo_path': receiptPhotoPath,
      'recorded_at': recordedAt.toIso8601String(),
      'is_fixed_cost': isFixedCost ? 1 : 0,
    };
  }
}
