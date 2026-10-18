import 'package:lapakpindah/modules/penjualan/models/sale.dart';

class SaleRepository {
  static const int demoSessionId = 1;
  static const int demoLocationId = 1;
  static const String demoLocationName = 'CFD Jam Gadang';

  /// Total pengeluaran sesi demo (Rp).
  /// SEMENTARA: diganti total pengeluaran asli dari Modul 2 setelah terhubung.
  static const int demoSessionExpense = 50000;

  static final List<Sale> _sales = [];
  static int _nextId = 1;

  List<Sale> getSalesBySession(int sessionId) =>
      List.unmodifiable(_sales.where((s) => s.sessionId == sessionId));

  bool hasSalesForProduct(int productId) =>
      _sales.any((s) => s.productId == productId);

  int getTotalBySession(int sessionId) =>
      _sales.where((s) => s.sessionId == sessionId).fold(0, (sum, s) => sum + s.total);

  Sale addSale({
    required int sessionId,
    required int productId,
    required int quantity,
    required int unitPrice,
  }) {
    if (sessionId <= 0 || productId <= 0 || quantity <= 0 || unitPrice < 0) {
      throw ArgumentError('Data transaksi tidak valid.');
    }
    final sale = Sale(
      id: _nextId++,
      sessionId: sessionId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      recordedAt: DateTime.now(),
    );
    _sales.add(sale);
    return sale;
  }

  /// Mengubah jumlah terjual; harga satuan tetap seperti saat dicatat.
  Sale updateQuantity({required int id, required int quantity}) {
    if (quantity <= 0) {
      throw ArgumentError('Jumlah terjual harus lebih dari 0.');
    }
    final index = _sales.indexWhere((s) => s.id == id);
    if (index < 0) throw StateError('Catatan penjualan tidak ditemukan.');
    return _sales[index] = _sales[index].copyWith(quantity: quantity);
  }

  void deleteSale({required int id}) {
    final index = _sales.indexWhere((s) => s.id == id);
    if (index < 0) throw StateError('Catatan penjualan tidak ditemukan.');
    _sales.removeAt(index);
  }
}
