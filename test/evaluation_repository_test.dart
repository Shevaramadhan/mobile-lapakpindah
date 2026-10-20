import 'package:flutter_test/flutter_test.dart';
import 'package:lapakpindah/core/utils/validators.dart';
import 'package:lapakpindah/modules/sesi_lokasi/repositories/location_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/repositories/evaluation_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/repositories/profit_target_repository.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/models/profit_series.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/view_models/evaluation_view_model.dart';

void main() {
  test(
    'nominal di bawah Rp 100.000, pecahan, huruf dan terlalu besar ditolak',
    () {
      for (final input in [
        '',
        '0',
        '-100',
        '1.5',
        '50,5',
        'abc',
        '99.999',
        '1000000000000',
      ]) {
        expect(Validators.profitTarget(input), isNotNull, reason: input);
      }
      expect(Validators.profitTarget('100.000'), isNull);
      expect(Validators.parseRupiah('100.000'), 100000);
    },
  );

  test(
    'target di memori dapat dibuat, diubah, dihapus dan tetap unik per lokasi',
    () async {
      final locations = LocationRepository();
      final location = await locations.add(name: 'CFD');
      final targets = ProfitTargetRepository();
      await expectLater(targets.save(location.id, 99999), throwsArgumentError);
      final first = await targets.save(location.id, 100000);
      final edited = await targets.save(location.id, 150000);
      expect(edited.id, first.id);
      expect((await targets.fetchAll()).single.amount, 150000);
      expect(await locations.fetchAll(), hasLength(1));
      await targets.delete(first.id);
      expect(await targets.fetchAll(), isEmpty);
      expect(await locations.fetchAll(), hasLength(1));
      expect(await ProfitTargetRepository().fetchAll(), isEmpty);
    },
  );

  test(
    'rata-rata laba per sesi dan grafik memakai data contoh yang terpisah',
    () async {
      final location = await LocationRepository().add(name: 'Pasar');
      final sessions = [
        SessionProfit(
          id: 'a',
          locationId: location.id,
          date: DateTime(2026, 10, 12),
          revenue: 60000,
          expense: 20000,
        ),
        SessionProfit(
          id: 'b',
          locationId: location.id,
          date: DateTime(2026, 10, 12),
          revenue: 0,
          expense: 100000,
        ),
      ];
      final locations = LocationRepository(initialLocations: [location]);
      final vm = EvaluationViewModel(
        locationsRepository: locations,
        repository: EvaluationRepository(initialSessions: sessions),
        targetsRepository: ProfitTargetRepository(),
        now: () => DateTime(2026, 10, 13),
      );
      await vm.load();
      expect(vm.averageFor(location.id), -30000);
      expect(vm.points.single.profit, -60000);
      vm.dispose();
      expect(await EvaluationRepository().fetchSessions(), isEmpty);
    },
  );

  test('pengelompokan mingguan melintasi tahun dan sesi pada hari sama', () {
    SessionProfit session(String id, DateTime date, int profit) =>
        SessionProfit(
          id: id,
          locationId: 'l',
          date: date,
          revenue: profit,
          expense: 0,
        );
    final sessions = [
      session('a', DateTime(2025, 12, 31), 100),
      session('b', DateTime(2026, 1, 1), -50),
      session('c', DateTime(2026, 1, 5), 20),
      session('d', DateTime(2026, 1, 5), 30),
    ];
    final points = groupProfits(sessions, TrendGrouping.weekly);
    expect(points.map((p) => p.profit), [50, 50]);
    expect(points.first.date, DateTime(2025, 12, 29));
    expect(groupProfits(sessions, TrendGrouping.daily).last.profit, 50);
    expect(groupProfits([], TrendGrouping.daily), isEmpty);
  });

  test('pilihan periode otomatis menentukan pengelompokan grafik', () async {
    final location = await LocationRepository().add(name: 'Pasar');
    final vm = EvaluationViewModel(
      locationsRepository: LocationRepository(initialLocations: [location]),
      repository: EvaluationRepository(
        initialSessions: [
          SessionProfit(
            id: 'a',
            locationId: location.id,
            date: DateTime(2026, 10, 12),
            revenue: 120000,
            expense: 20000,
          ),
          SessionProfit(
            id: 'b',
            locationId: location.id,
            date: DateTime(2026, 10, 13),
            revenue: 150000,
            expense: 20000,
          ),
        ],
      ),
      targetsRepository: ProfitTargetRepository(),
      now: () => DateTime(2026, 10, 13),
    );
    await vm.load();
    expect(vm.grouping, TrendGrouping.daily);
    expect(vm.points, hasLength(2));
    vm.selectPeriod(EvaluationPeriod.month);
    expect(vm.grouping, TrendGrouping.weekly);
    expect(vm.points, hasLength(1));
    expect(vm.points.single.profit, 230000);
    vm.dispose();
  });
}
