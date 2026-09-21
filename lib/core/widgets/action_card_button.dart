import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';

/// Tombol aksi dashboard (Kasir POS, Catat Biaya, Rapor Profit).
class ActionCardButton extends StatelessWidget {
  const ActionCardButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.onTap,
    this.trailingIcon = Icons.arrow_forward_ios,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary ? AppColors.primary : AppColors.surfaceCard;
    final borderColor = isPrimary
        ? AppColors.primaryDark
        : AppColors.inputBorder;
    final titleColor = isPrimary ? AppColors.onPrimary : AppColors.textPrimary;
    final subtitleColor = isPrimary
        ? AppColors.accentLight
        : AppColors.textSecondary;
    final iconColor = isPrimary ? AppColors.onPrimary : AppColors.textSecondary;
    final trailingColor = isPrimary
        ? AppColors.onPrimary
        : AppColors.textSecondary;

    return Container(
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(leadingIcon, color: iconColor, size: 19),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.titleSmall(color: titleColor),
                        ),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall(color: subtitleColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(trailingIcon, color: trailingColor, size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
