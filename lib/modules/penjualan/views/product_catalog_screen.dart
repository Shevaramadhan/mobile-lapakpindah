import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/modules/penjualan/models/product.dart';
import 'package:lapakpindah/modules/penjualan/view_models/sale_view_model.dart';
import 'package:lapakpindah/modules/penjualan/views/product_form_screen.dart';
import 'package:lapakpindah/modules/penjualan/views/widgets/product_card.dart';

/// Katalog Produk: lihat, tambah, ubah, aktif/nonaktif, dan hapus produk.
class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({super.key});

  Future<void> _openForm(BuildContext context, [Product? product]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (context.mounted && saved == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produk berhasil disimpan')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(
          'Hapus ${product.name}? '
          'Produk yang pernah terjual tidak dapat dihapus.',
        ),
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
    final deleted = vm.deleteProduct(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Produk dihapus' : vm.errorMessage ?? 'Gagal menghapus',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(title: const Text('Katalog Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: const Color(0xFFE87924),
      ),
      body: Consumer<SaleViewModel>(
        builder: (context, vm, _) {
          final items = vm.allProducts;
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada produk. Tambahkan produk pertama.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                specialPrice: vm.specialPriceFor(product.id),
                specialPriceLabel: 'Harga di ${SaleViewModel.demoLocationName}',
                onEdit: () => _openForm(context, product),
                onToggleActive: () => vm.setProductActive(
                  id: product.id,
                  isActive: !product.isActive,
                ),
                onDelete: () => _confirmDelete(context, product),
              );
            },
          );
        },
      ),
    );
  }
}
