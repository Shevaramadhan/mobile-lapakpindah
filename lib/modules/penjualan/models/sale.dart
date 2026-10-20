class Sale {
  final int id, sessionId, productId, quantity, unitPrice;
  final DateTime recordedAt;

  const Sale({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.recordedAt,
  });

  int get total => quantity * unitPrice;

  Sale copyWith({int? quantity}) => Sale(
        id: id,
        sessionId: sessionId,
        productId: productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        recordedAt: recordedAt,
      );
}
