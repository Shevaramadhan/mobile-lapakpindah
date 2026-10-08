import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/widgets/location_map.dart';
import 'package:lapakpindah/modules/home/models/dashboard_summary.dart';
import 'package:lapakpindah/modules/home/views/widgets/dashboard_card.dart';

/// DateTime → "06.10" (hanya dipakai di file ini).
String _formatTime(DateTime? time) =>
    time == null ? '-' : DateFormat('HH.mm').format(time);

/// Kartu sesi aktif: peta + nama lokasi + jam + tombol Tutup lapak.
class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({
    super.key,
    required this.summary,
    required this.onClose,
  });

  final DashboardSummary summary;

  /// Dipanggil saat tombol "Tutup lapak" ditekan.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Peta lokasi (atau pengganti jika koordinat belum ada) ──
          SizedBox(
            height: 240,
            child: summary.hasCoordinate
                ? LocationMap(
                    latitude: summary.latitude!,
                    longitude: summary.longitude!,
                  )
                : Container(
                    color: AppColors.surfaceChip,
                    alignment: Alignment.center,
                    child: Text(
                      'Koordinat lokasi belum ditandai',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ),
          ),
          const Divider(height: 1, color: AppColors.inputBorder),

          // ── Nama lokasi, jam, tombol tutup ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.locationName ?? '-',
                        style: AppTextStyles.titleLarge(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buka ${_formatTime(summary.openTime)} · '
                        'rencana tutup ${_formatTime(summary.plannedCloseTime)}',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                  ),
                  child: Text(
                    'Tutup lapak',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu saat tidak ada sesi aktif: ajakan membuka lapak.
class ClosedSessionCard extends StatelessWidget {
  const ClosedSessionCard({super.key, required this.onOpen});

  /// Dipanggil saat tombol "Buka lapak" ditekan.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 48,
            color: AppColors.inputIcon,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Belum ada sesi jualan', style: AppTextStyles.titleSmall()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Buka lapak di sebuah lokasi untuk mulai mencatat penjualan dan biaya.',
            style: AppTextStyles.bodySmall(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.store),
            label: const Text('Buka lapak'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}
