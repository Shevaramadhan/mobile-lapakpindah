import 'package:flutter/material.dart';

/// Nilai warna LapakPindah — diambil dari desain Figma.
///
/// Widget TIDAK memakai kelas ini secara langsung untuk warna umum.
/// Warna umum dibaca lewat `Theme.of(context).colorScheme` (diatur di app_theme.dart).
/// Yang boleh dipakai langsung di widget hanya warna yang tidak punya
/// peran di ColorScheme: [success], [successContainer], [warningContainer].
class AppColors {
  AppColors._();

  // ── Warna utama (→ colorScheme.primary / onPrimary) ──
  static const Color primary = Color(0xFFB15F00);
  static const Color onPrimary = Color(0xFFFFFBFF);

  /// Oranye tua: teks link, tombol garis, ikon modul (→ onPrimaryContainer).
  static const Color primaryDark = Color(0xFF8D4B00);

  /// Oranye muda: latar kotak ikon modul & kartu sesi (→ primaryContainer).
  static const Color primarySoft = Color(0xFFFBEEDD);

  // ── Teks (→ onSurface / onSurfaceVariant) ──
  static const Color textPrimary = Color(0xFF111C2D);
  static const Color textSecondary = Color(0xFF565E74);

  // ── Garis & ikon input (→ outlineVariant / outline) ──
  static const Color inputBorder = Color(0xFFDBC2B0);
  static const Color inputIcon = Color(0xFF887364);
  // rgba(136,115,100,0.7) — warna teks contoh (hint) di kolom isian
  static const Color inputPlaceholder = Color(0xB3887364);

  // ── Permukaan ──
  static const Color surfaceBackground = Color(0xFFF9F9FF); // latar layar
  static const Color surfaceCard = Color(0xFFFFFFFF); // → surface
  static const Color surfaceChip = Color(0xFFF0F3FF); // → surfaceContainer

  // ── Status (tidak ada di ColorScheme, boleh dipakai langsung) ──
  static const Color success = Color(0xFF006948);
  static const Color successContainer = Color(0xFFE3F4EC); // latar badge hijau
  static const Color warningContainer = Color(0xFFFFF1D6); // latar badge kuning
  static const Color error = Color(0xFFBA1A1A); // → colorScheme.error

  // ── Bayangan ──
  static const Color shadow = Color(0x33000000); // rgba(0,0,0,0.2)
}
