// foundation.dart (bukan material.dart): ViewModel hanya butuh ChangeNotifier,
// tidak bergantung pada widget UI.
import 'package:flutter/foundation.dart';
import 'package:lapakpindah/modules/auth/models/app_user.dart';
import 'package:lapakpindah/modules/auth/repositories/auth_repository.dart';

/// ViewModel autentikasi (M3: MVVM).
///
/// View (LoginScreen) → ViewModel (kelas ini) → Model/Data (AuthRepository).
/// Tugasnya: menyimpan state login untuk UI dan memanggil repository.
/// Urusan penyimpanan data (termasuk "ingat akun") ada di repository.
class AuthViewModel extends ChangeNotifier {
  // ── Sumber data ──
  final _repository = AuthRepository();

  // ── State ──
  bool _isLoading = false;
  AppUser? _user;
  String? _errorMessage;
  bool _rememberDevice = true;

  // ── Getter untuk UI (UI hanya membaca, tidak mengubah langsung) ──
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  AppUser? get user => _user;
  String? get userName => _user?.displayName;
  String? get errorMessage => _errorMessage;
  bool get rememberDevice => _rememberDevice;

  // ── Info akun demo (ditampilkan di halaman "Buat akun") ──
  // View membaca lewat ViewModel, tidak langsung ke repository (M3: MVVM).
  static String get demoPhone => AuthRepository.demoPhone;
  static String get demoEmail => AuthRepository.demoEmail;
  static String get demoPin => AuthRepository.demoPin;

  /// Toggle checkbox "Ingat akun ini di perangkat ini".
  void toggleRememberDevice(bool value) {
    _rememberDevice = value;
    notifyListeners();
  }

  // ── Login ──

  /// Login dengan nomor WhatsApp / email dan PIN.
  /// Mengembalikan true jika berhasil. Jika gagal, pesan ada di [errorMessage].
  Future<bool> login(String identifier, String pin) async {
    // 1. Masuk loading state & hapus error lama
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. Cek ke repository (melempar AuthException jika salah)
      _user = await _repository.login(identifier: identifier, pin: pin);

      // 3. Dicentang → ingat akun; tidak dicentang → hapus akun yang dulu diingat
      if (_rememberDevice) {
        await _repository.rememberAccount(identifier);
      } else {
        await _repository.forgetAccount();
      }
      return true;
    } on AuthException catch (e) {
      // Error yang dikenali (nomor/email atau PIN salah)
      _errorMessage = e.message;
      return false;
    } catch (_) {
      // Error lain yang tidak terduga
      _errorMessage = 'Terjadi kesalahan. Coba lagi nanti.';
      return false;
    } finally {
      // 4. Selalu keluar dari loading state, berhasil maupun gagal
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ──

  /// Logout dan hapus akun yang diingat.
  Future<void> logout() async {
    _user = null;
    await _repository.forgetAccount();
    notifyListeners();
  }

  // ── Akun yang diingat ──

  /// Dipanggil saat aplikasi dibuka. Jika ada akun yang diingat,
  /// pengguna dianggap sudah login. Mengembalikan true jika berhasil.
  Future<bool> checkSavedSession() async {
    _user = await _repository.getRememberedAccount();
    notifyListeners();
    return _user != null;
  }
}
