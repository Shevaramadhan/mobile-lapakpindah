import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/models/item.dart';
import 'package:lapakpindah/routes/app_routes.dart';

/// Layar detail produk — StatefulWidget yang dapat menerima kembalian catatan.
class DetailScreen extends StatefulWidget {
  // (1) data yang DITERIMA dari Home
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // (3) buka form, TUNGGU hasilnya, lalu tampilkan
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return; // null = pengguna batal
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.item"
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context), // Back ke Home
        ),
        title: Text('Detail Produk', style: AppTextStyles.titleLarge()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.inputBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero icon produk
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.surfaceChip,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: const Icon(
                  Icons.fastfood_outlined,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Kartu info utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusCard,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID produk
                  _buildInfoRow(
                    icon: Icons.tag,
                    label: 'ID Produk',
                    value: item.id, // data dari item
                  ),
                  const Divider(
                    color: AppColors.inputBorder,
                    height: AppSpacing.xl,
                  ),

                  // Nama produk
                  Text('Nama Produk', style: AppTextStyles.labelMedium()),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.title, // data dari item
                    style: AppTextStyles.heading2(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Kategori & harga
                  _buildInfoRow(
                    icon: Icons.sell_outlined,
                    label: 'Kategori',
                    value: item.subtitle, // data dari item
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Kartu deskripsi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusCard,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deskripsi', style: AppTextStyles.labelMedium()),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.description, // data dari widget.item
                    style: AppTextStyles.bodyMedium(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Kartu Catatan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusCard,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan Tambahan', style: AppTextStyles.labelMedium()),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _catatan == null
                        ? 'Belum ada catatan.'
                        : 'Catatan: $_catatan',
                    style: AppTextStyles.bodyMedium(
                      color: _catatan == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _bukaFormCatatan,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Tulis Catatan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(
                        double.infinity,
                        AppSpacing.buttonHeight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.borderRadius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Baris informasi dengan ikon, label, dan nilai.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.inputIcon, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall()),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.titleSmall()),
            ],
          ),
        ),
      ],
    );
  }
}
