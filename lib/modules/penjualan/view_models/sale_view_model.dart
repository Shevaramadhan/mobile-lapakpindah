import 'package:flutter/foundation.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/modules/penjualan/models/product.dart';
import 'package:lapakpindah/modules/penjualan/models/sale.dart';
import 'package:lapakpindah/modules/penjualan/repositories/location_price_repository.dart';
import 'package:lapakpindah/modules/penjualan/repositories/product_repository.dart';
import 'package:lapakpindah/modules/penjualan/repositories/sale_repository.dart';

/// Mengelola produk, harga khusus lokasi, input/validasi/penyimpanan
/// penjualan, riwayat, dan ringkasan balik modal sesi.
class SaleViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;
  final SaleRepository _saleRepository;
  final LocationPriceRepository _priceRepository;

  SaleViewModel({
    ProductRepository? productRepository,
    SaleRepository? saleRepository,
    LocationPriceRepository? priceRepository,
  })  : _productRepository = productRepository ?? ProductRepository(),
        _saleRepository = saleRepository ?? SaleRepository(),
        _priceRepository = priceRepository ?? LocationPriceRepository() {
    loadHistory();
  }

  static const int demoSessionId = SaleRepository.demoSessionId;
  static const int demoLocationId = SaleRepository.demoLocationId;
  static const String demoLocationName = SaleRepository.demoLocationName;

  // SIMULASI PRACTICAL CHALLENGE
  // Ubah kedua nilai menjadi false setelah pengujian.
  static const bool demoLoading = true;
  static const bool demoSaveError = false;

  Product? _selectedProduct;
  String _quantityInput = '';
  String? _errorMessage;
  String? _successMessage;
  Sale? _lastSavedSale;
  List<Sale> _sales = [];
  ViewStatus _historyStatus = ViewStatus.success;

  // Status loading khusus proses penyimpanan.
  bool _isSaving = false;

  // ── Produk (FR-11) ──
  List<Product> get products => _productRepository.getActiveProducts();
  List<Product> get allProducts => _productRepository.getAllProducts();

  String getProductName(int id) =>
      _productRepository.getProductById(id)?.name ?? 'Produk #$id';

  String _messageOf(Object e) {
    if (e is ArgumentError) return e.message.toString();
    if (e is StateError) return e.message;
    return e.toString();
  }

  /// [specialPrice] opsional: harga khusus di lokasi sesi saat ini (FR-13).
  bool addProduct({
    required String name,
    required int sellingPrice,
    int? specialPrice,
  }) {
    try {
      if (specialPrice != null && specialPrice <= 0) {
        throw ArgumentError('Harga khusus harus lebih dari Rp0.');
      }
      final product = _productRepository.addProduct(
        name: name,
        sellingPrice: sellingPrice,
      );
      if (specialPrice != null) {
        _priceRepository.setPrice(
          productId: product.id,
          locationId: demoLocationId,
          price: specialPrice,
        );
      }
      _errorMessage = null;
      _successMessage = 'Produk berhasil ditambahkan.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _messageOf(e);
      notifyListeners();
      return false;
    }
  }

  /// [specialPrice] null berarti harga khusus lokasi dihapus.
  bool updateProduct({
    required int id,
    required String name,
    required int sellingPrice,
    int? specialPrice,
  }) {
    try {
      if (specialPrice != null && specialPrice <= 0) {
        throw ArgumentError('Harga khusus harus lebih dari Rp0.');
      }
      _productRepository.updateProduct(
        id: id,
        name: name,
        sellingPrice: sellingPrice,
      );
      if (specialPrice == null) {
        _priceRepository.removePrice(productId: id, locationId: demoLocationId);
      } else {
        _priceRepository.setPrice(
          productId: id,
          locationId: demoLocationId,
          price: specialPrice,
        );
      }
      _selectedProduct = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _messageOf(e);
      notifyListeners();
      return false;
    }
  }

  bool setProductActive({required int id, required bool isActive}) {
    try {
      _productRepository.setProductActive(id: id, isActive: isActive);
      if (_selectedProduct?.id == id && !isActive) _selectedProduct = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _messageOf(e);
      notifyListeners();
      return false;
    }
  }

  bool deleteProduct(int id) {
    try {
      _productRepository.deleteProduct(id: id);
      _priceRepository.removePrice(productId: id, locationId: demoLocationId);
      if (_selectedProduct?.id == id) _selectedProduct = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _messageOf(e);
      notifyListeners();
      return false;
    }
  }

  // ── Harga khusus lokasi (FR-13) ──
  /// Harga khusus produk di lokasi sesi ini, atau null jika tidak ada.
  int? specialPriceFor(int productId) => _priceRepository.getPrice(
        productId: productId,
        locationId: demoLocationId,
      );

  /// Harga yang berlaku: harga khusus lokasi, jika tidak ada harga normal.
  int priceFor(Product product) =>
      specialPriceFor(product.id) ?? product.sellingPrice;

  // ── Input penjualan (FR-12) ──
  Product? get selectedProduct => _selectedProduct;
  String get quantityInput => _quantityInput;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Sale? get lastSavedSale => _lastSavedSale;
  List<Sale> get sales => List.unmodifiable(_sales);
  ViewStatus get historyStatus => _historyStatus;
  bool get isSaving => _isSaving;

  int? get quantity => int.tryParse(_quantityInput.trim());

  int get total {
    final product = _selectedProduct;
    final qty = quantity;
    if (product == null || qty == null || qty <= 0) return 0;
    return priceFor(product) * qty;
  }

  // ── Ringkasan sesi (FR-12 total penjualan, FR-14 selisih) ──
  int get totalSales => _sales.fold(0, (sum, s) => sum + s.total);

  /// SEMENTARA data demo; diganti total pengeluaran Modul 2.
  int get sessionExpense => SaleRepository.demoSessionExpense;

  /// Positif = untung, negatif = masih kurang untuk balik modal.
  int get balance => totalSales - sessionExpense;
  bool get isBreakEven => balance >= 0;

  void selectProduct(Product? product) {
    // Input tidak berubah ketika penyimpanan berlangsung.
    if (_isSaving) return;

    _selectedProduct = product != null &&
            product.isActive &&
            products.any((item) => item.id == product.id)
        ? _productRepository.getProductById(product.id)
        : null;

    _clearFeedback();
    notifyListeners();
  }

  void updateQuantity(String value) {
    // Input tidak berubah ketika penyimpanan berlangsung.
    if (_isSaving) return;

    _quantityInput = value;
    _clearFeedback();
    notifyListeners();
  }

  void _clearFeedback() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Mengambil ulang data dari repository,
  /// bukan membuat riwayat dummy.
  void loadHistory() {
    try {
      _sales = _saleRepository.getSalesBySession(demoSessionId);
      _historyStatus = ViewStatus.success;
    } catch (_) {
      _historyStatus = ViewStatus.error;
      _errorMessage = 'Riwayat penjualan gagal dimuat.';
    }

    notifyListeners();
  }

  /// True hanya ketika transaksi berhasil disimpan.
  /// Future digunakan agar loading tidak membekukan UI.
  Future<bool> saveSale() async {
    // Mencegah proses penyimpanan berulang.
    if (_isSaving) return false;

    _clearFeedback();
    _lastSavedSale = null;

    final product = _selectedProduct;
    final amount = quantity;

    // Validasi tetap dilakukan sebelum proses loading.
    if (product == null) {
      _errorMessage = 'Pilih produk terlebih dahulu.';
      notifyListeners();
      return false;
    }

    if (amount == null || amount <= 0) {
      _errorMessage = 'Jumlah terjual harus berupa bilangan bulat lebih dari 0.';
      notifyListeners();
      return false;
    }

    // Mulai loading.
    _isSaving = true;
    notifyListeners();

    try {
      // Jeda sementara untuk demonstrasi loading.
      if (demoLoading) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Simulasi error sebelum data masuk repository.
      if (demoSaveError) {
        throw StateError('Simulasi kegagalan penyimpanan.');
      }

      // Harga satuan yang disimpan = harga yang berlaku di lokasi (FR-13).
      _lastSavedSale = _saleRepository.addSale(
        sessionId: demoSessionId,
        productId: product.id,
        quantity: amount,
        unitPrice: priceFor(product),
      );

      _sales = _saleRepository.getSalesBySession(demoSessionId);
      _historyStatus = ViewStatus.success;
      _successMessage = 'Penjualan berhasil disimpan.';

      _selectedProduct = null;
      _quantityInput = '';

      return true;
    } catch (_) {
      _errorMessage = 'Penjualan gagal disimpan. Silakan coba lagi.';
      return false;
    } finally {
      // Loading selalu berhenti, baik berhasil maupun gagal.
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Mengubah jumlah pada catatan penjualan (FR-12).
  bool updateSaleQuantity({required int id, required int quantity}) {
    try {
      _saleRepository.updateQuantity(id: id, quantity: quantity);
      _sales = _saleRepository.getSalesBySession(demoSessionId);
      _errorMessage = null;
      _successMessage = 'Catatan penjualan diperbarui.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _messageOf(e);
      notifyListeners();
      return false;
    }
  }

  /// Menghapus catatan penjualan (FR-12).
  bool deleteSale(int id) {
    try {
      _saleRepository.deleteSale(id: id);
      _sales = _saleRepository.getSalesBySession(demoSessionId);
      _errorMessage = null;
      _successMessage = 'Catatan penjualan dihapus.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _messageOf(e);
      notifyListeners();
      return false;
    }
  }
}
