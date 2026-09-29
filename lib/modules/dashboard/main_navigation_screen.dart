import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/modules/dashboard/home_screen.dart';

/// Screen utama dengan bottom navigation — 4 tab.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content area with bottom padding for nav bar
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.navBarHeight + 14),
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(onNavigateToTab: _onTabSelected),
                _buildPlaceholderTab('Kasir POS', Icons.point_of_sale),
                _buildPlaceholderTab('Catat Biaya', Icons.receipt_long),
                _buildPlaceholderTab('Rapor Profit', Icons.analytics_outlined),
              ],
            ),
          ),

          // Custom bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  /// Placeholder tab untuk modul yang belum diimplementasi.
  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.storefront, color: AppColors.primaryDark, size: 19),
            const SizedBox(width: AppSpacing.sm),
            Text('LapakPindah', style: AppTextStyles.titleLarge()),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.inputBorder),
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
            Text(
              'Segera hadir',
              style: AppTextStyles.bodyMedium(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      _NavItemData(icon: Icons.storefront, label: 'Lapak'),
      _NavItemData(icon: Icons.point_of_sale, label: 'Kasir POS'),
      _NavItemData(icon: Icons.receipt_long, label: 'Catat Biaya'),
      _NavItemData(icon: Icons.analytics_outlined, label: 'Rapor Profit'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          top: BorderSide(color: AppColors.inputBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = _currentIndex == index;
            return _buildNavItem(
              icon: items[index].icon,
              label: items[index].label,
              isActive: isActive,
              onTap: () => _onTabSelected(index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                color:
                    isActive ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
