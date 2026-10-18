import '../models/profit_series.dart';

/// Sumber data sesi sementara. Data contoh hanya saat LAPAK_DEMO=true.
class EvaluationRepository {
  EvaluationRepository({
    List<SessionProfit> initialSessions = const [],
    bool demo = false,
    DateTime Function()? now,
  }) : _sessions = [
         ...initialSessions,
         if (demo) ..._demoSessions((now ?? DateTime.now)()),
       ];
  final List<SessionProfit> _sessions;

  /// Berikan daftar sesi tanpa membolehkan ViewModel mengubah sumber aslinya.
  Future<List<SessionProfit>> fetchSessions() async =>
      List.unmodifiable(_sessions);

  /// Buat sesi contoh hanya untuk demonstrasi, bukan transaksi riil pengguna.
  static List<SessionProfit> _demoSessions(DateTime today) {
    const profits = [350000, 430000, 390000, 530000, 470000, 590000, 390000];
    return [
      for (var index = 0; index < profits.length; index++)
        SessionProfit(
          id: 'contoh-$index',
          locationId: 'demo-cfd',
          date: DateTime(today.year, today.month, today.day - 6 + index),
          revenue: profits[index] + 25000,
          expense: 25000,
        ),
      for (var index = 0; index < 7; index++)
        SessionProfit(
          id: 'kantor-$index',
          locationId: 'demo-office',
          date: DateTime(today.year, today.month, today.day - 6 + index),
          revenue: 405000,
          expense: 25000,
        ),
    ];
  }
}
