import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';

/// Bagian atas Beranda: sapaan + status lapak (buka/tutup) + chip sesi.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.isSessionActive,
  });

  final String userName;
  final bool isSessionActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Teks sapaan & judul ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $userName', style: AppTextStyles.bodySmall()),
              const SizedBox(height: 2),
              Text(
                isSessionActive ? 'Lapak sedang buka' : 'Lapak sedang tutup',
                style: AppTextStyles.heading2(),
              ),
            ],
          ),
        ),

        // ── Chip status sesi (titik hijau = aktif, abu = tidak ada sesi) ──
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceChip,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: isSessionActive
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isSessionActive ? 'Sesi aktif' : 'Tidak ada sesi',
                style: AppTextStyles.labelMedium(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
