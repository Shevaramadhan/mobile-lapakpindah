import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';

/// Kartu dasar Beranda (M3: Card + ShapeBorder + elevation).
/// Latar putih, garis tepi, sudut membulat, bayangan tipis.
/// Dipakai ulang oleh semua kartu di Beranda.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1, // bayangan tipis (hierarki visual)
      color: AppColors.surfaceCard,
      surfaceTintColor: Colors.transparent, // jaga warna tetap putih di Material 3
      clipBehavior: Clip.antiAlias, // agar peta ikut terpotong di sudut kartu
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
