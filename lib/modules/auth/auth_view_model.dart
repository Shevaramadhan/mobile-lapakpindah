import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/data/auth_repository.dart';
import 'package:lapakpindah/models/app_user.dart';

/// ViewModel autentikasi (M3: MVVM).
///
/// View (LoginScreen) → ViewModel (kelas ini) → Model/Data (AuthRepository).
/// Tugasnya: menyimpan state login untuk UI, memanggil repository,
/// dan mengingat akun di perangkat (shared_preferences).
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

  // ── Key penyimpanan di perangkat ──
  static const String _keyIdentifier = 'logged_in_identifier';

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
        await _saveSession(identifier);
      } else {
        await _clearSession();
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
    await _clearSession();
    notifyListeners();
  }

  // ── Akun yang diingat ──

  /// Dipanggil saat aplikasi dibuka. Jika ada akun yang diingat,
  /// pengguna dianggap sudah login. Mengembalikan true jika berhasil.
  Future<bool> checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final identifier = prefs.getString(_keyIdentifier);
    if (identifier == null) return false;

    _user = await _repository.findByIdentifier(identifier);
    notifyListeners();
    return _user != null;
  }

  Future<void> _saveSession(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdentifier, identifier);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIdentifier);
  }
}
