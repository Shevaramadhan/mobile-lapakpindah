import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';

/// Tombol utama LapakPindah — bg primary (#B15F00).
class LapakPrimaryButton extends StatelessWidget {
  const LapakPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: AppColors.primaryDark),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.onPrimary, size: 15),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(label, style: AppTextStyles.buttonText()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Tombol sekunder LapakPindah — bg putih, border #DBC2B0.
class LapakSecondaryButton extends StatelessWidget {
  const LapakSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.textSecondary, size: 15),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style: AppTextStyles.buttonText(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
