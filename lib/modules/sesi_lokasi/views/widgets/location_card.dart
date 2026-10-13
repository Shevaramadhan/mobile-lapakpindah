import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';

/// Kartu satu lokasi di Daftar Lokasi (Figma M1·1).
/// Bentuk kartu (putih, garis, sudut 8) dari cardTheme di app_theme.dart.
class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    // Gaya teks & warna dari tema
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // ── Ikon pin dalam kotak oranye muda ──
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusCard,
                ),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Nama, catatan, status koordinat ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.note ?? 'Tanpa catatan',
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Chip kuning: koordinat belum diambil lewat GPS (FR-02 menyusul)
                  if (!location.hasCoordinate) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'Koordinat belum ditandai',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
