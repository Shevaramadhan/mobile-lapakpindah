import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/models/dashboard_summary.dart';
import 'package:lapakpindah/modules/auth/auth_view_model.dart';
import 'package:lapakpindah/modules/dashboard/dashboard_view_model.dart';
import 'package:lapakpindah/modules/dashboard/widgets/session_map.dart';
import 'package:lapakpindah/routes/app_routes.dart';
import 'package:lapakpindah/widgets/state_views.dart';

// ── Helper format ──

/// 400000 → "Rp 400.000"
String _formatRupiah(double amount) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);

/// DateTime → "06.10"
String _formatTime(DateTime? time) =>
    time == null ? '-' : DateFormat('HH.mm').format(time);

/// Screen Beranda (dashboard) LapakPindah.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab});

  /// Callback pindah tab di bottom navigation (dipakai kartu modul).
  /// Index: 1 Lokasi, 2 Biaya, 3 Penjualan, 4 Evaluasi.
  final void Function(int index)? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// true = data dashboard sengaja dibuat gagal (untuk menguji ErrorView).
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    // Muat data setelah frame pertama agar aman memakai context.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() {
    return context
        .read<DashboardViewModel>()
        .loadDashboard(simulateError: _simulateError);
  }

  // ── Aksi: menu profil ──
  void _onProfileMenuSelected(String value) {
    if (value == 'error') {
      setState(() => _simulateError = !_simulateError);
      _loadDashboard();
    } else if (value == 'logout') {
      _logout();
    }
  }

  // ── Aksi: keluar akun ──
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<AuthViewModel>().logout();
    if (!mounted) return;

    // Kembali ke Login dan hapus semua layar sebelumnya dari stack
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  // ── Aksi: tutup lapak ──
  Future<void> _closeSession(String locationName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tutup lapak?'),
        content: Text('Sesi jualan di $locationName akan diakhiri.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Tutup lapak'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<DashboardViewModel>().closeSession();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lapak ditutup. Sesi jualan selesai.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: _buildAppBar(),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          // Pilih tampilan sesuai status: loading / error / success
          return switch (vm.status) {
            ViewStatus.loading =>
              const LoadingView(message: 'Memuat beranda...'),
            ViewStatus.error =>
              ErrorView(message: vm.errorMessage, onRetry: _loadDashboard),
            ViewStatus.success => _buildContent(vm.summary),
          };
        },
      ),
    );
  }

  // ── AppBar: logo + nama aplikasi + tombol profil ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceCard,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.lg,
      title: Row(
        children: [
          const Icon(Icons.storefront, color: AppColors.primaryDark, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text('LapakPindah', style: AppTextStyles.titleLarge()),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Profil',
          onSelected: _onProfileMenuSelected,
          itemBuilder: (context) => [
            CheckedPopupMenuItem(
              value: 'error',
              checked: _simulateError,
              child: const Text('Simulasikan error'),
            ),
            const PopupMenuItem(value: 'logout', child: Text('Keluar')),
          ],
          // Avatar bulat bergaris seperti desain
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceChip,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.inputBorder),
      ),
    );
  }

  // ── Isi beranda (status success) ──
  Widget _buildContent(DashboardSummary summary) {
    final userName = context.watch<AuthViewModel>().userName ?? 'Pengguna';

    return RefreshIndicator(
      // Tarik ke bawah untuk memuat ulang
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _GreetingHeader(userName: userName, summary: summary),
          const SizedBox(height: AppSpacing.md),
          summary.isSessionActive
              ? _ActiveSessionCard(
                  summary: summary,
                  onClose: () => _closeSession(summary.locationName ?? 'lokasi ini'),
                )
              : _ClosedSessionCard(
                  onOpen: () => widget.onNavigateToTab?.call(1),
                ),
          // Estimasi bersih hanya relevan saat ada sesi aktif
          if (summary.isSessionActive) ...[
            const SizedBox(height: AppSpacing.md),
            _NetEstimateCard(summary: summary),
          ],
          const SizedBox(height: AppSpacing.md),
          _ModuleGrid(onNavigateToTab: widget.onNavigateToTab),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Widget bagian-bagian Beranda
// ════════════════════════════════════════════════════════════════════

/// Sapaan + status lapak (buka/tutup) + chip sesi.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.userName, required this.summary});

  final String userName;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final isActive = summary.isSessionActive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Teks sapaan & judul
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $userName', style: AppTextStyles.bodySmall()),
              const SizedBox(height: 2),
              Text(
                isActive ? 'Lapak sedang buka' : 'Lapak sedang tutup',
                style: AppTextStyles.heading2(),
              ),
            ],
          ),
        ),
        // Chip status sesi (titik hijau = aktif, abu = tidak ada sesi)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceChip,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: isActive ? AppColors.success : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isActive ? 'Sesi aktif' : 'Tidak ada sesi',
                style: AppTextStyles.labelMedium(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu dasar Beranda (M3: Card + ShapeBorder + elevation).
/// Latar putih, garis tepi, sudut membulat, bayangan tipis.
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.padding = EdgeInsets.zero});

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

/// Kartu sesi aktif: peta + nama lokasi + jam + tombol Tutup lapak.
class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard({required this.summary, required this.onClose});

  final DashboardSummary summary;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Peta lokasi (atau pengganti jika koordinat belum ada) ──
          SizedBox(
            height: 240,
            child: summary.hasCoordinate
                ? SessionMap(
                    latitude: summary.latitude!,
                    longitude: summary.longitude!,
                  )
                : Container(
                    color: AppColors.surfaceChip,
                    alignment: Alignment.center,
                    child: Text(
                      'Koordinat lokasi belum ditandai',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ),
          ),
          const Divider(height: 1, color: AppColors.inputBorder),

          // ── Nama lokasi, jam, tombol tutup ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.locationName ?? '-',
                        style: AppTextStyles.titleLarge(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buka ${_formatTime(summary.openTime)} · '
                        'rencana tutup ${_formatTime(summary.plannedCloseTime)}',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                  ),
                  child: Text(
                    'Tutup lapak',
                    style: AppTextStyles.labelMedium(color: AppColors.primaryDark),
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

/// Kartu saat tidak ada sesi aktif: ajakan membuka lapak.
class _ClosedSessionCard extends StatelessWidget {
  const _ClosedSessionCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.storefront_outlined, size: 48, color: AppColors.inputIcon),
          const SizedBox(height: AppSpacing.sm),
          Text('Belum ada sesi jualan', style: AppTextStyles.titleSmall()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Buka lapak di sebuah lokasi untuk mulai mencatat penjualan dan biaya.',
            style: AppTextStyles.bodySmall(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.store),
            label: const Text('Buka lapak'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu estimasi bersih: badge balik modal + nominal + penjualan/pengeluaran.
class _NetEstimateCard extends StatelessWidget {
  const _NetEstimateCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final isBreakEven = summary.isBreakEven;

    return _DashboardCard(
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
          Text(_formatRupiah(summary.netProfit), style: AppTextStyles.heading3()),
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
                const VerticalDivider(width: AppSpacing.lg, color: AppColors.inputBorder),
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

/// Satu kolom label + nominal (dipakai di kartu estimasi).
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
        Text(_formatRupiah(amount), style: AppTextStyles.titleSmall(color: color)),
      ],
    );
  }
}

/// Grid 2×2 kartu modul yang membuka tab masing-masing.
class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.onNavigateToTab});

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
    return _DashboardCard(
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
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
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
