import 'package:lapakpindah/modules/penjualan/models/product.dart';
import 'package:lapakpindah/modules/penjualan/repositories/sale_repository.dart';
class ProductRepository {
  static final List<Product> _products = [const Product(id: 1, name: 'Es Teh', sellingPrice: 5000), const Product(id: 2, name: 'Es Jeruk', sellingPrice: 7000)];
  static int _nextId = 3;
  List<Product> getAllProducts() => List.unmodifiable(_products);
  List<Product> getActiveProducts() => List.unmodifiable(_products.where((p) => p.isActive));
  Product? getProductById(int id) { for (final p in _products) { if (p.id == id) return p; } return null; }
  void _validate(String name, int price) { if (name.trim().isEmpty) throw ArgumentError('Nama produk wajib diisi.'); if (price <= 0) throw ArgumentError('Harga harus lebih dari Rp0.'); }
  Product addProduct({required String name, required int sellingPrice}) { _validate(name,sellingPrice); final p = Product(id: _nextId++, name: name.trim(), sellingPrice: sellingPrice); _products.add(p); return p; }
  Product updateProduct({required int id, required String name, required int sellingPrice}) { _validate(name,sellingPrice); final i = _products.indexWhere((p)=>p.id==id); if(i<0) throw StateError('Produk tidak ditemukan.'); return _products[i] = _products[i].copyWith(name:name.trim(),sellingPrice:sellingPrice); }
  Product setProductActive({required int id, required bool isActive}) { final i=_products.indexWhere((p)=>p.id==id); if(i<0) throw StateError('Produk tidak ditemukan.'); return _products[i]=_products[i].copyWith(isActive:isActive); }
  void deleteProduct({required int id}) { final i=_products.indexWhere((p)=>p.id==id); if(i<0) throw StateError('Produk tidak ditemukan.'); if(SaleRepository().hasSalesForProduct(id)) throw StateError('Produk memiliki riwayat penjualan. Nonaktifkan sebagai gantinya.'); _products.removeAt(i); }
}
