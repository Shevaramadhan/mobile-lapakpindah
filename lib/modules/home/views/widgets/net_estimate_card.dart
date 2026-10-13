import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/modules/home/models/dashboard_summary.dart';
import 'package:lapakpindah/modules/home/views/widgets/dashboard_card.dart';

/// Kartu estimasi bersih: badge balik modal + nominal + penjualan/pengeluaran.
class NetEstimateCard extends StatelessWidget {
  const NetEstimateCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    // Gaya teks & warna dari tema (app_theme.dart)
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isBreakEven = summary.isBreakEven;

    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Judul + badge balik modal (FR-14) ──
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estimasi Bersih Hari Ini',
                  style: textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  // Hijau tidak ada di ColorScheme → dari AppColors
                  color: isBreakEven
                      ? AppColors.successContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  isBreakEven ? 'Sudah balik modal' : 'Belum balik modal',
                  style: textTheme.labelSmall?.copyWith(
                    color: isBreakEven ? AppColors.success : colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Nominal estimasi bersih ──
          Text(
            formatRupiah(summary.netProfit),
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(), // warna & tebal dari dividerTheme
          const SizedBox(height: AppSpacing.sm),

          // ── Penjualan | Pengeluaran ──
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _AmountColumn(
                    label: 'Penjualan',
                    amount: summary.totalSales,
                    color: AppColors.success,
                  ),
                ),
                const VerticalDivider(width: AppSpacing.lg),
                Expanded(
                  child: _AmountColumn(
                    label: 'Pengeluaran',
                    amount: summary.totalExpense,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu kolom label + nominal (hanya dipakai di kartu estimasi).
class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          formatRupiah(amount),
          style: textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
