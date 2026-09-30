import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/widgets/custom_button.dart';
import 'package:lapakpindah/core/widgets/custom_text_field.dart';
import 'package:lapakpindah/modules/auth/auth_view_model.dart';
import 'package:lapakpindah/modules/auth/register_placeholder_screen.dart';
import 'package:lapakpindah/utils/validators.dart';
import 'package:lapakpindah/routes/app_routes.dart';

/// Screen login LapakPindah.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.login(
      _identifierController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login gagal. Periksa kembali nomor/email dan kata sandi.',
            style: AppTextStyles.bodySmall(color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCard,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                _buildLoginForm(),
                _buildBottomFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logo + nama app + tagline.
  Widget _buildTopHeader() {
    return Row(
      children: [
        Container(
          width: AppSpacing.logoSize,
          height: AppSpacing.logoSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: const Icon(
            Icons.storefront,
            color: AppColors.onPrimary,
            size: 16,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LapakPindah', style: AppTextStyles.titleLarge()),
            Text(
              'Manajemen UMKM Keliling',
              style: AppTextStyles.labelSmall(),
            ),
          ],
        ),
      ],
    );
  }

  /// Form utama: headline, input fields, checkbox, button.
  Widget _buildLoginForm() {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            Text('Masuk ke Akun', style: AppTextStyles.heading1()),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kelola lapak dan kasir harian kamu',
              style: AppTextStyles.bodyMedium(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Input 1: WA/Email
            LapakTextField(
              label: 'Nomor WhatsApp atau Email',
              hintText: '0812-xxxx-xxxx',
              controller: _identifierController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.number, // Hanya angka
              validator: (value) => Validators.numericOnly(
                value,
                fieldName: 'Nomor WA',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Input 2: Password/PIN
            LapakTextField(
              label: 'Kata sandi atau PIN',
              hintText: 'Masukkan sandi atau PIN 6 digit',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              trailingLabel: 'Lupa sandi?',
              onTrailingTap: () {
                // TODO: Implement forgot password
              },
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.inputIcon,
                    size: 18,
                  ),
                ),
              ),
              // TUGAS: Memakai fungsi password dari validators.dart
              validator: Validators.password,
            ),
            const SizedBox(height: AppSpacing.md),

            // Checkbox: Ingat perangkat
            GestureDetector(
              onTap: () => viewModel.toggleRememberDevice(
                !viewModel.rememberDevice,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: viewModel.rememberDevice,
                      onChanged: (value) {
                        viewModel.toggleRememberDevice(value ?? false);
                      },
                      activeColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      side: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Ingat perangkat ini untuk 30 hari',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Button: Masuk
            LapakPrimaryButton(
              label: 'Masuk ke Lapak',
              icon: Icons.login,
              isLoading: viewModel.isLoading,
              onPressed: _handleLogin,
            ),
          ],
        );
      },
    );
  }

  /// Footer: "Belum punya akun? Daftar gratis"
  Widget _buildBottomFooter() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Belum punya akun? ',
              style: AppTextStyles.bodyMedium(),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterPlaceholderScreen(),
                  ),
                );
              },
              child: Text(
                'Daftar gratis',
                style: AppTextStyles.labelMedium(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
