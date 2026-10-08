import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/core/utils/validators.dart';
import 'package:lapakpindah/core/widgets/custom_button.dart';
import 'package:lapakpindah/core/widgets/custom_text_field.dart';
import 'package:lapakpindah/core/widgets/state_views.dart';
import 'package:lapakpindah/modules/auth/view_models/auth_view_model.dart';
import 'package:lapakpindah/routes/app_routes.dart';

/// Screen login LapakPindah: masuk dengan Nomor WA / Email + PIN 6 digit.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── State form (M4: Form + GlobalKey + TextEditingController) ──
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  /// true selama aplikasi mengecek akun yang diingat di perangkat.
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    // Dipanggil setelah frame pertama agar aman memakai context.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedSession());
  }

  // ── Aksi: cek "Ingat akun ini di perangkat ini" saat aplikasi dibuka ──
  Future<void> _checkSavedSession() async {
    final hasSession = await context.read<AuthViewModel>().checkSavedSession();

    // Setelah await, pastikan screen masih ada sebelum memakai context
    if (!mounted) return;

    if (hasSession) {
      // Akun diingat → langsung ke Beranda tanpa login lagi
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // Tidak ada akun diingat → tampilkan form login
      setState(() => _isCheckingSession = false);
    }
  }

  @override
  void dispose() {
    // Controller wajib dibuang saat screen ditutup agar tidak memory leak
    _identifierController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ── Aksi: tombol Masuk ──
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus(); // tutup keyboard

    // 1. Validasi semua field; berhenti jika ada yang salah
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // 2. Proses login lewat ViewModel (loading & error dikelola ViewModel)
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.login(
      _identifierController.text.trim(),
      _pinController.text,
    );

    // 3. Setelah await, pastikan screen masih ada sebelum memakai context
    if (!mounted) return;

    // 4. Berhasil → ganti Login dengan Beranda (Login dibuang dari stack).
    //    Gagal → pesan error tampil otomatis lewat ErrorBanner.
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  // ── Aksi: "Lupa PIN?" (belum tersedia) ──
  void _handleForgotPin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur atur ulang PIN belum tersedia.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sedang mengecek akun yang diingat → tampilkan indikator loading
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceCard,
        body: LoadingView(message: 'Membuka LapakPindah...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceCard,
      body: SafeArea(
        // M3 Layout: SingleChildScrollView agar tidak overflow saat keyboard muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 64),
                _buildLoginForm(),
                const SizedBox(height: AppSpacing.xl),
                _buildBottomFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bagian 1: logo + nama aplikasi + tagline ──
  Widget _buildTopHeader() {
    return Row(
      children: [
        Container(
          width: AppSpacing.logoSize,
          height: AppSpacing.logoSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCard),
          ),
          child: const Icon(
            Icons.storefront,
            color: AppColors.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Flexible: teks menyusut/terpotong di layar sempit, tidak overflow
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LapakPindah',
                style: AppTextStyles.titleLarge(),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Cari lokasi paling untung',
                style: AppTextStyles.labelSmall(),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bagian 2: judul, input, checkbox, tombol ──
  Widget _buildLoginForm() {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        final isLoading = viewModel.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul
            Text('Masuk ke Akun', style: AppTextStyles.heading1()),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Catat jualan dan biaya di tiap lokasi',
              style: AppTextStyles.bodyMedium(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pesan error dari proses login (misal PIN salah)
            if (viewModel.errorMessage != null) ...[
              ErrorBanner(message: viewModel.errorMessage!),
              const SizedBox(height: AppSpacing.md),
            ],

            // Input 1: Nomor WA atau Email
            LapakTextField(
              label: 'Nomor WA atau Email',
              hintText: 'Contoh: 0812xxxx atau nama@gmail.com',
              controller: _identifierController,
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: Validators.phoneOrEmail,
            ),
            const SizedBox(height: AppSpacing.md),

            // Input 2: PIN 6 digit (hanya angka)
            LapakTextField(
              label: 'PIN',
              hintText: 'Masukkan PIN 6 digit',
              controller: _pinController,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              enabled: !isLoading,
              trailingLabel: 'Lupa PIN?',
              onTrailingTap: _handleForgotPin,
              onFieldSubmitted: (_) => _handleLogin(),
              suffixIcon: IconButton(
                tooltip: _obscurePin ? 'Tampilkan PIN' : 'Sembunyikan PIN',
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
                icon: Icon(
                  _obscurePin
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.inputIcon,
                  size: 20,
                ),
              ),
              validator: Validators.pin,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Checkbox "ingat akun" — seluruh baris bisa diketuk (tinggi ≥48dp)
            InkWell(
              onTap: isLoading
                  ? null
                  : () => viewModel.toggleRememberDevice(!viewModel.rememberDevice),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Checkbox(
                      value: viewModel.rememberDevice,
                      onChanged: isLoading
                          ? null
                          : (value) => viewModel.toggleRememberDevice(value ?? false),
                      activeColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.inputBorder),
                    ),
                    Expanded(
                      child: Text(
                        'Ingat akun ini di perangkat ini',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Tombol Masuk (menampilkan loading saat proses berjalan)
            LapakPrimaryButton(
              label: 'Masuk',
              icon: Icons.login,
              isLoading: isLoading,
              onPressed: _handleLogin,
            ),
          ],
        );
      },
    );
  }

  // ── Bagian 3: "Belum punya akun? Buat akun" ──
  Widget _buildBottomFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      // Wrap: jika tidak muat satu baris, "Buat akun" turun ke baris berikutnya
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Belum punya akun? ', style: AppTextStyles.bodyMedium()),
          TextButton(
            // M4: named route, terdaftar di AppRoutes
            onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              minimumSize: const Size(48, 48),
            ),
            child: Text(
              'Buat akun',
              style: AppTextStyles.labelMedium(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
