import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/modules/dashboard/home_screen.dart';

/// Screen utama setelah login: bottom navigation 5 tab.
///
/// Tab 0 = Beranda (dashboard). Tab 1–4 = modul tiap anggota,
/// sementara berisi placeholder sampai modulnya dikerjakan.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // ── Daftar tab (urutan = index) ──
  static const _tabs = [
    _NavItemData(icon: Icons.home_outlined, label: 'Beranda'),
    _NavItemData(icon: Icons.location_on_outlined, label: 'Lokasi'),
    _NavItemData(icon: Icons.receipt_long_outlined, label: 'Biaya'),
    _NavItemData(icon: Icons.shopping_bag_outlined, label: 'Penjualan'),
    _NavItemData(icon: Icons.bar_chart, label: 'Evaluasi'),
  ];

  /// Tab yang sedang aktif.
  int _currentIndex = 0;

  void _onTabSelected(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: semua tab tetap hidup, sehingga state tiap tab
      // (misal posisi scroll) tidak hilang saat berpindah tab.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateToTab: _onTabSelected),
          const _PlaceholderTab(
            title: 'Lokasi & Sesi',
            module: 'Modul 1',
            icon: Icons.location_on_outlined,
          ),
          const _PlaceholderTab(
            title: 'Pengeluaran',
            module: 'Modul 2',
            icon: Icons.receipt_long_outlined,
          ),
          const _PlaceholderTab(
            title: 'Penjualan',
            module: 'Modul 3',
            icon: Icons.shopping_bag_outlined,
          ),
          const _PlaceholderTab(
            title: 'Evaluasi Lokasi',
            module: 'Modul 4',
            icon: Icons.bar_chart,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── Bottom navigation kustom (item aktif berlatar oranye) ──
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Expanded(
                child: _NavItem(
                  data: _tabs[i],
                  isActive: _currentIndex == i,
                  onTap: () => _onTabSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Satu item bottom navigation: ikon + label.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.onPrimary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
          child: ConstrainedBox(
            // Area sentuh minimal 48dp (NFR-03)
            constraints: const BoxConstraints(minHeight: 52),
            child: Column(
              // min: tinggi bottom nav mengikuti isi. Tanpa ini, Column
              // memenuhi seluruh layar dan isi Beranda tertutup.
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data.icon, size: 20, color: color),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: AppTextStyles.labelSmall(color: color),
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

/// Isi sementara untuk tab modul yang belum dikerjakan.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.module,
    required this.icon,
  });

  final String title;
  final String module;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        automaticallyImplyLeading: false,
        title: Text(title, style: AppTextStyles.titleLarge()),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.inputBorder),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.inputBorder),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.heading2()),
            const SizedBox(height: AppSpacing.sm),
            Text('Segera hadir — $module', style: AppTextStyles.bodyMedium()),
          ],
        ),
      ),
    );
  }
}

/// Data satu tab: ikon + label.
class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
