import 'package:flutter/material.dart';

import '../../models/profit_series.dart';
import '../../view_models/evaluation_view_model.dart';
import 'profit_trend_chart.dart';

/// Isi visual kartu tren laba; pilihan periode mengubah data dan grouping.
class TrendCardContent extends StatelessWidget {
  const TrendCardContent({super.key, required this.vm});
  final EvaluationViewModel vm;

  static const _ink = Color(0xFF1E293B);
  static const _muted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tren Laba',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  Text(switch (vm.period) {
                    EvaluationPeriod.week => '7 hari terakhir',
                    EvaluationPeriod.month => 'Bulan ini',
                    EvaluationPeriod.all => 'Semua riwayat',
                  }, style: const TextStyle(fontSize: 10, color: _muted)),
                ],
              ),
            ),
            PopupMenuButton<EvaluationPeriod>(
              initialValue: vm.period,
              onSelected: vm.selectPeriod,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: EvaluationPeriod.week,
                  child: Text('Minggu Ini'),
                ),
                PopupMenuItem(
                  value: EvaluationPeriod.month,
                  child: Text('Bulan Ini'),
                ),
                PopupMenuItem(
                  value: EvaluationPeriod.all,
                  child: Text('Semua Riwayat'),
                ),
              ],
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      switch (vm.period) {
                        EvaluationPeriod.week => 'Minggu Ini',
                        EvaluationPeriod.month => 'Bulan Ini',
                        EvaluationPeriod.all => 'Semua',
                      },
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 12,
                      color: Color(0xFF4B5563),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vm.points.isEmpty)
          const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'Belum ada sesi selesai pada periode ini.',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ),
          )
        else
          ProfitTrendChart(points: vm.points, grouping: vm.grouping),
      ],
    ),
  );
}
