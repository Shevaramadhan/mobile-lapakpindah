// foundation.dart (bukan material.dart): ViewModel hanya butuh ChangeNotifier,
// tidak bergantung pada widget UI.
import 'package:flutter/foundation.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';
import 'package:lapakpindah/modules/sesi_lokasi/repositories/location_repository.dart';

/// ViewModel lokasi (M3: MVVM).
///
/// View (Daftar & Form Lokasi) → ViewModel (kelas ini) → LocationRepository.
/// Menyimpan state daftar lokasi dan proses simpan, lalu memberi tahu View
/// lewat `notifyListeners()` setiap kali state berubah.
class LocationViewModel extends ChangeNotifier {
  // ── Sumber data ──
  final _repository = LocationRepository();

  // ── State daftar lokasi ──
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  List<Location> _locations = [];

  // ── State proses simpan (form tambah lokasi) ──
  bool _isSaving = false;
  String? _saveError;

  // ── Getter untuk UI (UI hanya membaca, tidak mengubah langsung) ──
  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<Location> get locations => _locations;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  // ── Memuat daftar lokasi ──

  Future<void> loadLocations() async {
    // 1. Masuk loading state
    _status = ViewStatus.loading;
    notifyListeners();

    try {
      // 2. Ambil daftar dari repository
      _locations = await _repository.fetchAll();
      _status = ViewStatus.success;
    } catch (e) {
      // 3. Gagal: simpan pesan untuk ErrorView
      _errorMessage = e.toString();
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  // ── Validasi nama (dipakai validator form) ──

  /// true jika nama sudah dipakai lokasi lain.
  bool isNameTaken(String name) => _repository.isNameTaken(name);

  // ── Menyimpan lokasi baru ──

  /// Mengembalikan lokasi yang tersimpan, atau null jika gagal
  /// (pesan gagal tersedia di [saveError]).
  Future<Location?> addLocation(String name, String note) async {
    // 1. Mulai proses: tombol Simpan menampilkan loading
    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      // 2. Simpan lewat repository
      final saved = await _repository.add(name: name, note: note);
      // 3. Berhasil: muat ulang daftar agar layar Daftar ikut berubah
      _locations = await _repository.fetchAll();
      _status = ViewStatus.success;
      return saved;
    } on LocationException catch (e) {
      // Gagal karena aturan data (misal nama sudah ada)
      _saveError = e.message;
      return null;
    } catch (_) {
      // Gagal karena hal lain yang tidak terduga
      _saveError = 'Lokasi gagal disimpan. Coba lagi.';
      return null;
    } finally {
      // 4. Proses selesai (berhasil atau gagal): matikan loading
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
}
