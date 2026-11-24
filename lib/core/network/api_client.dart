import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/core/network/api_config.dart';
import 'package:lapakpindah/core/network/api_exception.dart';

/// Penghubung aplikasi ke backend Express. Dipakai bersama semua modul.
///
/// Repository modul memanggil [get]/[post]/[put]/[delete] dengan path
/// relatif terhadap `API_BASE_URL`, misalnya `_api.get('locations')`.
/// Hasilnya JSON yang sudah di-decode (Map atau List). Semua kegagalan
/// dilempar sebagai [ApiException].
///
/// Hanya repository yang boleh memakai kelas ini; View dan ViewModel tidak.
class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? httpClient,
    this.timeout = ApiConfig.timeout,
  }) : _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
       _http = httpClient ?? http.Client();

  /// Klien bersama, atau null jika aplikasi dijalankan tanpa `API_BASE_URL`.
  /// Pola di repository: `ApiClient.shared != null ? versi server : versi lokal`.
  static final ApiClient? shared = ApiConfig.isConfigured
      ? ApiClient(baseUrl: ApiConfig.baseUrl)
      : null;

  static const String _tokenKey = 'api_token';

  final Uri _baseUri;
  final http.Client _http;
  final Duration timeout;
  String? _token;

  bool get hasToken => _token != null;

  // ── Token login ──

  /// Dipanggil setelah login berhasil (token disimpan di memori).
  void setToken(String? token) => _token = token;

  /// Menyimpan token di perangkat agar tetap login saat aplikasi dibuka lagi.
  Future<void> persistToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, _token!);
    }
  }

  /// Membaca token yang tersimpan. Mengembalikan true jika ada.
  Future<bool> restoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token != null;
  }

  /// Hapus token dari perangkat saja; sesi yang sedang berjalan tetap login.
  Future<void> forgetPersistedToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Logout: hapus token dari memori dan perangkat.
  Future<void> clearToken() async {
    _token = null;
    await forgetPersistedToken();
  }

  // ── Request ──

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send(() => _http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, {Object? body}) => _send(
    () => _http.post(_uri(path), headers: _headers(), body: _encode(body)),
  );

  Future<dynamic> put(String path, {Object? body}) => _send(
    () => _http.put(_uri(path), headers: _headers(), body: _encode(body)),
  );

  Future<dynamic> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers()));

  /// Upload satu file (misalnya foto nota Modul 2) sebagai multipart.
  Future<dynamic> uploadFile(
    String path, {
    required String field,
    required String filePath,
    Map<String, String> fields = const {},
  }) => _send(() async {
    final request = http.MultipartRequest('POST', _uri(path))
      ..headers.addAll(_headers(json: false))
      ..fields.addAll(fields)
      ..files.add(await http.MultipartFile.fromPath(field, filePath));
    return http.Response.fromStream(await _http.send(request));
  });

  // ── Bagian dalam ──

  Uri _uri(String path, [Map<String, String>? query]) {
    final relative = path.startsWith('/') ? path.substring(1) : path;
    final uri = _baseUri.resolve(relative);
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  Map<String, String> _headers({bool json = true}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  String? _encode(Object? body) => body == null ? null : jsonEncode(body);

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'Server terlalu lama menjawab. Periksa koneksi internet.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }

    final dynamic data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Jawaban server tidak dapat dibaca.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    // Format error backend: { message, errors? }
    final message = data is Map && data['message'] is String
        ? data['message'] as String
        : 'Terjadi kesalahan di server (${response.statusCode}).';
    final errors = data is Map && data['errors'] is Map
        ? (data['errors'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : const <String, String>{};
    throw ApiException(
      message,
      statusCode: response.statusCode,
      fieldErrors: errors,
    );
  }
}
