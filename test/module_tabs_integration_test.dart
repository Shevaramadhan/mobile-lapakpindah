import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapakpindah/main.dart';
import 'package:lapakpindah/modules/sesi_lokasi/repositories/location_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('semua tab modul dapat dibuka setelah login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      LapakPindahApp(locationRepository: LocationRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '081234567890');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.widgetWithText(InkWell, 'Lokasi'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.widgetWithText(AppBar, 'Lokasi'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(InkWell, 'Biaya'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.widgetWithText(AppBar, 'Pengeluaran'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(InkWell, 'Penjualan'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.widgetWithText(AppBar, 'Pencatatan Penjualan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(InkWell, 'Evaluasi'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Evaluasi Lokasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
