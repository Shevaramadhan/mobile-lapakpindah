import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';

/// Tombol utama LapakPindah: lebar penuh, tinggi 56.
/// Warna, sudut, dan gaya teks diambil dari filledButtonTheme (app_theme.dart).
class LapakPrimaryButton extends StatelessWidget {
  const LapakPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      // AbsorbPointer: saat loading tombol tidak bisa ditekan,
      // tetapi warnanya tetap oranye (tidak berubah jadi abu "disabled").
      child: AbsorbPointer(
        absorbing: isLoading,
        child: FilledButton(
          onPressed: onPressed,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null || iconWidget != null) ...[
                      iconWidget ?? Icon(icon, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(child: Text(label, textAlign: TextAlign.center)),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Tombol sekunder LapakPindah: lebar penuh, latar putih bergaris.
/// Gaya diambil dari outlinedButtonTheme (app_theme.dart).
class LapakSecondaryButton extends StatelessWidget {
  const LapakSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null || iconWidget != null) ...[
              iconWidget ?? Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
