import 'package:flutter/material.dart';

/// Kartu dasar Beranda (M3: Card + ShapeBorder + elevation).
/// Latar putih, garis tepi, sudut membulat, dan bayangan tipis
/// semuanya diatur cardTheme di app_theme.dart.
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
      child: Padding(padding: padding, child: child),
    );
  }
}
