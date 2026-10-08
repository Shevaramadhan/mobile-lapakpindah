import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/modules/home/models/dashboard_summary.dart';
import 'package:lapakpindah/modules/home/views/widgets/dashboard_card.dart';

/// Kartu estimasi bersih: badge balik modal + nominal + penjualan/pengeluaran.
class NetEstimateCard extends StatelessWidget {
  const NetEstimateCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
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
                  style: AppTextStyles.bodyMedium(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (isBreakEven ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
                child: Text(
                  isBreakEven ? 'Sudah balik modal' : 'Belum balik modal',
                  style: AppTextStyles.labelSmall(
                    color: isBreakEven ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Nominal estimasi bersih ──
          Text(
            formatRupiah(summary.netProfit),
            style: AppTextStyles.heading3(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.inputBorder),
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
                const VerticalDivider(
                  width: AppSpacing.lg,
                  color: AppColors.inputBorder,
                ),
                Expanded(
                  child: _AmountColumn(
                    label: 'Pengeluaran',
                    amount: summary.totalExpense,
                    color: AppColors.error,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall()),
        const SizedBox(height: 2),
        Text(
          formatRupiah(amount),
          style: AppTextStyles.titleSmall(color: color),
        ),
      ],
    );
  }
}
