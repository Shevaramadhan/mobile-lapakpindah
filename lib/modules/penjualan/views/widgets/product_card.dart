import 'package:flutter/material.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/modules/penjualan/models/product.dart';

/// Kartu satu produk di Katalog Produk.
/// Widget presentasi murni: aksi dikirim lewat callback.
class ProductCard extends StatelessWidget {
  final Product product;

  /// Harga khusus di lokasi sesi, null jika memakai harga normal.
  final int? specialPrice;
  final String specialPriceLabel;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.specialPrice,
    required this.specialPriceLabel,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = product.isActive ? 'Aktif' : 'Nonaktif';
    final special = specialPrice;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.fastfood_outlined)),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${formatRupiah(product.sellingPrice)} • $status'
                '${special != null ? '\n$specialPriceLabel: ${formatRupiah(special)}' : ''}',
              ),
              trailing: IconButton(
                tooltip: 'Edit produk',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onToggleActive,
                    icon: Icon(
                      product.isActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    label: Text(product.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus produk',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
