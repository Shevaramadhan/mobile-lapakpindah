import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_theme.dart';
import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';
import 'package:lapakpindah/modules/sesi_lokasi/repositories/location_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/models/profit_target.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/models/profit_series.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/repositories/profit_target_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/repositories/evaluation_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/view_models/evaluation_view_model.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/view_models/profit_target_view_model.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/views/evaluation_screen.dart';
import 'package:lapakpindah/routes/app_routes.dart';

class _Locations extends LocationRepository {
  @override
  Future<List<Location>> fetchAll() async => [
    const Location(id: 'cfd', name: 'CFD Jam Gadang'),
    const Location(id: 'kantor', name: 'Area Perkantoran'),
  ];
}

class _Targets extends ProfitTargetRepository {
  ProfitTarget? target;
  bool fail = false;
  Completer<void>? gate;
  int writes = 0;
  @override
  Future<List<ProfitTarget>> fetchAll() async => [?target];
  @override
  Future<ProfitTarget> save(String locationId, int amount) async {
    writes++;
    if (gate != null) await gate!.future;
    if (fail) throw StateError('Disk failure');
    return target = ProfitTarget(id: 1, locationId: locationId, amount: amount);
  }

  @override
  Future<void> delete(int id) async {
    target = null;
  }
}

class _Evaluation extends EvaluationRepository {
  @override
  Future<List<SessionProfit>> fetchSessions() async => [
    SessionProfit(
      id: 's',
      locationId: 'cfd',
      date: DateTime(2026, 10, 13),
      revenue: 150000,
      expense: 25000,
    ),
  ];
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  late _Targets targets;
  late ProfitTargetViewModel form;
  late EvaluationViewModel evaluation;

  Future<void> start(
    WidgetTester tester, {
    Size size = const Size(390, 884),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final locations = _Locations();
    targets = _Targets();
    form = ProfitTargetViewModel(
      repository: targets,
      locationsRepository: locations,
    );
    evaluation = EvaluationViewModel(
      locationsRepository: locations,
      repository: _Evaluation(),
      targetsRepository: targets,
      now: () => DateTime(2026, 10, 13),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => form),
          ChangeNotifierProvider(create: (_) => evaluation),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EvaluationScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kelola Target'), 200);
    await tester.tap(find.text('Kelola Target'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'validasi → gagal simpan → retry → result → dashboard → ubah → hapus',
    (tester) async {
      await start(tester);
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      expect(find.text('Nominal target wajib diisi'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      expect(
        find.text('Target laba minimal Rp 100.000 per sesi'),
        findsOneWidget,
      );
      expect(targets.writes, 0);

      await tester.enterText(find.byType(TextFormField), '99999');
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      expect(
        find.text('Target laba minimal Rp 100.000 per sesi'),
        findsOneWidget,
      );
      expect(targets.writes, 0);

      targets.fail = true;
      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Target gagal disimpan'), findsOneWidget);
      expect(form.amountText, '100.000');

      targets.fail = false;
      targets.gate = Completer<void>();
      await tester.tap(find.text('Simpan Target'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(form.isSaving, isTrue);
      final writes = targets.writes;
      await form.save(); // double submit ditolak oleh ViewModel juga
      expect(targets.writes, writes);
      targets.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Target Disimpan!'), findsOneWidget);
      expect(find.text('Rp 100.000'), findsWidgets);
      await tester.tap(find.text('Kembali ke Evaluasi'));
      await tester.pumpAndSettle();
      expect(find.text('Target Disimpan!'), findsNothing);
      await tester.scrollUntilVisible(find.text('Ubah Target'), 200);
      expect(find.text('Tercapai'), findsOneWidget);
      await tester.tap(find.text('Ubah Target'));
      await tester.pumpAndSettle();
      expect(form.amountText, '100.000');
      expect(form.dirty, isFalse);
      await tester.enterText(find.byType(TextFormField), '150000');
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kembali ke Evaluasi'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Hapus Target'), 200);
      expect(find.text('Belum tercapai'), findsOneWidget);
      await tester.tap(find.text('Hapus Target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(targets.target, isNull);
      expect(find.text('Target berhasil dihapus'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'batal perubahan, atur target lain, dan layar kecil dengan keyboard',
    (tester) async {
      await start(tester, size: const Size(360, 640));
      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.text('Batalkan perubahan?'), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pump();
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump();
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Atur Target Lain'));
      await tester.tap(find.text('Atur Target Lain'));
      await tester.pumpAndSettle();
      expect(form.locationId, isNull);
      expect(form.amountText, isEmpty);
      await tester.tap(find.text('Simpan Target'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih lokasi terlebih dahulu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('menu lokasi memilih lokasi lain dan memperbarui form', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.byTooltip('Pilih lokasi jualan'));
    await tester.pumpAndSettle();
    expect(find.text('Area Perkantoran'), findsOneWidget);

    await tester.tap(find.text('Area Perkantoran'));
    await tester.pumpAndSettle();
    expect(form.locationId, 'kantor');
    expect(find.text('Area Perkantoran'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
