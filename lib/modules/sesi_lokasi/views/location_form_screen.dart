import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/utils/validators.dart';
import 'package:lapakpindah/core/widgets/custom_button.dart';
import 'package:lapakpindah/core/widgets/custom_text_field.dart';
import 'package:lapakpindah/core/widgets/state_views.dart';
import 'package:lapakpindah/modules/sesi_lokasi/view_models/location_view_model.dart';
import 'package:lapakpindah/modules/sesi_lokasi/views/widgets/coordinate_section.dart';

/// Layar Form Tambah Lokasi (Figma M1·2, tanpa bagian GPS).
///
/// Workflow: isi form → validasi → simpan (loading) →
/// berhasil: kembali ke Daftar sambil membawa lokasi baru (result) /
/// gagal: pesan error, tetap di form.
class LocationFormScreen extends StatefulWidget {
  const LocationFormScreen({super.key});

  @override
  State<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends State<LocationFormScreen> {
  // ── Aturan isian ──
  static const int _nameMinLength = 3;
  static const int _nameMaxLength = 50;
  static const int _noteMaxLength = 100;

  // ── State form (M4: Form + GlobalKey + TextEditingController) ──
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    // Controller wajib dibuang saat layar ditutup agar tidak memory leak
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Validasi nama tempat ──
  // Satu aturan satu langkah; berhenti di aturan pertama yang dilanggar.
  // return null = valid, return 'pesan' = tidak valid (pesan tampil di bawah isian).
  String? _validateName(String? value) {
    const field = 'Nama tempat';

    // Aturan 1: wajib diisi & minimal 3 karakter
    final minError = Validators.minLength(
      value,
      _nameMinLength,
      fieldName: field,
    );
    if (minError != null) return minError;

    // Aturan 2: maksimal 50 karakter
    final maxError = Validators.maxLength(
      value,
      _nameMaxLength,
      fieldName: field,
    );
    if (maxError != null) return maxError;

    // Aturan 3: belum dipakai lokasi lain
    if (context.read<LocationViewModel>().isNameTaken(value!)) {
      return 'Nama tempat sudah dipakai lokasi lain';
    }
    return null;
  }

  // ── Event: tombol "Ambil lokasi saat ini" (GPS belum tersedia) ──
  void _showGpsNotReady() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur GPS belum tersedia. Lokasi tetap bisa disimpan tanpa koordinat.',
        ),
      ),
    );
  }

  // ── Event: tombol Simpan ditekan ──
  Future<void> _save() async {
    FocusScope.of(context).unfocus(); // tutup keyboard

    // 1. Validasi semua field; berhenti jika ada yang salah (tetap di form)
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // 2. Simpan lewat ViewModel (loading & error dikelola ViewModel)
    final saved = await context.read<LocationViewModel>().addLocation(
      _nameController.text,
      _noteController.text,
    );

    // 3. Setelah await, pastikan layar masih ada sebelum memakai context
    if (!mounted) return;

    // 4. Berhasil → tutup form dan kirim lokasi baru ke layar Daftar (result).
    //    Gagal → saved = null, pesan error tampil lewat ErrorBanner.
    if (saved != null) {
      Navigator.pop(context, saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          // Tombol kembali muncul otomatis; gaya dari appBarTheme
          appBar: AppBar(title: const Text('Tambah Lokasi')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Feedback gagal dari proses simpan (misal nama sudah ada)
                  if (vm.saveError != null) ...[
                    ErrorBanner(message: vm.saveError!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Isian 1: nama tempat (wajib)
                  LapakTextField(
                    label: 'Nama tempat',
                    hintText: 'Contoh: CFD Jam Gadang',
                    controller: _nameController,
                    enabled: !vm.isSaving,
                    textInputAction: TextInputAction.next,
                    validator: _validateName,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Isian 2: catatan (opsional)
                  LapakTextField(
                    label: 'Catatan (opsional)',
                    hintText: 'Contoh: Dekat pintu masuk, ramai pagi',
                    controller: _noteController,
                    enabled: !vm.isSaving,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    validator: (value) => Validators.maxLength(
                      value,
                      _noteMaxLength,
                      fieldName: 'Catatan',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bagian 3: koordinat (tampilan saja, GPS belum dipasang)
                  CoordinateSection(onTakeLocation: _showGpsNotReady),
                ],
              ),
            ),
          ),

          // ── Bar bawah: tombol Simpan (Figma: "Bar Bawah") ──
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: SafeArea(
              top: false,
              child: LapakPrimaryButton(
                label: 'Simpan lokasi',
                isLoading: vm.isSaving,
                onPressed: _save,
              ),
            ),
          ),
        );
      },
    );
  }
}
