import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';

/// Modal Bottom Sheet untuk menampilkan detail lengkap satu pengeluaran,
/// termasuk teks keterangan penuh, kategori, nominal, waktu, dan foto bukti nota.
class ExpenseDetailSheet extends StatelessWidget {
  const ExpenseDetailSheet({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  final Expense expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isFixed = expense.isFixedCost;
    final hasReceipt = expense.hasReceipt;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ──
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header bar: Judul & tombol tutup ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Pengeluaran',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Nominal besar ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isFixed ? AppColors.primarySoft : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFixed
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nominal Biaya',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(expense.amount),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Baris Badge: Kategori + Biaya Tetap + Status Nota ──
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  avatar: const Icon(Icons.category_outlined, size: 16),
                  label: Text(expense.category.label),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                if (isFixed)
                  Chip(
                    avatar: Icon(Icons.push_pin, size: 16, color: colorScheme.primary),
                    label: Text(
                      'Biaya Tetap',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.primarySoft,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                if (hasReceipt)
                  const Chip(
                    avatar: Icon(Icons.receipt_long, size: 16, color: Color(0xFF2563EB)),
                    label: Text(
                      'Ada Foto Nota',
                      style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Color(0xFFEFF6FF),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Keterangan Pengeluaran (Teks Penuh) ──
            Text('Keterangan', style: textTheme.labelLarge),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: SelectableText(
                expense.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Waktu Pencatatan ──
            Text('Waktu Pencatatan', style: textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  _formatFullDateTime(expense.recordedAt),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Foto Bukti Nota (Jika ada) ──
            if (hasReceipt) ...[
              Text('Bukti Foto Nota', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              _buildReceiptImage(context, expense.receiptPhotoPath!),
              const SizedBox(height: AppSpacing.md),
            ],

            const SizedBox(height: AppSpacing.sm),

            // ── Tombol Aksi (Ubah & Hapus) ──
            if (onEdit != null || onDelete != null) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Ubah'),
                        onPressed: () {
                          Navigator.pop(context);
                          onEdit?.call();
                        },
                      ),
                    ),
                  if (onEdit != null && onDelete != null && !isFixed)
                    const SizedBox(width: AppSpacing.sm),
                  if (onDelete != null && !isFixed)
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Hapus'),
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete?.call();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tampilan foto nota dengan kemampuan tap untuk memperbesar.
  Widget _buildReceiptImage(BuildContext context, String path) {
    final file = File(path);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: exists ? () => _showFullscreenImage(context, file) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 220),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: exists
              ? Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.file(
                      file,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Ketuk perbesar',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 36, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text(
              'Foto nota terlampir',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(file, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatFullDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour.$minute WIB';
  }
}

