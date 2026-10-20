import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';

/// Bagian "Koordinat lokasi" di form lokasi (Figma M1·2).
///
/// SEMENTARA hanya tampilan: fitur GPS (FR-02) belum dipasang, jadi kotak peta
/// berisi pesan "Peta belum tersedia". Nanti saat GPS dibuat, kotak pesan ini
/// diganti `LocationMap` dari core/widgets/location_map.dart.
class CoordinateSection extends StatelessWidget {
  const CoordinateSection({super.key, required this.onTakeLocation});

  /// Dipanggil saat tombol "Ambil lokasi saat ini" ditekan.
  final VoidCallback onTakeLocation;

  @override
  Widget build(BuildContext context) {
    // Gaya teks & warna dari tema (app_theme.dart)
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Koordinat lokasi', style: textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),

        // ── Kotak peta: berisi pesan karena koordinat belum diambil ──
        // Kata-katanya bukan "gagal dimuat" agar tidak terbaca sebagai error.
        Card(
          child: Container(
            height: 140,
            color: colorScheme.surfaceContainer,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 32, color: colorScheme.outline),
                const SizedBox(height: AppSpacing.sm),
                Text('Peta belum tersedia', style: textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(
                  'Peta akan tampil setelah koordinat diambil lewat GPS',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Tombol ambil lokasi (gaya dari outlinedButtonTheme) ──
        OutlinedButton.icon(
          onPressed: onTakeLocation,
          icon: const Icon(Icons.my_location, size: 18),
          label: const Text('Ambil lokasi saat ini'),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Teks bantuan ──
        Text(
          'Tekan saat kamu berada di tempat jualan.',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
