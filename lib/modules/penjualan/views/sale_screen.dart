
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/core/widgets/custom_button.dart';
import 'package:lapakpindah/core/widgets/custom_text_field.dart';
import 'package:lapakpindah/modules/penjualan/models/product.dart';
import 'package:lapakpindah/modules/penjualan/view_models/sale_view_model.dart';
import 'package:lapakpindah/modules/penjualan/views/sale_history_screen.dart';
import 'package:lapakpindah/modules/penjualan/views/product_catalog_screen.dart';
import 'package:lapakpindah/modules/penjualan/views/product_form_screen.dart';
import 'package:lapakpindah/modules/penjualan/views/widgets/break_even_card.dart';

/// View untuk satu workflow pencatatan penjualan.
/// State bisnis dan penyimpanan ditangani oleh SaleViewModel.
class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onQuantityChanged);
  }

  void _onQuantityChanged() {
    context.read<SaleViewModel>().updateQuantity(_quantityController.text);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // Menunggu hasil penyimpanan dari ViewModel.
  Future<void> _saveSale() async {
    final vm = context.read<SaleViewModel>();

    // Mencegah pemanggilan ulang ketika sedang menyimpan.
    if (vm.isSaving) return;

    final saved = await vm.saveSale();

    if (!mounted) return;

    final message = saved ? vm.successMessage : vm.errorMessage;

    if (saved) {
      _quantityController.clear();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'Proses penjualan tidak dapat diselesaikan.',
        ),
        backgroundColor: saved ? AppColors.success : AppColors.error,
      ),
    );
  }

  // Membuka riwayat dengan instance SaleViewModel yang sama.
  void _openSaleHistory() {
    context.read<SaleViewModel>().loadHistory();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SaleHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surfaceCard,
        title: Text(
          'Pencatatan Penjualan',
          style: AppTextStyles.titleLarge(),
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat Penjualan',
            icon: const Icon(Icons.history),
            onPressed: _openSaleHistory,
          ),
        ],
      ),
      body: Consumer<SaleViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Catat produk yang terjual pada sesi berjualan.',
                  style: AppTextStyles.bodyMedium(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Informasi sesi dan lokasi dummy.
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Berjualan',
                        style: AppTextStyles.titleSmall(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              SaleViewModel.demoLocationName,
                              style: AppTextStyles.bodyMedium(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sesi #${SaleViewModel.demoSessionId} · Data sementara',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Form input produk dan jumlah.
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk terjual',
                        style: AppTextStyles.labelMedium(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<int>(
                        key: ValueKey(vm.selectedProduct?.id),
                        initialValue: vm.selectedProduct?.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Pilih produk',
                          border: OutlineInputBorder(),
                        ),
                        items: vm.products.map((Product product) {
                          return DropdownMenuItem<int>(
                            value: product.id,
                            child: Text(
                              '${product.name} — '
                              '${formatRupiah(vm.priceFor(product))}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: vm.isSaving
                            ? null
                            : (id) {
                                Product? selected;

                                for (final product in vm.products) {
                                  if (product.id == id) {
                                    selected = product;
                                    break;
                                  }
                                }

                                vm.selectProduct(selected);
                              },
                      ),
                      if (vm.selectedProduct != null &&
                          vm.specialPriceFor(vm.selectedProduct!.id) != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            'Memakai harga khusus ${SaleViewModel.demoLocationName}',
                            style: AppTextStyles.bodySmall(color: AppColors.success),
                          ),
                        ),
                      Row(children:[TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ProductFormScreen())),icon:const Icon(Icons.add_circle_outline),label:const Text('Input Produk')),const SizedBox(width:8),TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ProductCatalogScreen())),icon:const Icon(Icons.inventory_2_outlined),label:const Text('Kelola Produk'))]),
                      const SizedBox(height: AppSpacing.lg),
                      LapakTextField(
                        label: 'Jumlah terjual',
                        hintText: 'Masukkan jumlah produk',
                        controller: _quantityController,
                        prefixIcon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Total selalu berasal dari getter ViewModel.
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Penjualan',
                        style: AppTextStyles.bodySmall(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatRupiah(vm.total),
                        style: AppTextStyles.heading2(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Ringkasan sesi: total penjualan, pengeluaran, selisih (FR-14).
                BreakEvenCard(
                  totalSales: vm.totalSales,
                  totalExpense: vm.sessionExpense,
                  balance: vm.balance,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Loading tampil selama proses penyimpanan.
                if (vm.isSaving)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // Tombol tidak dapat diproses berulang saat loading.
                LapakPrimaryButton(
                  label: vm.isSaving
                      ? 'Menyimpan...'
                      : 'Simpan Penjualan',
                  icon: Icons.save_outlined,
                  onPressed: vm.isSaving ? null : _saveSale,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadiusCard,
        ),
      ),
      child: child,
    );
  }
}
