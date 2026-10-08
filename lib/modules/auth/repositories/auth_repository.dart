import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/modules/auth/models/app_user.dart';

/// Exception khusus untuk kegagalan login (nomor/email atau PIN salah).
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Data layer autentikasi (M3: lapisan Data pada MVVM).
///
/// Tugasnya: mengecek akun dan mengingat akun di perangkat.
/// SEMENTARA: belum memakai database. Akun demo disimpan di memori.
/// Saat SQLite dipakai, cukup isi method di kelas ini yang diganti;
/// ViewModel dan UI tidak perlu diubah.
class AuthRepository {
  // ── Key penyimpanan "ingat akun" di perangkat (shared_preferences) ──
  static const String _keyRememberedIdentifier = 'logged_in_identifier';

  // ── Akun demo (dummy) ──
  // Bisa login dengan nomor WA ATAU email, PIN sama.
  static const String demoPhone = '081234567890';
  static const String demoEmail = 'radit@gmail.com';
  static const String demoPin = '123456';

  static const AppUser _demoUser = AppUser(
    id: 1,
    displayName: 'Bang Radit',
    phone: demoPhone,
    email: demoEmail,
  );

  // ── Login ──

  /// Mengembalikan [AppUser] jika nomor/email dan PIN cocok,
  /// atau melempar [AuthException] jika salah.
  Future<AppUser> login({
    required String identifier,
    required String pin,
  }) async {
    // Simulasi waktu proses agar loading state di UI bisa diuji.
    await Future.delayed(const Duration(milliseconds: 800));

    final user = await findByIdentifier(identifier);
    if (user == null || pin != demoPin) {
      throw const AuthException('Nomor/email atau PIN salah.');
    }
    return user;
  }

  // ── Cari user dari nomor/email (dipakai login & sesi yang diingat) ──

  /// Mengembalikan user jika nomor/email terdaftar, atau null jika tidak.
  Future<AppUser?> findByIdentifier(String identifier) async {
    final normalized = normalizeIdentifier(identifier);
    final isMatch = normalized == _demoUser.phone || normalized == _demoUser.email;
    return isMatch ? _demoUser : null;
  }

  // ── Ingat akun di perangkat ──

  /// Menyimpan nomor/email agar aplikasi bisa login otomatis saat dibuka lagi.
  Future<void> rememberAccount(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRememberedIdentifier, identifier);
  }

  /// Menghapus akun yang diingat (saat logout atau checkbox tidak dicentang).
  Future<void> forgetAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberedIdentifier);
  }

  /// Mengembalikan user yang diingat di perangkat, atau null jika tidak ada.
  Future<AppUser?> getRememberedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final identifier = prefs.getString(_keyRememberedIdentifier);
    if (identifier == null) return null;
    return findByIdentifier(identifier);
  }

  // ── Normalisasi input ──

  /// Menyeragamkan format input agar penulisan berbeda tetap dikenali:
  /// - Email           → huruf kecil, contoh "Radit@Gmail.com" → "radit@gmail.com".
  /// - Nomor WhatsApp  → buang spasi/strip, "+62"/"62" diganti "0",
  ///                     contoh "+62 812-3456-7890" → "081234567890".
  static String normalizeIdentifier(String input) {
    final value = input.trim();
    if (value.contains('@')) return value.toLowerCase();

    var digits = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (digits.startsWith('+62')) {
      digits = '0${digits.substring(3)}';
    } else if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }
}
