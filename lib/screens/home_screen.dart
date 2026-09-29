import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/data/item_repository.dart';
import 'package:lapakpindah/models/item.dart';
import 'package:lapakpindah/routes/app_routes.dart';
import 'package:lapakpindah/widgets/state_views.dart';

// (1) status tampilan layar Home
enum ViewStatus { loading, success, error }

/// Layar daftar produk LapakPindah — menampilkan status loading, kosong, dan error.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (2) variabel state
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  final bool _simulateError = false; // ubah ke true untuk menguji error state

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }

    List<Item> data = <Item>[];
    String? error;

    try {
      data = await _repository.fetchItems(simulateError: _simulateError);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      // (4) indikator loading dimatikan di blok finally (selalu dijalankan).
      // Guard mounted agar aman bila layar sudah ditutup selama await,
      // tanpa memakai return di dalam finally.
      if (mounted) {
        setState(() {
          if (error != null) {
            _errorMessage = error;
            _status = ViewStatus.error;
          } else {
            _items = data;
            _status = ViewStatus.success;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
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
            Text('Produk Lapak', style: AppTextStyles.titleLarge()),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.inputBorder),
        ),
      ),
      body: _buildContent(), // (5) isi layar tergantung status
    );
  }

  // (6) memilih tampilan: loading / error / empty / daftar data
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(
        message: _errorMessage,
        onRetry: _loadItems,
      ),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(
        message: 'Belum ada produk.\nTambahkan produk untuk memulai.',
        icon: Icons.storefront_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) => _buildItemCard(_items[index]),
    );
  }

  /// Kartu produk kustom bergaya LapakPindah (dari Praktikum 1).
  Widget _buildItemCard(Item item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
            onTap: () {
              // (7) kirim item ke layar Detail — diisi di Langkah 7
              Navigator.pushNamed(context, AppRoutes.detail, arguments: item);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Icon produk
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceChip,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.borderRadius,
                      ),
                    ),
                    child: const Icon(
                      Icons.fastfood_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Nama & subtitle produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.titleSmall(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: AppTextStyles.bodySmall(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Panah chevron
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
