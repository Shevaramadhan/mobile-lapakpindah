/// Alamat server backend, diisi saat menjalankan aplikasi:
///
///   flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
///
/// Tanpa `API_BASE_URL`, [isConfigured] bernilai false dan setiap modul
/// tetap memakai repository lokal (data contoh). Karena itu tes dan
/// `flutter run` biasa tetap berjalan tanpa server.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Batas waktu menunggu jawaban server sebelum dianggap gagal.
  static const Duration timeout = Duration(seconds: 15);
}
