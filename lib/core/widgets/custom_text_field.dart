import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Input field LapakPindah: label di atas + TextFormField.
/// Tampilan kolom mengikuti inputDecorationTheme di app_theme.dart.
class LapakTextField extends StatelessWidget {
  const LapakTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.trailingLabel,
    this.onTrailingTap,
    this.keyboardType,
    this.enabled = true,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.onFieldSubmitted,
  });

  // ── Label & isi ──
  final String label;
  final String hintText;
  final TextEditingController? controller;

  // ── Ikon ──
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  // ── Perilaku input ──
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  /// false = field dikunci (misal saat proses login berjalan).
  final bool enabled;

  /// Tombol aksi keyboard, misal "next" atau "done".
  final TextInputAction? textInputAction;

  /// Penyaring input, misal hanya angka untuk PIN.
  final List<TextInputFormatter>? inputFormatters;

  /// Batas jumlah karakter. Penghitung karakter disembunyikan.
  final int? maxLength;

  /// Jumlah baris kolom; lebih dari 1 untuk isian panjang (misal catatan).
  final int maxLines;

  /// Dipanggil saat pengguna menekan tombol aksi keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  // ── Teks kecil di kanan label (misal "Lupa PIN?") ──
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Baris label ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.labelLarge),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Text(
                  trailingLabel!,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // ── Kolom input ──
        // Garis, warna, hint, dan warna ikon diatur inputDecorationTheme
        // (app_theme.dart); teks ketikan memakai textTheme.bodyLarge.
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            // Sembunyikan penghitung "0/6" bawaan maxLength
            counterText: '',
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
