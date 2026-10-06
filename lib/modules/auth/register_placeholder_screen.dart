import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/data/auth_repository.dart';

/// Placeholder screen untuk registrasi — akan diimplementasi nanti.
class RegisterPlaceholderScreen extends StatelessWidget {
  const RegisterPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCard,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Daftar Akun', style: AppTextStyles.titleLarge()),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceChip,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Halaman Registrasi',
                style: AppTextStyles.heading2(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Fitur ini akan segera hadir.\nSilakan gunakan akun demo untuk login.',
                style: AppTextStyles.bodyMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceChip,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    Text('Akun Demo', style: AppTextStyles.labelMedium()),
                    const SizedBox(height: AppSpacing.xs),
                    // Akun demo diambil dari AuthRepository agar selalu sama
                    Text(
                      'No. WA: ${AuthRepository.demoPhone}',
                      style: AppTextStyles.bodySmall(),
                    ),
                    Text(
                      'atau Email: ${AuthRepository.demoEmail}',
                      style: AppTextStyles.bodySmall(),
                    ),
                    Text(
                      'PIN: ${AuthRepository.demoPin}',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
