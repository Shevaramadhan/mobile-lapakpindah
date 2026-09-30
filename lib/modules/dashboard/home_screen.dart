import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/widgets/action_card_button.dart';
import 'package:lapakpindah/modules/auth/auth_view_model.dart';
import 'package:lapakpindah/modules/dashboard/dashboard_view_model.dart';

import '../../routes/app_routes.dart'; // Buka komentar/tambahkan baris ini

import 'package:lapakpindah/models/lapak.dart';
import 'package:lapakpindah/data/lapak_repository.dart';
import 'package:lapakpindah/widgets/state_views.dart';

// (1) Status tampilan layar
enum ViewStatus { loading, success, error }

/// Screen beranda/dashboard LapakPindah.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab});

  /// Callback untuk navigasi ke tab lain dari action buttons.
  final void Function(int index)? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (2) Variabel State untuk Langkah 5
  final _repository = LapakRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Lapak> _items = [];
  String _errorMessage = '';
  bool _simulateError = false; // Untuk menguji ErrorView

  @override
  void initState() {
    super.initState();
    // Load data summary dashboard asli
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadTodaySummary();
    });
    
    // (3) Ambil data dummy lokasi saat layar pertama dibuka
    _loadItems();
  }

  // (4) Mengambil data + menangani error dengan try-catch
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }

    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);
      
      // Pemeriksaan mounted sebelum setState
      if (!mounted) return;

      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  /// Format angka ke Rupiah: 400000 → "Rp 400.000"
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: _buildAppBar(),
      // (5) Isi layar diganti menjadi pemanggilan _buildContent
      body: _buildContent(), 
    );
  }

  // (6) Memilih tampilan: loading / error / success
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat data lapak...'),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildDashboardWithList(),
    };
  }

  // Menggabungkan dashboard asli dengan list lokasi lapak
  Widget _buildDashboardWithList() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      children: [
        _buildGreetingHeader(),
        const SizedBox(height: AppSpacing.md),
        _buildRevenueSummaryCard(),
        const SizedBox(height: AppSpacing.md),
        _buildActionButtons(),
        const SizedBox(height: AppSpacing.lg),
        
        // Judul untuk Daftar Lokasi
        Text('Daftar Lokasi Jualan', style: AppTextStyles.heading2()),
        const SizedBox(height: AppSpacing.sm),
        
        // Menampilkan daftar data dummy
        _buildList(),
      ],
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada data lokasi lapak.');
    }
    
    return ListView.builder(
      shrinkWrap: true, // Wajib agar tidak error di dalam ListView utama
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          color: AppColors.surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront, color: AppColors.primaryDark),
            ),
            title: Text(item.title, style: AppTextStyles.titleSmall()),
            subtitle: Text(item.subtitle, style: AppTextStyles.bodySmall()),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.detail,
                arguments: item,
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceCard,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(
            Icons.storefront,
            color: AppColors.primaryDark,
            size: 19,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('LapakPindah', style: AppTextStyles.titleLarge()),
        ],
      ),
      actions: [
        // Menu untuk simulasi error (memenuhi syarat Langkah 5)
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (value) {
            if (value == 'error') {
              setState(() => _simulateError = !_simulateError);
              _loadItems();
            }
          },
          itemBuilder: (context) => [
            CheckedPopupMenuItem(
              value: 'error',
              checked: _simulateError,
              child: const Text('Simulasikan Error'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 21,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.inputBorder,
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Consumer2<DashboardViewModel, AuthViewModel>(
      builder: (context, dashVM, authVM, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dashVM.getGreeting(),
                    style: AppTextStyles.bodySmall(),
                  ),
                  Text(
                    authVM.userName ?? 'Pengguna',
                    style: AppTextStyles.heading2(),
                  ),
                ],
              ),
              // Location chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceChip,
                  border: Border.all(color: AppColors.inputBorder),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadius,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      dashVM.currentLocation ?? 'Belum set lokasi',
                      style: AppTextStyles.labelMedium(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueSummaryCard() {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowCard,
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendapatan Bersih Hari Ini',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceChip,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      vm.percentageChange >= 0
                          ? '+${vm.percentageChange.toStringAsFixed(0)}%'
                          : '${vm.percentageChange.toStringAsFixed(0)}%',
                      style: AppTextStyles.labelSmall(
                        color: vm.percentageChange >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),

              // Net income
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  _formatCurrency(vm.todayNetIncome),
                  style: AppTextStyles.heading3(),
                ),
              ),

              // Divider
              Container(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.inputBorder),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Total Omzet
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Omzet',
                              style: AppTextStyles.bodySmall(),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(vm.todayTotalRevenue),
                              style: AppTextStyles.titleSmall(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vertical divider
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        color: AppColors.inputBorder,
                      ),
                      // Pengeluaran
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengeluaran',
                                style: AppTextStyles.bodySmall(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatCurrency(vm.todayTotalExpense),
                                style: AppTextStyles.titleSmall(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        children: [
          ActionCardButton(
            title: 'Kasir POS',
            subtitle: 'Buka dan mulai transaksi',
            leadingIcon: Icons.point_of_sale,
            isPrimary: true,
            onTap: () => widget.onNavigateToTab?.call(1),
          ),
          const SizedBox(height: AppSpacing.sm),
          ActionCardButton(
            title: 'Catat Biaya & Nota',
            subtitle: 'Foto dan simpan bukti nota',
            leadingIcon: Icons.receipt_long,
            onTap: () => widget.onNavigateToTab?.call(2),
          ),
          const SizedBox(height: AppSpacing.sm),
          ActionCardButton(
            title: 'Rapor Profit',
            subtitle: 'Lihat evaluasi untung-rugi',
            leadingIcon: Icons.analytics_outlined,
            trailingIcon: Icons.chevron_right,
            onTap: () => widget.onNavigateToTab?.call(3),
          ),
        ],
      ),
    );
  }
}
