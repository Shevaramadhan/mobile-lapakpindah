import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/core/widgets/state_views.dart';
import 'package:lapakpindah/modules/auth/view_models/auth_view_model.dart';
import 'package:lapakpindah/modules/home/models/dashboard_summary.dart';
import 'package:lapakpindah/modules/home/view_models/home_view_model.dart';
import 'package:lapakpindah/modules/home/views/widgets/greeting_header.dart';
import 'package:lapakpindah/modules/home/views/widgets/module_grid.dart';
import 'package:lapakpindah/modules/home/views/widgets/net_estimate_card.dart';
import 'package:lapakpindah/modules/home/views/widgets/session_card.dart';
import 'package:lapakpindah/routes/app_routes.dart';

/// Screen Beranda LapakPindah (View pada MVVM).
///
/// File ini hanya mengatur state layar, aksi pengguna, dan susunan bagian.
/// Tampilan tiap bagian ada di folder `widgets/`.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab});

  /// Callback pindah tab di bottom navigation (dipakai kartu modul).
  /// Index: 1 Lokasi, 2 Biaya, 3 Penjualan, 4 Evaluasi.
  final void Function(int index)? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// true = data Beranda sengaja dibuat gagal (untuk menguji ErrorView).
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    // Muat data setelah frame pertama agar aman memakai context.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() {
    return context
        .read<HomeViewModel>()
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

  // ── Dialog konfirmasi (dipakai ulang oleh Keluar & Tutup lapak) ──

  /// Menampilkan dialog Ya/Batal. Mengembalikan true jika pengguna
  /// menekan tombol [confirmLabel]. Dialog mengembalikan nilai lewat
  /// Navigator.pop(context, hasil) (M4: Returning Data).
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    // null = dialog ditutup tanpa memilih (misal ketuk di luar dialog)
    return result ?? false;
  }

  // ── Aksi: keluar akun ──
  Future<void> _logout() async {
    final confirmed = await _confirm(
      title: 'Keluar',
      message: 'Yakin ingin keluar dari akun ini?',
      confirmLabel: 'Keluar',
    );
    if (!confirmed || !mounted) return;

    await context.read<AuthViewModel>().logout();
    if (!mounted) return;

    // Kembali ke Login dan hapus semua layar sebelumnya dari stack
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  // ── Aksi: tutup lapak ──
  Future<void> _closeSession(String locationName) async {
    final confirmed = await _confirm(
      title: 'Tutup lapak?',
      message: 'Sesi jualan di $locationName akan diakhiri.',
      confirmLabel: 'Tutup lapak',
    );
    if (!confirmed || !mounted) return;

    await context.read<HomeViewModel>().closeSession();
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
      body: Consumer<HomeViewModel>(
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

  // ── Isi Beranda (status success): susunan bagian dari folder widgets/ ──
  Widget _buildContent(DashboardSummary summary) {
    // Nama pengguna dari sesi login global (AuthViewModel)
    final userName = context.watch<AuthViewModel>().userName ?? 'Pengguna';

    return RefreshIndicator(
      // Tarik ke bawah untuk memuat ulang
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GreetingHeader(
            userName: userName,
            isSessionActive: summary.isSessionActive,
          ),
          const SizedBox(height: AppSpacing.md),
          summary.isSessionActive
              ? ActiveSessionCard(
                  summary: summary,
                  onClose: () =>
                      _closeSession(summary.locationName ?? 'lokasi ini'),
                )
              : ClosedSessionCard(
                  onOpen: () => widget.onNavigateToTab?.call(1),
                ),
          // Estimasi bersih hanya relevan saat ada sesi aktif
          if (summary.isSessionActive) ...[
            const SizedBox(height: AppSpacing.md),
            NetEstimateCard(summary: summary),
          ],
          const SizedBox(height: AppSpacing.md),
          ModuleGrid(onNavigateToTab: widget.onNavigateToTab),
        ],
      ),
    );
  }
}
