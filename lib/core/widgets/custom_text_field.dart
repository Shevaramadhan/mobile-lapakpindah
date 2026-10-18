import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';

/// Input field kustom LapakPindah — dengan label, icon, shadow.
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

  /// Dipanggil saat pengguna menekan tombol aksi keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  // ── Teks kecil di kanan label (misal "Lupa PIN?") ──
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Baris label ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium()),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Text(
                  trailingLabel!,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // ── Kolom input dengan bayangan ──
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            keyboardType: keyboardType,
            enabled: enabled,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            onFieldSubmitted: onFieldSubmitted,
            style: AppTextStyles.inputText(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.inputText(),
              // Sembunyikan penghitung "0/6" bawaan maxLength
              counterText: '',
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.inputIcon, size: 18)
                  : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.surfaceCard,
              contentPadding: EdgeInsets.only(
                left: prefixIcon != null ? 44 : 14,
                right: 14,
                top: 13.5,
                bottom: 13.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: const BorderSide(color: AppColors.error, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
