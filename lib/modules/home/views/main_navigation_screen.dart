import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/modules/home/views/home_screen.dart';
import 'package:lapakpindah/modules/sesi_lokasi/views/location_list_screen.dart';
import 'package:lapakpindah/modules/evaluasi_lokasi/views/evaluation_screen.dart';

/// Screen utama setelah login: bottom navigation 5 tab.
///
/// Tab 0 = Beranda (dashboard). Tab 1 = Lokasi (Modul 1).
/// Tab 2–3 sementara berisi placeholder. Tab 4 = Evaluasi (FR-17/FR-18).
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
          const LocationListScreen(), // Modul 1: Daftar Lokasi
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
          EvaluationScreen(isActive: _currentIndex == 4),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── Bottom navigation kustom (item aktif berlatar oranye) ──
  // Ukuran dari Figma: tinggi 64, jarak tepi 6.
  Widget _buildBottomNavBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navBarHeight,
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
    // Warna dari tema: aktif = primary/onPrimary, tidak aktif = abu
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final radius = BorderRadius.circular(6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: isActive ? colorScheme.primary : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            // Area sentuh minimal 48dp (NFR-03)
            constraints: const BoxConstraints(minHeight: 48),
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
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: color),
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
    final textTheme = Theme.of(context).textTheme;

    // Gaya AppBar & latar layar dari tema
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('Segera hadir — $module', style: textTheme.bodyMedium),
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
