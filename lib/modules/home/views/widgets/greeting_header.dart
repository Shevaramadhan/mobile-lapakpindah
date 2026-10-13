import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';

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
    // Gaya teks & warna dari tema (app_theme.dart)
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Teks sapaan & judul ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $userName', style: textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                isSessionActive ? 'Lapak sedang buka' : 'Lapak sedang tutup',
                style: textTheme.titleLarge,
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
            color: colorScheme.surfaceContainer,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                // Hijau "success" tidak ada di ColorScheme → dari AppColors
                color: isSessionActive
                    ? AppColors.success
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isSessionActive ? 'Sesi aktif' : 'Tidak ada sesi',
                style: textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
