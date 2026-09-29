import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/widgets/action_card_button.dart';
import 'package:lapakpindah/modules/auth/auth_view_model.dart';
import 'package:lapakpindah/modules/dashboard/dashboard_view_model.dart';
import 'package:lapakpindah/data/item_repository.dart';
import 'package:lapakpindah/models/item.dart';
import 'package:lapakpindah/routes/app_routes.dart';
import 'package:lapakpindah/widgets/state_views.dart';

/// Screen beranda/dashboard LapakPindah.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab});

  /// Callback untuk navigasi ke tab lain dari action buttons.
  final void Function(int index)? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum ViewStatus { loading, success, error }

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadTodaySummary();
      _loadItems();
    });
  }

  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }

    try {
      final items = await _repository.fetchItems();
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
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          _buildGreetingHeader(),
          const SizedBox(height: AppSpacing.md),
          _buildRevenueSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildLapakSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildActionButtons(),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
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
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Icon(
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


  Widget _buildLapakSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lapak Saya', style: AppTextStyles.heading2()),
            Text(
              'Pilih untuk melihat detail',
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 150,
          child: _buildLapakContent(),
        ),
      ],
    );
  }

  Widget _buildLapakContent() {
    switch (_status) {
      case ViewStatus.loading:
        return const LoadingView(message: 'Memuat daftar lapak...');

      case ViewStatus.error:
        return ErrorView(
          message: _errorMessage,
          onRetry: _loadItems,
        );

      case ViewStatus.success:
        if (_items.isEmpty) {
          return const EmptyView(
            message: 'Belum ada data lapak.',
            icon: Icons.storefront_outlined,
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final item = _items[index];

            return SizedBox(
              width: 245,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                  side: const BorderSide(color: AppColors.inputBorder),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: item,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.storefront,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall(),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Lihat detail',
                              style: AppTextStyles.labelMedium(
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
    }
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
