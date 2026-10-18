import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/rupiah_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/view_status.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../models/profit_target.dart';
import '../view_models/profit_target_view_model.dart';
import 'widgets/evaluation_widgets.dart';

/// FR-18: input -> validasi -> simpan -> feedback -> halaman hasil.
/// Target berlaku per sesi untuk lokasi yang dipilih.
class ProfitTargetFormScreen extends StatefulWidget {
  const ProfitTargetFormScreen({super.key});

  @override
  State<ProfitTargetFormScreen> createState() => _ProfitTargetFormScreenState();
}

class _ProfitTargetFormScreenState extends State<ProfitTargetFormScreen> {
  static const _ink = Color(0xFF111C2D);
  static const _muted = Color(0xFF565E74);
  static const _brown = Color(0xFF554336);
  static const _orange = Color(0xFF8D4B00);

  // State lokal untuk Form, teks, dialog kembali, dan feedback singkat.
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  bool _started = false;
  bool _leaving = false;
  bool _attempted = false;
  bool _showSuccess = false;
  String? _initialLocation;
  ProfitTarget? _savedDuringVisit;

  @override
  void initState() {
    super.initState();
    // Setiap ketikan di controller menjadi event perubahan state ViewModel.
    _amount.addListener(() {
      if (mounted) {
        context.read<ProfitTargetViewModel>().changeAmount(_amount.text);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Saat mengubah target, Evaluasi mengirim ID lokasi lewat route.
    final args = ModalRoute.of(context)?.settings.arguments;
    _initialLocation = args is String ? args : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(_initialLocation);
    });
  }

  /// Isi form dari repository; target lama ditampilkan saat mode ubah.
  Future<void> _load(String? location) async {
    final vm = context.read<ProfitTargetViewModel>();
    await vm.begin(location);
    if (!mounted) return;
    _amount.text = vm.amountText;
    setState(() {
      _attempted = false;
      _showSuccess = false;
    });
  }

  /// Cegah perubahan yang belum disimpan hilang tanpa konfirmasi.
  Future<void> _leave() async {
    final vm = context.read<ProfitTargetViewModel>();
    if (vm.isSaving || _leaving) return;
    _leaving = true;
    if (vm.dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Batalkan perubahan?'),
          content: const Text('Perubahan target belum disimpan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Lanjut mengisi'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buang perubahan'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (discard != true) {
        _leaving = false;
        return;
      }
    }
    if (mounted) Navigator.pop(context, _savedDuringVisit);
  }

  /// Event tombol Simpan: validasi -> simpan -> hasil -> Evaluasi.
  Future<void> _submit() async {
    final vm = context.read<ProfitTargetViewModel>();
    if (vm.isSaving) return;
    setState(() => _attempted = true);
    // Validator Flutter mengembalikan null jika semua field valid.
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final saved = await vm.save();
    if (!mounted || saved == null) return;
    _savedDuringVisit = saved.target;
    setState(() => _showSuccess = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    // Data SavedTarget dikirim ke layar hasil; aksi dari layar itu dikembalikan.
    final action = await Navigator.pushNamed<TargetResultAction>(
      context,
      AppRoutes.targetResult,
      arguments: saved,
    );
    if (!mounted) return;
    if (action == TargetResultAction.another) {
      _formKey.currentState?.reset();
      await _load(null);
    } else {
      Navigator.pop(context, saved.target);
    }
  }

  @override
  void dispose() {
    // Controller dilepas bersama layar agar listener tidak tertinggal.
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch membangun ulang UI ketika ViewModel memanggil notifyListeners().
    final vm = context.watch<ProfitTargetViewModel>();
    final amountInvalid =
        _attempted && Validators.profitTarget(vm.amountText) != null;
    final color = amountInvalid ? Theme.of(context).colorScheme.error : _brown;
    return PopScope<ProfitTarget>(
      canPop: !vm.isSaving && !vm.dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          title: const Text('Kelola Target Laba'),
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: vm.isSaving ? null : _leave,
            icon: const EvaluationAsset('form_back'),
          ),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: switch (vm.status) {
                // Feedback saat data form dimuat atau gagal dimuat.
                ViewStatus.loading => const LoadingView(
                  message: 'Memuat lokasi dan target...',
                ),
                ViewStatus.error => ErrorView(
                  message: 'Form gagal dimuat.',
                  onRetry: () => _load(_initialLocation),
                ),
                ViewStatus.success =>
                  vm.locations.isEmpty
                      ? _emptyLocations()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Pilih Lokasi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _brown,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Menu muncul di bawah field dengan ukuran
                                // pilihan yang sama ringkasnya seperti desain.
                                FormField<String>(
                                  key: ValueKey(vm.locationId),
                                  initialValue: vm.locationId,
                                  validator: (id) => id == null
                                      ? 'Pilih lokasi terlebih dahulu'
                                      : null,
                                  builder: (field) => LayoutBuilder(
                                    builder: (context, constraints) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PopupMenuButton<String>(
                                          enabled: !vm.isSaving,
                                          tooltip: 'Pilih lokasi jualan',
                                          position: PopupMenuPosition.under,
                                          offset: const Offset(0, 4),
                                          color: Colors.white,
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFDBC2B0),
                                            ),
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: constraints.maxWidth,
                                            maxWidth: constraints.maxWidth,
                                            maxHeight: 240,
                                          ),
                                          onSelected: (id) {
                                            field.didChange(id);
                                            vm.selectLocation(id);
                                            _amount.text = vm.amountText;
                                          },
                                          itemBuilder: (_) => [
                                            for (final location in vm.locations)
                                              PopupMenuItem<String>(
                                                value: location.id,
                                                height: 42,
                                                child: Row(
                                                  children: [
                                                    const EvaluationAsset(
                                                      'form_imgcontainer',
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        location.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _ink,
                                                        ),
                                                      ),
                                                    ),
                                                    if (field.value ==
                                                        location.id)
                                                      const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: _orange,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                          child: Container(
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 13,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: field.hasError
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                    : const Color(0xFFDBC2B0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const EvaluationAsset(
                                                  'form_imgcontainer',
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    vm.locations
                                                            .where(
                                                              (location) =>
                                                                  location.id ==
                                                                  field.value,
                                                            )
                                                            .firstOrNull
                                                            ?.name ??
                                                        'Pilih lokasi jualan',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: field.value == null
                                                          ? _muted
                                                          : _ink,
                                                    ),
                                                  ),
                                                ),
                                                const EvaluationAsset(
                                                  'form_chevron',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (field.hasError) ...[
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12,
                                            ),
                                            child: Text(
                                              field.errorText!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Nominal Target per Sesi',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      amountInvalid
                                          ? 'Wajib valid'
                                          : 'IDR (Rupiah)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // Formatter mengatur tampilan; validator
                                // menolak angka di bawah minimum.
                                TextFormField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: const [
                                    RupiahInputFormatter(),
                                  ],
                                  textInputAction: TextInputAction.done,
                                  enabled: !vm.isSaving,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Minimal 100.000',
                                    prefixText: 'Rp ',
                                    filled: true,
                                    fillColor: amountInvalid
                                        ? const Color(0xFFFFF7F9)
                                        : Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: _showSuccess
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF006948),
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  validator: Validators.profitTarget,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'PILIHAN CEPAT NOMINAL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .25,
                                    color: _muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Pilihan cepat memicu event yang sama seperti ketikan.
                                LayoutBuilder(
                                  builder: (context, constraints) => Row(
                                    children: [
                                      for (final entry in const {
                                        500000: '500rb',
                                        1000000: '1jt',
                                        2000000: '2jt',
                                        5000000: '5jt',
                                      }.entries) ...[
                                        if (entry.key != 500000)
                                          const SizedBox(width: 4),
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: ChoiceChip(
                                              label: Center(
                                                child: Text(
                                                  entry.value,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              selected:
                                                  Validators.parseRupiah(
                                                    vm.amountText,
                                                  ) ==
                                                  entry.key,
                                              showCheckmark: false,
                                              labelPadding: EdgeInsets.zero,
                                              padding: EdgeInsets.zero,
                                              onSelected: vm.isSaving
                                                  ? null
                                                  : (_) {
                                                      _amount.text =
                                                          RupiahInputFormatter.formatAmount(
                                                            entry.key,
                                                          );
                                                    },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Berlaku untuk',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _brown,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F3FF),
                                    border: Border.all(
                                      color: const Color(0xFFDBC2B0),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Setiap sesi jualan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (amountInvalid) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F3FF),
                                      border: Border.all(
                                        color: const Color(0xFFDBC2B0),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: _muted,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Target minimal Rp 100.000 untuk setiap sesi jualan.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _brown,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                // Feedback gagal dari repository; isian tetap ada.
                                if (vm.saveError != null) ...[
                                  const SizedBox(height: 16),
                                  ErrorBanner(message: vm.saveError!),
                                ],
                                // Feedback singkat sebelum halaman hasil.
                                if (_showSuccess) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006948),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Target berhasil disimpan!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Baru saja',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
              },
            ),
          ),
        ),
        bottomNavigationBar:
            vm.status == ViewStatus.success && vm.locations.isNotEmpty
            ? SafeArea(
                top: false,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      // Event utama workflow FR-18.
                      child: LapakPrimaryButton(
                        label: vm.isSaving ? 'Menyimpan...' : 'Simpan Target',
                        iconWidget: const EvaluationAsset('form_save'),
                        isLoading: vm.isSaving,
                        onPressed: _submit,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  /// Feedback saat belum ada lokasi, plus jalan ke form tambah lokasi.
  Widget _emptyLocations() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const EmptyView(
        message: 'Belum ada lokasi. Tambahkan lokasi jualan sebelum mengatur target.',
        icon: Icons.location_off_outlined,
      ),
      FilledButton.icon(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.locationForm);
          if (mounted) await _load(null);
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Tambah Lokasi'),
      ),
    ],
  );
}
