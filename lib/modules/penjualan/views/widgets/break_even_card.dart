import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';

/// Ringkasan sesi: total penjualan, pengeluaran, dan selisihnya (FR-14).
/// Widget presentasi murni; angka dihitung di SaleViewModel.
class BreakEvenCard extends StatelessWidget {
  final int totalSales;
  final int totalExpense;
  final int balance;

  const BreakEvenCard({
    super.key,
    required this.totalSales,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = balance >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;
    final statusText = isProfit
        ? (balance == 0
            ? 'Balik modal'
            : 'Untung ${formatRupiah(balance)}')
        : 'Kurang ${formatRupiah(-balance)} untuk balik modal';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Sesi', style: AppTextStyles.titleSmall()),
          const SizedBox(height: AppSpacing.md),
          _row('Total penjualan sesi', formatRupiah(totalSales)),
          const SizedBox(height: AppSpacing.xs),
          _row('Total pengeluaran sesi', formatRupiah(totalExpense)),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(statusText, style: AppTextStyles.titleSmall(color: color)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pengeluaran masih data demo, menunggu terhubung ke Modul 2.',
            style: AppTextStyles.bodySmall(),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodySmall())),
        Text(value, style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)),
      ],
    );
  }
}
