import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/modules/pengeluaran/models/session_info.dart';

/// Banner informasi sesi aktif di bagian atas layar pengeluaran (Frame 1 Figma).
///
/// Menampilkan titik hijau menyala, nama lokasi sesi aktif,
/// dan jam buka beserta rencana jam tutup.
class ActiveSessionBar extends StatelessWidget {
  const ActiveSessionBar({super.key, required this.session});

  final SessionInfo session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Format jam buka dan rencana tutup: "06.10" & "10.30"
    final openStr = _formatTime(session.openTime);
    final closeStr = _formatTime(session.plannedCloseTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // kuning muda dari Figma
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          // Titik indikator hijau sesi aktif
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sesi aktif · ${session.locationName}',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Buka $openStr · rencana tutup $closeStr',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }
}
