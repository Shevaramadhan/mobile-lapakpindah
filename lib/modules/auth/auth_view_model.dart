import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/core/database/db_helper.dart';

/// ViewModel autentikasi — MVVM pattern.
class AuthViewModel extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper.instance;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userName;
  bool _rememberDevice = true;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  bool get rememberDevice => _rememberDevice;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyIdentifier = 'identifier';

  /// Toggle checkbox "Ingat perangkat ini".
  void toggleRememberDevice(bool value) {
    _rememberDevice = value;
    notifyListeners();
  }

  /// Login dengan identifier (WA/email) dan password.
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi delay network-like
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _dbHelper.validateLogin(identifier, password);

      if (user != null) {
        _isLoggedIn = true;
        _userName = user['name'] as String?;

        if (_rememberDevice) {
          await _saveSession(identifier);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout dan hapus session.
  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  /// Cek apakah ada session tersimpan.
  Future<bool> checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (isLoggedIn) {
      _isLoggedIn = true;
      _userName = prefs.getString(_keyUserName);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _saveSession(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserName, _userName ?? '');
    await prefs.setString(_keyIdentifier, identifier);
  }
}
