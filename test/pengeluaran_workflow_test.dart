import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapakpindah/main.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/models/session_info.dart';
import 'package:lapakpindah/modules/pengeluaran/repositories/pengeluaran_repository.dart';
import 'package:lapakpindah/modules/pengeluaran/view_models/pengeluaran_view_model.dart';
import 'package:lapakpindah/modules/pengeluaran/view_models/tambah_pengeluaran_view_model.dart';
import 'package:lapakpindah/modules/pengeluaran/views/tambah_pengeluaran_screen.dart';

void main() {
  setUp(() {
    PengeluaranRepository().resetForTesting();
  });

  group('TambahPengeluaranViewModel (Form State & Validation)', () {
    test('canSave hanya true jika keterangan & jumlah terisi valid', () {
      final vm = TambahPengeluaranViewModel(sessionId: 'test-session');
      expect(vm.canSave, isFalse);

      vm.setDescription('Beli Gas');
      expect(vm.canSave, isFalse); // nominal masih 0

      vm.setAmountText('20000');
      expect(vm.canSave, isTrue); // valid

      vm.setDescription('   ');
      expect(vm.canSave, isFalse); // keterangan kosong lagi
    });

    test('validasi keterangan: kosong ditolak', () {
      final vm = TambahPengeluaranViewModel(sessionId: 'test-session');
      expect(vm.validateDescription(''), 'Keterangan wajib diisi');
      expect(vm.validateDescription('   '), 'Keterangan wajib diisi');
      expect(vm.validateDescription('Beli es batu'), isNull);
    });

    test('validasi jumlah: kosong, negatif, atau 0 ditolak', () {
      final vm = TambahPengeluaranViewModel(sessionId: 'test-session');
      expect(vm.validateAmount(''), 'Jumlah biaya wajib diisi');
      expect(vm.validateAmount('-5000'), 'Jumlah biaya tidak boleh negatif');
      expect(vm.validateAmount('0'), 'Jumlah harus lebih dari Rp 0');
      expect(vm.validateAmount('25000'), isNull);
    });

    test("parsing nominal: '20.000' dan '20.000,50' terurai benar menjadi 20000", () {
      final vm = TambahPengeluaranViewModel(sessionId: 'test-session');
      vm.setAmountText('20.000');
      expect(vm.amount, 20000);
      expect(vm.validateAmount('20.000'), isNull);

      vm.setAmountText('20.000,50');
      expect(vm.amount, 20000);
      expect(vm.validateAmount('20.000,50'), isNull);
    });

    test('save() berhasil mengembalikan objek Expense', () async {
      final vm = TambahPengeluaranViewModel(sessionId: 'test-session');
      vm.setDescription('Beli sendok plastik');
      vm.setAmountText('15000');

      final saved = await vm.save();
      expect(saved, isNotNull);
      expect(saved?.description, 'Beli sendok plastik');
      expect(saved?.amount, 15000);
      expect(saved?.sessionId, 'test-session');
    });

    test('save() mencegah double call / race condition via re-entry guard', () async {
      final vm = TambahPengeluaranViewModel(sessionId: 'test-session');
      vm.setDescription('Beli sendok plastik');
      vm.setAmountText('15000');

      // Panggil save dua kali secara bersamaan (simulasi double-tap)
      final future1 = vm.save();
      final future2 = vm.save();
      final results = await Future.wait([future1, future2]);

      expect(results[0], isNotNull);
      expect(results[1], isNull); // Panggilan kedua harus diblokir oleh guard
    });

    test('PengeluaranRepository adalah singleton dan tersinkronisasi antar ViewModel', () async {
      final repo1 = PengeluaranRepository();
      final repo2 = PengeluaranRepository();
      expect(identical(repo1, repo2), isTrue);

      final formVm = TambahPengeluaranViewModel(sessionId: 'session-cfd-01');
      formVm.setDescription('Bumbu Dapur Tambahan');
      formVm.setAmountText('12000');
      final saved = await formVm.save();
      expect(saved, isNotNull);

      final listVm = PengeluaranViewModel();
      await listVm.loadData();
      final existsInList = listVm.expenses.any((e) => e.description == 'Bumbu Dapur Tambahan');
      expect(existsInList, isTrue);
    });
  });

  group('PengeluaranViewModel (State & Calculation)', () {
    test('kalkulasi total, limit, sisa, dan persentase', () async {
      final vm = PengeluaranViewModel();
      await vm.loadData();

      // Data awal: 5 item, total Rp 160.000, limit Rp 200.000
      expect(vm.expenses.length, 5);
      expect(vm.totalExpense, 160000);
      expect(vm.limit?.limitAmount, 200000);
      expect(vm.remainingLimit, 40000);
      expect(vm.usagePercent, 80);
      expect(vm.isLimitReached, isFalse);

      // Tambahkan item baru Rp 50.000 (total jadi Rp 210.000, tembus limit)
      vm.applyNewExpense(Expense(
        id: 'new-01',
        sessionId: 'session-cfd-01',
        description: 'Minyak 2L',
        amount: 50000,
        recordedAt: DateTime.now(),
      ));

      expect(vm.expenses.length, 6);
      expect(vm.totalExpense, 210000);
      expect(vm.remainingLimit, 0);
      expect(vm.usagePercent, 100);
      expect(vm.isLimitReached, isTrue);
    });
  });

  group('PengeluaranRepository & Notifikasi (FR-08, FR-09, FR-10)', () {
    test('FR-08 auto-apply fixed costs saat sesi baru diaktifkan', () async {
      final repo = PengeluaranRepository();
      final newSession = SessionInfo(
        id: 'new-session-99',
        locationId: 'loc-cfd',
        locationName: 'CFD Jam Gadang',
        openTime: DateTime.now(),
        plannedCloseTime: DateTime.now().add(const Duration(hours: 4)),
      );

      final addedCosts = await repo.setActiveSession(newSession, autoApplyFixedCosts: true);
      // Di loc-cfd ada 2 template biaya tetap: Retribusi (10.000) dan Sewa tempat (50.000)
      expect(addedCosts.length, 2);
      expect(addedCosts.any((e) => e.description == 'Retribusi' && e.amount == 10000), isTrue);
      expect(addedCosts.any((e) => e.description == 'Sewa tempat' && e.amount == 50000), isTrue);

      final sessionExpenses = await repo.fetchExpensesBySession('new-session-99');
      expect(sessionExpenses.length, 2);
    });

    test('FR-10 notifikasi hanya dipicu 1x per sesi (flag _notifiedSessions)', () async {
      final repo = PengeluaranRepository();
      // session-cfd-01 awal total: 160.000, limit: 200.000
      expect(repo.isSessionNotified('session-cfd-01'), isFalse);

      // Tambah biaya 50.000 -> total 210.000 (melebihi limit)
      await repo.addExpense(
        sessionId: 'session-cfd-01',
        description: 'Beli Daging',
        amount: 50000,
      );
      expect(repo.isSessionNotified('session-cfd-01'), isTrue);

      // Tambah biaya lagi 30.000 -> flag tetap true dan tidak crash/spam
      await repo.addExpense(
        sessionId: 'session-cfd-01',
        description: 'Beli Bumbu',
        amount: 30000,
      );
      expect(repo.isSessionNotified('session-cfd-01'), isTrue);
    });

    test('updateExpense dan setLimit memicu pengecekan batas dan notifikasi', () async {
      final repo = PengeluaranRepository();
      // session-cfd-01 limit awal: 200.000, total: 160.000
      expect(repo.isSessionNotified('session-cfd-01'), isFalse);

      // Turunkan limit menjadi 150.000 (di bawah total 160.000)
      await repo.setLimit(sessionId: 'session-cfd-01', limitAmount: 150000);
      expect(repo.isSessionNotified('session-cfd-01'), isTrue);

      // Reset repo untuk tes updateExpense
      repo.resetForTesting();
      expect(repo.isSessionNotified('session-cfd-01'), isFalse);

      // Update exp-01 (Gas LPG dari 40.000 menjadi 90.000 -> total jadi 210.000)
      await repo.updateExpense(
        id: 'exp-01',
        description: 'Gas LPG 12kg',
        amount: 90000,
        category: ExpenseCategory.operasional,
      );
      expect(repo.isSessionNotified('session-cfd-01'), isTrue);
    });
  });

  testWidgets('Workflow Tambah Pengeluaran end-to-end', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LapakPindahApp());
    await tester.pumpAndSettle();

    // 1. Login akun demo
    await tester.enterText(find.byType(TextFormField).at(0), '081234567890');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 2. Buka tab Biaya (Modul 2)
    await tester.tap(find.widgetWithText(InkWell, 'Biaya'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Periksa layar Daftar Pengeluaran termuat (Frame 1)
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.textContaining('CFD Jam Gadang'), findsOneWidget);
    expect(find.text('Gas LPG'), findsOneWidget);

    // 3. Tekan FAB (+) → buka form Tambah Pengeluaran (Frame 2)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Tambah pengeluaran'), findsOneWidget);

    // 4. Coba simpan saat kosong (tombol nonaktif / disabled)
    // LapakPrimaryButton menggunakan onPressed = null saat canSave false
    final saveButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(TambahPengeluaranScreen),
        matching: find.byType(FilledButton),
      ),
    );
    expect(saveButton.onPressed, isNull);

    // 5. Isi form (Keterangan & Nominal)
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contoh: beli es batu'),
      'Minyak goreng 2 liter',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '0'),
      '30000',
    );
    await tester.pump();

    // Tombol simpan sekarang aktif
    final activeSaveButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(TambahPengeluaranScreen),
        matching: find.byType(FilledButton),
      ),
    );
    expect(activeSaveButton.onPressed, isNotNull);

    // 6. Simpan pengeluaran
    await tester.tap(find.text('Simpan pengeluaran'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 7. Result: kembali ke daftar, item baru ada di list & SnackBar tampil (Frame 10)
    expect(find.text('Tambah pengeluaran'), findsNothing);
    expect(find.text('Pengeluaran ditambahkan!'), findsOneWidget);
    expect(find.text('Minyak goreng 2 liter'), findsOneWidget);
  });
}
