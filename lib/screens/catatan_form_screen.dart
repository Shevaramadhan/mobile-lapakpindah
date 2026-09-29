import 'package:flutter/material.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/theme/app_text_styles.dart';
import 'package:lapakpindah/utils/validators.dart';

/// Screen form untuk menulis catatan produk dan mengembalikan hasilnya.
class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Tutup layar ini sambil MEMBAWA teks catatan ke layar sebelumnya
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        title: Text('Tulis Catatan', style: AppTextStyles.titleLarge()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.inputBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                style: AppTextStyles.bodyMedium(),
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    Validators.minLength(value, 5, fieldName: 'Catatan'),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _simpan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(
                    double.infinity,
                    AppSpacing.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadius,
                    ),
                  ),
                ),
                child: Text('Simpan', style: AppTextStyles.buttonText()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
