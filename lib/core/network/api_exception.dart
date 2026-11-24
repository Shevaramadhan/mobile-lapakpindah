/// Satu jenis error untuk semua kegagalan komunikasi dengan server.
///
/// [message] sudah ramah pengguna (berbahasa Indonesia dari server), jadi
/// ViewModel boleh langsung menampilkannya. Untuk form, pesan per kolom
/// ada di [fieldErrors], contoh `fieldErrors['name']`.
class ApiException implements Exception {
  final String message;

  /// Kode HTTP dari server, atau null jika server tidak bisa dihubungi.
  final int? statusCode;
  final Map<String, String> fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Tidak ada internet, server mati, atau terlalu lama menjawab.
  bool get isNetworkError => statusCode == null;

  /// Token tidak ada atau kedaluwarsa; pengguna perlu login ulang.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
