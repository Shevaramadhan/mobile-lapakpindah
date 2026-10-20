import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/modules/penjualan/models/product.dart';
import 'package:lapakpindah/modules/penjualan/models/sale.dart';
import 'package:lapakpindah/modules/penjualan/view_models/sale_view_model.dart';

/// Menampilkan transaksi yang tersimpan pada sesi demo, lengkap dengan
/// total penjualan sesi serta aksi ubah jumlah dan hapus (FR-12).
/// Data diperoleh dari SaleViewModel, bukan dibuat di View.
class SaleHistoryScreen extends StatelessWidget {
  const SaleHistoryScreen({super.key});

  Future<void> _editSale(BuildContext context, Sale sale) async {
    final newQuantity = await showDialog<int>(
      context: context,
      builder: (_) => _EditQuantityDialog(initialQuantity: sale.quantity),
    );
    if (newQuantity == null || !context.mounted) return;

    final vm = context.read<SaleViewModel>();
    final ok = vm.updateSaleQuantity(id: sale.id, quantity: newQuantity);
    _showMessage(
      context,
      ok ? vm.successMessage : vm.errorMessage,
      isSuccess: ok,
    );
  }

  Future<void> _deleteSale(BuildContext context, Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus catatan penjualan?'),
        content: const Text('Catatan ini akan dihapus dari total penjualan sesi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final vm = context.read<SaleViewModel>();
    final ok = vm.deleteSale(sale.id);
    _showMessage(
      context,
      ok ? vm.successMessage : vm.errorMessage,
      isSuccess: ok,
    );
  }

  void _showMessage(BuildContext context, String? message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Proses tidak dapat diselesaikan.'),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Riwayat Penjualan', style: AppTextStyles.titleLarge()),
      ),
      body: Consumer<SaleViewModel>(
        builder: (context, vm, _) {
          if (vm.historyStatus == ViewStatus.error) {
            return _messageState(
              icon: Icons.error_outline,
              title: 'Riwayat gagal dimuat',
              description: vm.errorMessage ?? 'Silakan coba lagi.',
              onRetry: () => context.read<SaleViewModel>().loadHistory(),
            );
          }

          if (vm.historyStatus == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sales = vm.sales.reversed.toList();
          if (sales.isEmpty) {
            return _messageState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada penjualan',
              description:
                  'Transaksi yang berhasil disimpan pada sesi ini akan muncul di sini.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'Lokasi: ${SaleViewModel.demoLocationName}',
                style: AppTextStyles.titleSmall(),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sesi #${SaleViewModel.demoSessionId} · ${sales.length} transaksi',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: AppSpacing.md),
              _totalCard(vm.totalSales),
              const SizedBox(height: AppSpacing.lg),
              for (final sale in sales)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _saleCard(context, sale, vm.allProducts),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _totalCard(int totalSales) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Total penjualan sesi', style: AppTextStyles.labelMedium()),
          ),
          Text(
            formatRupiah(totalSales),
            style: AppTextStyles.titleLarge(color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  Widget _saleCard(BuildContext context, Sale sale, List<Product> products) {
    String productName = 'Produk #${sale.productId}';
    for (final product in products) {
      if (product.id == sale.productId) {
        productName = product.name;
        break;
      }
    }

    final recordedTime =
        DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(sale.recordedAt);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(productName, style: AppTextStyles.titleSmall()),
              ),
              IconButton(
                tooltip: 'Ubah jumlah',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editSale(context, sale),
              ),
              IconButton(
                tooltip: 'Hapus catatan',
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _deleteSale(context, sale),
              ),
            ],
          ),
          Text(recordedTime, style: AppTextStyles.bodySmall()),
          const SizedBox(height: AppSpacing.md),
          _detailRow('Jumlah terjual', '${sale.quantity}'),
          const SizedBox(height: AppSpacing.xs),
          _detailRow('Harga satuan', formatRupiah(sale.unitPrice)),
          const Divider(height: AppSpacing.xl),
          _detailRow('Total', formatRupiah(sale.total), emphasize: true),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool emphasize = false}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodySmall())),
        Text(
          value,
          style: emphasize
              ? AppTextStyles.titleSmall(color: AppColors.primaryDark)
              : AppTextStyles.bodyMedium(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.primaryDark),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.titleLarge(), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: AppTextStyles.bodyMedium(), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog untuk mengubah jumlah terjual. Controller dikelola State
/// agar dibuang dengan benar saat dialog ditutup.
class _EditQuantityDialog extends StatefulWidget {
  final int initialQuantity;
  const _EditQuantityDialog({required this.initialQuantity});

  @override
  State<_EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<_EditQuantityDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final quantity = int.tryParse(_controller.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Jumlah harus bilangan bulat lebih dari 0');
      return;
    }
    Navigator.pop(context, quantity);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah jumlah terjual'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Jumlah terjual',
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
