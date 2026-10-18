/// Cara menggabungkan sesi pada grafik: per hari atau per minggu.
enum TrendGrouping { daily, weekly }

/// Rentang sesi yang ditampilkan; targetnya tetap per sesi.
enum EvaluationPeriod { week, month, all }

/// Data satu sesi untuk menghitung laba; sementara berasal dari repository demo.
class SessionProfit {
  const SessionProfit({
    required this.id,
    required this.locationId,
    required this.date,
    required this.revenue,
    required this.expense,
  });
  final String id;
  final String locationId;
  final DateTime date;
  final int revenue;
  final int expense;

  /// Laba sesi = pemasukan dikurangi pengeluaran.
  int get profit => revenue - expense;
}

/// Satu titik pada grafik: tanggal kelompok dan total labanya.
class ProfitPoint {
  const ProfitPoint(this.date, this.profit);
  final DateTime date;
  final int profit;
}

/// Hari tanpa sesi tidak dibuat menjadi laba nol. Minggu dimulai Senin.
List<ProfitPoint> groupProfits(
  List<SessionProfit> sessions,
  TrendGrouping grouping,
) {
  final totals = <DateTime, int>{};
  for (final session in sessions) {
    // Buang komponen jam agar sesi di hari yang sama masuk satu titik.
    var date = DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
    );
    if (grouping == TrendGrouping.weekly) {
      // Geser tanggal ke Senin minggu yang sama sebagai kunci kelompok.
      date = DateTime(date.year, date.month, date.day - date.weekday + 1);
    }
    // Akumulasikan laba semua sesi pada hari/minggu tersebut.
    totals[date] = (totals[date] ?? 0) + session.profit;
  }
  // Urutkan tanggal supaya garis grafik berjalan dari lama ke baru.
  final dates = totals.keys.toList()..sort();
  return [for (final date in dates) ProfitPoint(date, totals[date]!)];
}
