import 'package:flutter/foundation.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/repositories/pengeluaran_repository.dart';

/// ViewModel FORM Tambah Pengeluaran (M3: MVVM).
///
/// Menyimpan seluruh state form di satu tempat agar perubahan data
/// (keterangan, jumlah, proses simpan, pesan gagal) bisa diuji tanpa UI:
/// - [description] & [amountText] : isi form
/// - [isSaving]                    : proses simpan sedang berjalan (Frame 8)
/// - [saveError]                   : pesan gagal (Frame 9)
class TambahPengeluaranViewModel extends ChangeNotifier {
  TambahPengeluaranViewModel({required this.sessionId, PengeluaranRepository? repository})
      : _repository = repository ?? PengeluaranRepository();

  final PengeluaranRepository _repository;

  /// Sesi tujuan pencatatan pengeluaran (dikirim dari layar Daftar).
  final String sessionId;

  // ═══ [STATE] Variabel state form Tambah Pengeluaran ═══
  // ── State form ──
  String _description = '';
  String _amountText = '';
  ExpenseCategory _category = ExpenseCategory.bahanBaku;
  bool _isSaving = false;
  String? _saveError;
  String? _receiptPhotoPath;

  // ── Getter untuk UI ──
  String get description => _description;
  String get amountText => _amountText;
  ExpenseCategory get category => _category;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;
  String? get receiptPhotoPath => _receiptPhotoPath;

  /// Nominal hasil parsing. 0 jika teks belum berisi angka.
  double get amount => _parseAmount(_amountText);

  // ═══ [VALIDATION] Tombol Simpan aktif hanya jika valid ═══
  /// Tombol Simpan aktif hanya jika form terisi (Frame 7: tombol nonaktif).
  bool get canSave =>
      !_isSaving && _description.trim().isNotEmpty && amount > 0;

  // ── Event: isi form ──

  void setDescription(String value) {
    if (_description == value) return;
    _description = value;
    _saveError = null;
    notifyListeners();
  }

  void setAmountText(String value) {
    if (_amountText == value) return;
    _amountText = value;
    _saveError = null;
    notifyListeners();
  }

  void setCategory(ExpenseCategory value) {
    if (_category == value) return;
    _category = value;
    notifyListeners();
  }

  void setReceiptPhotoPath(String? path) {
    _receiptPhotoPath = path;
    notifyListeners();
  }

  // ── Validation (dipakai validator TextFormField) ──

  // ═══ [VALIDATION] Validasi keterangan (lapis 1 - ViewModel) ═══
  /// Keterangan wajib diisi.
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Keterangan wajib diisi';
    }
    return null;
  }

  // ═══ [VALIDATION] Validasi nominal (lapis 1 - ViewModel) ═══
  /// Jumlah wajib diisi dan harus lebih dari Rp 0.
  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah biaya wajib diisi';
    }
    if (value.trim().startsWith('-')) {
      return 'Jumlah biaya tidak boleh negatif';
    }
    final parsed = _parseAmount(value);
    if (parsed <= 0) {
      return 'Jumlah harus lebih dari Rp 0';
    }
    return null;
  }

  // ── Event: tombol Simpan ditekan ──

  // ═══ [EVENT → PROSES] Tombol Simpan ditekan ═══
  /// Menyimpan pengeluaran. Mengembalikan objek [Expense] jika berhasil,
  /// atau null jika gagal (pesan tersedia di [saveError]).
  Future<Expense?> save() async {
    // ── Guard re-entry pencegah race condition / double-tap ──
    if (_isSaving) return null;

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      final saved = await _repository.addExpense(
        sessionId: sessionId,
        description: _description,
        amount: amount,
        category: _category,
        receiptPhotoPath: _receiptPhotoPath,
      );
      return saved;
    } on PengeluaranException catch (e) {
      _saveError = e.message;
      return null;
    } catch (_) {
      _saveError = 'Pengeluaran gagal disimpan. Coba lagi.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Menghapus pesan gagal lama saat form dibuka lagi.
  void clearSaveError() {
    if (_saveError == null) return;
    _saveError = null;
    notifyListeners();
  }

  // ═══ [PARSING] Konversi teks "20.000" / "20.000,50" → angka 20000 ═══
  /// "20.000" / "20000" / "Rp 20.000" / "20.000,50" → 20000.
  static double _parseAmount(String raw) {
    var trimmed = raw.trim();
    if (trimmed.startsWith('-')) return 0;
    // Potong bagian desimal (sen) jika pengguna mengetik pemisah koma
    if (trimmed.contains(',')) {
      trimmed = trimmed.split(',').first;
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return double.tryParse(digits) ?? 0;
  }
}