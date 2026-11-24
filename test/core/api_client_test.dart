import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/core/network/api_client.dart';
import 'package:lapakpindah/core/network/api_exception.dart';
import 'package:lapakpindah/modules/auth/repositories/auth_repository.dart';

/// Contoh menguji repository yang memakai server tanpa server sungguhan:
/// MockClient menjawab request seperti backend Express.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ApiClient clientWith(MockClientHandler handler) => ApiClient(
    baseUrl: 'http://test.local/api/v1',
    httpClient: MockClient(handler),
  );

  test('GET memakai base URL, token, dan mengembalikan JSON', () async {
    late http.Request sent;
    final api = clientWith((request) async {
      sent = request;
      return http.Response(
        jsonEncode([
          {'id': 1, 'name': 'CFD'},
        ]),
        200,
      );
    })..setToken('abc');

    final data = await api.get('locations');

    expect(sent.url.toString(), 'http://test.local/api/v1/locations');
    expect(sent.headers['Authorization'], 'Bearer abc');
    expect(data, [
      {'id': 1, 'name': 'CFD'},
    ]);
  });

  test('error 422 menjadi ApiException dengan pesan per kolom', () async {
    final api = clientWith(
      (_) async => http.Response(
        jsonEncode({
          'message': 'Data lokasi tidak valid',
          'errors': {'name': 'Nama lokasi wajib diisi'},
        }),
        422,
      ),
    );

    await expectLater(
      api.post('locations', body: {'name': ''}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'Data lokasi tidak valid')
            .having(
              (e) => e.fieldErrors['name'],
              'name',
              'Nama lokasi wajib diisi',
            ),
      ),
    );
  });

  test('server tidak bisa dihubungi menjadi error jaringan', () async {
    final api = clientWith((_) async => throw http.ClientException('down'));

    await expectLater(
      api.get('locations'),
      throwsA(
        isA<ApiException>().having((e) => e.isNetworkError, 'network', true),
      ),
    );
  });

  test('AuthRepository login ke server lalu menyimpan token', () async {
    final api = clientWith((request) async {
      if (request.url.path.endsWith('/auth/login')) {
        return http.Response(
          jsonEncode({
            'token': 'tkn',
            'user': {
              'id': 1,
              'displayName': 'Bang Radit',
              'phone': '081234567890',
              'email': 'radit@gmail.com',
            },
          }),
          200,
        );
      }
      final authorized = request.headers['Authorization'] == 'Bearer tkn';
      return authorized
          ? http.Response(
              jsonEncode({
                'id': 1,
                'displayName': 'Bang Radit',
                'phone': '081234567890',
                'email': 'radit@gmail.com',
              }),
              200,
            )
          : http.Response(jsonEncode({'message': 'Silakan masuk'}), 401);
    });
    final repository = AuthRepository(api: api);

    final user = await repository.login(
      identifier: '081234567890',
      pin: '123456',
    );
    await repository.rememberAccount('081234567890');

    expect(user.displayName, 'Bang Radit');
    // Aplikasi dibuka ulang: token dibaca dari perangkat lalu dicek ke /auth/me.
    api.setToken(null);
    expect((await repository.getRememberedAccount())?.id, 1);

    await repository.logout();
    expect(await repository.getRememberedAccount(), isNull);
  });

  test('AuthRepository meneruskan pesan server saat PIN salah', () async {
    final api = clientWith(
      (_) async => http.Response(
        jsonEncode({'message': 'Nomor/email atau PIN salah.'}),
        401,
      ),
    );

    await expectLater(
      AuthRepository(api: api).login(identifier: '0812', pin: '000000'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Nomor/email atau PIN salah.',
        ),
      ),
    );
  });
}
