import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/core/utils/validators.dart';
import 'package:lapakpindah/main.dart';
import 'package:lapakpindah/modules/auth/repositories/auth_repository.dart';

void main() {
  // ── Validator login ──
  group('Validators', () {
    test('phoneOrEmail menerima nomor & email yang benar', () {
      expect(Validators.phoneOrEmail('0812-3456-7890'), isNull);
      expect(Validators.phoneOrEmail('+6281234567890'), isNull);
      expect(Validators.phoneOrEmail('radit@gmail.com'), isNull);
    });

    test('phoneOrEmail menolak input kosong / salah', () {
      expect(Validators.phoneOrEmail(''), isNotNull);
      expect(Validators.phoneOrEmail('0812'), isNotNull);
      expect(Validators.phoneOrEmail('radit@'), isNotNull);
    });

    test('pin wajib tepat 6 digit angka', () {
      expect(Validators.pin('123456'), isNull);
      expect(Validators.pin('12345'), isNotNull);
      expect(Validators.pin('12a456'), isNotNull);
    });
  });

  // ── Akun demo ──
  group('AuthRepository', () {
    test('format nomor berbeda tetap dikenali', () {
      expect(AuthRepository.normalizeIdentifier('+62 812-3456-7890'),
          '081234567890');
      expect(AuthRepository.normalizeIdentifier('Radit@Gmail.com'),
          'radit@gmail.com');
    });

    test('PIN salah melempar AuthException', () async {
      expect(
        () => AuthRepository().login(identifier: '081234567890', pin: '000000'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // ── Alur Login → Beranda di layar HP kecil (360×640) ──
  testWidgets('login dengan email membuka Beranda tanpa overflow',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const LapakPindahApp());
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Akun'), findsOneWidget);

    // Isi form lalu tekan Masuk
    await tester.enterText(find.byType(TextFormField).at(0), 'radit@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(seconds: 1)); // proses login
    await tester.pump(const Duration(seconds: 1)); // transisi + muat dashboard
    await tester.pump(const Duration(seconds: 1));

    // Beranda tampil dengan data dummy
    expect(find.text('Halo, Bang Radit'), findsOneWidget);
    expect(find.text('Lapak sedang buka'), findsOneWidget);
    expect(find.text('CFD Jam Gadang'), findsOneWidget);

    // Gulir ke bawah untuk melihat kartu estimasi (di bawah peta).
    // Drag dari area teks sapaan, bukan dari peta (peta menangkap geseran).
    await tester.drag(find.text('Lapak sedang buka'), const Offset(0, -400));
    await tester.pump();
    expect(find.text('Sudah balik modal'), findsOneWidget);
    expect(find.text('Rp 400.000'), findsOneWidget);
  });

  // ── "Ingat akun ini di perangkat ini" ──

  /// Login dengan akun demo. [remember] = status checkbox "ingat akun".
  Future<void> loginDemo(WidgetTester tester, {required bool remember}) async {
    await tester.pumpWidget(const LapakPindahApp());
    await tester.pumpAndSettle();
    if (!remember) {
      await tester.tap(find.byType(Checkbox)); // default tercentang → lepas
      await tester.pump();
    }
    await tester.enterText(find.byType(TextFormField).at(0), '081234567890');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Halo, Bang Radit'), findsOneWidget);
  }

  /// Menutup lalu membuka ulang aplikasi (state di memori hilang,
  /// data shared_preferences tetap ada).
  Future<void> restartApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const LapakPindahApp());
    await tester.pump(); // cek akun yang diingat
    await tester.pump(const Duration(seconds: 1)); // transisi ke Beranda
    await tester.pump(const Duration(seconds: 1)); // muat dashboard
  }

  testWidgets('akun diingat → buka ulang aplikasi langsung ke Beranda',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await loginDemo(tester, remember: true);

    await restartApp(tester);
    expect(find.text('Halo, Bang Radit'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsNothing);
  });

  testWidgets('akun tidak diingat → buka ulang aplikasi tetap di Login',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await loginDemo(tester, remember: false);

    await restartApp(tester);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
