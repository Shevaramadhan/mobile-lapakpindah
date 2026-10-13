import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/core/utils/validators.dart';
import 'package:lapakpindah/main.dart';
import 'package:lapakpindah/modules/sesi_lokasi/repositories/location_repository.dart';

void main() {
  // ── Validator panjang maksimal ──
  test('maxLength: kosong valid, lebih dari batas ditolak', () {
    expect(Validators.maxLength('', 5), isNull);
    expect(Validators.maxLength('abcde', 5), isNull);
    expect(
      Validators.maxLength('abcdef', 5, fieldName: 'Catatan'),
      'Catatan maksimal 5 karakter',
    );
  });

  // ── Repository lokasi (data di memori) ──
  group('LocationRepository', () {
    test('awal kosong, lalu bertambah setelah add', () async {
      final repository = LocationRepository();
      expect(await repository.fetchAll(), isEmpty);

      final saved = await repository.add(name: '  Pasar Kaget ', note: '');
      expect(saved.name, 'Pasar Kaget');
      expect(saved.note, isNull); // catatan kosong disimpan sebagai null
      expect(await repository.fetchAll(), hasLength(1));
    });

    test('nama ganda (beda huruf besar/kecil) ditolak', () async {
      final repository = LocationRepository();
      await repository.add(name: 'Pasar Kaget');
      expect(
        () => repository.add(name: 'pasar  KAGET'),
        throwsA(isA<LocationException>()),
      );
    });
  });

  // ── Workflow Tambah Lokasi: event → validasi → feedback → result ──
  testWidgets('tambah lokasi dari daftar kosong sampai tampil di daftar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LapakPindahApp());
    await tester.pumpAndSettle();

    // Login akun demo
    await tester.enterText(find.byType(TextFormField).at(0), '081234567890');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Buka tab Lokasi → daftar masih kosong
    await tester.tap(find.widgetWithText(InkWell, 'Lokasi'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Belum ada lokasi'), findsOneWidget);

    // Event: tekan + → form terbuka
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // halaman form mulai dibangun
    await tester.pump(const Duration(seconds: 1)); // animasi pindah halaman
    expect(find.text('Tambah Lokasi'), findsOneWidget);

    // Validasi: simpan dengan nama kosong → error, tetap di form
    await tester.tap(find.text('Simpan lokasi'));
    await tester.pump();
    expect(find.text('Nama tempat wajib diisi'), findsOneWidget);

    // Isi form lalu simpan
    await tester.enterText(find.byType(TextFormField).at(0), 'Pasar Kaget');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Lapak sisi timur',
    );
    await tester.tap(find.text('Simpan lokasi'));
    await tester.pump(const Duration(seconds: 1)); // proses simpan
    await tester.pump(const Duration(seconds: 1)); // kembali ke daftar

    // Result: kembali ke daftar, SnackBar + kartu lokasi baru tampil
    expect(find.text('Tambah Lokasi'), findsNothing);
    expect(find.text('Lokasi "Pasar Kaget" ditambahkan'), findsOneWidget);
    expect(find.text('Lokasi tersimpan (1)'), findsOneWidget);
    expect(find.text('Lapak sisi timur'), findsOneWidget);

    // Tunggu SnackBar hilang (tampil 4 detik) agar tidak menutupi tombol +
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));

    // Validasi nama ganda: tambah lagi dengan nama yang sama
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // halaman form mulai dibangun
    await tester.pump(const Duration(seconds: 1)); // animasi pindah halaman
    await tester.enterText(find.byType(TextFormField).at(0), 'pasar kaget');
    await tester.tap(find.text('Simpan lokasi'));
    await tester.pump();
    expect(find.text('Nama tempat sudah dipakai lokasi lain'), findsOneWidget);
  });
}
