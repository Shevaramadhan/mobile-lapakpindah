import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
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
    // Gaya teks & warna dari tema (app_theme.dart)
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                    color: colorScheme.surfaceContainer,
                    alignment: Alignment.center,
                    child: Text(
                      'Koordinat lokasi belum ditandai',
                      style: textTheme.bodySmall,
                    ),
                  ),
          ),
          const Divider(), // warna & tebal dari dividerTheme
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
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buka ${_formatTime(summary.openTime)} · '
                        'rencana tutup ${_formatTime(summary.plannedCloseTime)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Gaya tombol garis dari outlinedButtonTheme
                OutlinedButton(
                  onPressed: onClose,
                  child: const Text('Tutup lapak'),
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
    final textTheme = Theme.of(context).textTheme;

    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Belum ada sesi jualan', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Buka lapak di sebuah lokasi untuk mulai mencatat penjualan dan biaya.',
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Gaya tombol dari filledButtonTheme
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.store),
            label: const Text('Buka lapak'),
          ),
        ],
      ),
    );
  }
}
