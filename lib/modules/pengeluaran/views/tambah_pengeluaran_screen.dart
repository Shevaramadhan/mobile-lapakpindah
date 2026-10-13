import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/widgets/custom_button.dart';
import 'package:lapakpindah/core/widgets/custom_text_field.dart';
import 'package:lapakpindah/core/widgets/state_views.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/view_models/tambah_pengeluaran_view_model.dart';

/// Form Tambah Pengeluaran (Figma Frame 2, 7, 8, 9).
///
/// Flow: isi form → validasi → simpan (loading) → kembalikan [Expense]
/// baru sebagai result ke layar Daftar. Jika gagal: ErrorBanner ditampilkan
/// dan tombol menjadi "Coba simpan lagi".
class TambahPengeluaranScreen extends StatefulWidget {
  const TambahPengeluaranScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<TambahPengeluaranScreen> createState() => _TambahPengeluaranScreenState();
}

class _TambahPengeluaranScreenState extends State<TambahPengeluaranScreen> {
  static const int _descriptionMaxLength = 60;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  /// true saat kedua isian sudah terisi (tombol Simpan jadi aktif, Frame 7).
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TambahPengeluaranViewModel>().clearSaveError(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Handlers isi form (sinkronkan ke ViewModel + tombol Simpan) ──

  void _onDescriptionChanged(String value) {
    final vm = context.read<TambahPengeluaranViewModel>();
    vm.setDescription(value);
    _updateCanSave(vm);
  }

  void _onAmountChanged(String value) {
    final vm = context.read<TambahPengeluaranViewModel>();
    vm.setAmountText(value);
    _updateCanSave(vm);
  }

  void _updateCanSave(TambahPengeluaranViewModel vm) {
    final next = vm.canSave;
    if (next != _canSave) setState(() => _canSave = next);
  }

  // ── Event: tombol Simpan ditekan ──

  Future<void> _save(TambahPengeluaranViewModel vm) async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final saved = await vm.save();
    if (!mounted) return;

    if (saved != null) {
      Navigator.pop(context, saved);
    }
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<TambahPengeluaranViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tambah pengeluaran')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LapakTextField(
                    label: 'Keterangan pengeluaran',
                    hintText: 'Contoh: beli es batu',
                    controller: _descriptionController,
                    maxLength: _descriptionMaxLength,
                    enabled: !vm.isSaving,
                    validator: vm.validateDescription,
                    onChanged: _onDescriptionChanged,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryDropdown(vm),
                  const SizedBox(height: AppSpacing.md),
                  Text('Jumlah biaya', style: textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountController,
                    enabled: !vm.isSaving,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: _onAmountChanged,
                    validator: vm.validateAmount,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '0',
                      prefixText: 'Rp  ',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReceiptBox(vm),
                  const SizedBox(height: AppSpacing.md),
                  _buildHintBanner(textTheme),
                  if (vm.saveError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    ErrorBanner(message: vm.saveError!),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  LapakPrimaryButton(
                    label: vm.isSaving
                        ? 'Menyimpan...'
                        : vm.saveError != null
                            ? 'Coba simpan lagi'
                            : 'Simpan pengeluaran',
                    isLoading: vm.isSaving,
                    onPressed: _canSave && !vm.isSaving ? () => _save(vm) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHintBanner(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF92600A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Foto nota membantu pencocokan biaya.',
              style: textTheme.bodySmall?.copyWith(color: const Color(0xFF92600A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptBox(TambahPengeluaranViewModel vm) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: vm.isSaving
          ? null
          : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur foto nota belum tersedia di demo ini'),
                ),
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.camera_alt_outlined, size: 28, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            Text('Bukti nota (opsional)', style: textTheme.labelLarge),
            const SizedBox(height: 2),
            Text('Tekan untuk mengambil foto', style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(TambahPengeluaranViewModel vm) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori pengeluaran', style: textTheme.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<ExpenseCategory>(
          initialValue: vm.category,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: ExpenseCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat.label),
            );
          }).toList(),
          onChanged: vm.isSaving
              ? null
              : (cat) {
                  if (cat != null) vm.setCategory(cat);
                },
        ),
      ],
    );
  }
}
