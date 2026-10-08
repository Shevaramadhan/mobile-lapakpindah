import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/modules/home/views/widgets/dashboard_card.dart';

/// Grid 2×2 kartu modul yang membuka tab masing-masing.
class ModuleGrid extends StatelessWidget {
  const ModuleGrid({super.key, required this.onNavigateToTab});

  /// Dipanggil dengan index tab tujuan saat kartu diketuk.
  final void Function(int index)? onNavigateToTab;

  // Data kartu modul (list berisi objek _ModuleItem)
  static const List<_ModuleItem> _modules = [
    _ModuleItem(
      title: 'Lokasi & Sesi',
      subtitle: 'Tempat jualan & buka lapak',
      icon: Icons.location_on_outlined,
      tabIndex: 1,
    ),
    _ModuleItem(
      title: 'Pengeluaran',
      subtitle: 'Catat biaya & foto nota',
      icon: Icons.receipt_long_outlined,
      tabIndex: 2,
    ),
    _ModuleItem(
      title: 'Penjualan',
      subtitle: 'Catat produk terjual',
      icon: Icons.shopping_bag_outlined,
      tabIndex: 3,
    ),
    _ModuleItem(
      title: 'Evaluasi Lokasi',
      subtitle: 'Peringkat & tren laba',
      icon: Icons.bar_chart,
      tabIndex: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // M3: GridView.count — grid 2 kolom
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true, // tinggi grid mengikuti isi (berada di dalam ListView)
      physics: const NeverScrollableScrollPhysics(), // scroll ikut ListView induk
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.15, // lebar : tinggi kartu
      children: [
        for (final module in _modules)
          _ModuleCard(
            item: module,
            onTap: () => onNavigateToTab?.call(module.tabIndex),
          ),
      ],
    );
  }
}

/// Data satu kartu modul (M2: class + constructor).
class _ModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;

  /// Index tab tujuan di bottom navigation.
  final int tabIndex;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tabIndex,
  });
}

/// Satu kartu modul: ikon dalam kotak, judul, keterangan.
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.item, required this.onTap});

  final _ModuleItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon dalam kotak oranye muda
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.borderRadiusCard),
                  ),
                  child: Icon(item.icon, color: AppColors.primaryDark, size: 22),
                ),
                // Spacer: dorong judul ke bawah kartu (tinggi kartu tetap dari GridView)
                const Spacer(),
                // maxLines 1: judul tidak turun 2 baris → tidak overflow
                Text(
                  item.title,
                  style: AppTextStyles.titleSmall(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.subtitle,
                  style: AppTextStyles.bodySmall(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
