import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';

/// Tema global LapakPindah (M3: ThemeData).
///
/// Semua gaya teks, warna, dan bentuk komponen diatur SEKALI di sini.
/// Widget cukup membaca `Theme.of(context).textTheme` / `.colorScheme`,
/// tanpa menulis ukuran font atau kode warna sendiri.
/// Nilai diambil dari desain Figma (font Plus Jakarta Sans).
class AppTheme {
  AppTheme._();

  // ── 1. Gaya teks (textTheme) ──
  // Nama peran mengikuti Material 3; komentar = contoh pemakaian di Figma.
  static final TextTheme _textTheme = GoogleFonts.plusJakartaSansTextTheme(
    const TextTheme(
      // Nominal uang besar, misal "Rp 400.000"
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 34 / 28,
        letterSpacing: -0.7,
        color: AppColors.textPrimary,
      ),
      // Judul halaman login "Masuk ke Akun"
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      ),
      // Judul status "Lapak sedang buka"
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        color: AppColors.textPrimary,
      ),
      // Judul AppBar & nama aplikasi
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        letterSpacing: -0.45,
        color: AppColors.textPrimary,
      ),
      // Nama lokasi, nilai rupiah kecil, teks tombol
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 20 / 15,
        color: AppColors.textPrimary,
      ),
      // Teks yang diketik di kolom isian
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 20 / 16,
        color: AppColors.textPrimary,
      ),
      // Paragraf / keterangan
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.textSecondary,
      ),
      // Teks pendukung kecil, misal "Halo, Bang Radit"
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: AppColors.textSecondary,
      ),
      // Label kolom isian, link, chip
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        color: AppColors.textPrimary,
      ),
      // Keterangan kecil, misal subjudul kartu modul
      labelMedium: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        color: AppColors.textSecondary,
      ),
      // Badge & label bottom nav
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 14 / 11,
        color: AppColors.textSecondary,
      ),
    ),
  );

  // ── 2. Warna (colorScheme) ──
  // fromSeed membuat warna turunan otomatis, lalu warna dari Figma ditimpakan.
  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primaryDark,
    surface: AppColors.surfaceCard,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainer: AppColors.surfaceChip,
    outline: AppColors.inputIcon,
    outlineVariant: AppColors.inputBorder,
    error: AppColors.error,
  );

  /// Sudut kecil (tombol, isian) dan sudut kartu.
  static final _radiusSmall = BorderRadius.circular(AppSpacing.borderRadius);
  static final _radiusCard = BorderRadius.circular(AppSpacing.borderRadiusCard);

  /// Garis kolom isian; [color] berbeda untuk normal / fokus / error.
  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: _radiusSmall,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: AppColors.surfaceBackground,

      // ── 3. AppBar: putih, garis bawah tipis ──
      appBarTheme: AppBarTheme(
        backgroundColor: _colorScheme.surface,
        foregroundColor: _colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: _textTheme.titleMedium,
        iconTheme: IconThemeData(color: _colorScheme.onSurfaceVariant),
        shape: Border(bottom: BorderSide(color: _colorScheme.outlineVariant)),
      ),

      // ── 4. Tombol utama (FilledButton): oranye, sudut 4, bayangan ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _colorScheme.primary,
          foregroundColor: _colorScheme.onPrimary,
          minimumSize: const Size(48, 48), // area sentuh minimal (NFR-03)
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: _textTheme.titleSmall,
          elevation: 2,
          shadowColor: AppColors.shadow,
          side: const BorderSide(color: AppColors.primaryDark),
          shape: RoundedRectangleBorder(borderRadius: _radiusSmall),
        ),
      ),

      // ── 5. Tombol garis (OutlinedButton): "Tutup lapak", "Ambil lokasi" ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: _colorScheme.surface,
          foregroundColor: _colorScheme.onPrimaryContainer,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(color: _colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: _radiusSmall),
        ),
      ),

      // ── 6. Tombol teks (TextButton): link "Buat akun", "Batal" ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _colorScheme.onPrimaryContainer,
          minimumSize: const Size(48, 48),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // ── 7. Kolom isian (TextFormField) ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13.5,
        ),
        hintStyle: _textTheme.bodyLarge?.copyWith(
          color: AppColors.inputPlaceholder,
        ),
        prefixIconColor: _colorScheme.outline,
        suffixIconColor: _colorScheme.outline,
        border: _inputBorder(_colorScheme.outlineVariant),
        enabledBorder: _inputBorder(_colorScheme.outlineVariant),
        disabledBorder: _inputBorder(_colorScheme.outlineVariant),
        focusedBorder: _inputBorder(_colorScheme.primary, width: 1.5),
        errorBorder: _inputBorder(_colorScheme.error),
        focusedErrorBorder: _inputBorder(_colorScheme.error, width: 1.5),
      ),

      // ── 8. Kartu (Card): putih, garis tepi, sudut 8, bayangan tipis ──
      cardTheme: CardThemeData(
        color: _colorScheme.surface,
        surfaceTintColor: Colors.transparent, // jaga warna tetap putih di M3
        elevation: 1,
        margin: EdgeInsets.zero, // jarak antar kartu diatur dengan SizedBox
        clipBehavior:
            Clip.antiAlias, // isi (misal peta) ikut terpotong di sudut
        shape: RoundedRectangleBorder(
          borderRadius: _radiusCard,
          side: BorderSide(color: _colorScheme.outlineVariant),
        ),
      ),

      // ── 9. Checkbox & garis pemisah ──
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _colorScheme.onPrimaryContainer
              : null,
        ),
        side: BorderSide(color: _colorScheme.outlineVariant),
      ),
      dividerTheme: DividerThemeData(
        color: _colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
