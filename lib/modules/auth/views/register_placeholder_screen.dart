import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/modules/auth/view_models/auth_view_model.dart';

/// Placeholder screen untuk registrasi — akan diimplementasi nanti.
class RegisterPlaceholderScreen extends StatelessWidget {
  const RegisterPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Tombol kembali muncul otomatis; gaya AppBar dari appBarTheme
      appBar: AppBar(title: const Text('Daftar Akun')),
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
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Halaman Registrasi', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Fitur ini akan segera hadir.\nSilakan gunakan akun demo untuk login.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusCard,
                  ),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text('Akun Demo', style: textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    // Akun demo dibaca lewat AuthViewModel (View → ViewModel)
                    Text(
                      'No. WA: ${AuthViewModel.demoPhone}',
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      'atau Email: ${AuthViewModel.demoEmail}',
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      'PIN: ${AuthViewModel.demoPin}',
                      style: textTheme.bodySmall,
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
