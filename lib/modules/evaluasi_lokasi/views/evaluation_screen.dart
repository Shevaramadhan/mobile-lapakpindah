import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/format_rupiah.dart';
import '../../../core/utils/view_status.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../models/profit_target.dart';
import '../view_models/evaluation_view_model.dart';
import 'widgets/evaluation_widgets.dart';
import 'widgets/ranking_card_content.dart';
import 'widgets/trend_card_content.dart';

/// FR-17 menampilkan evaluasi; kartu Kelola Target membuka workflow FR-18.
/// Nilai dihitung ViewModel dari repository, lalu View menggambar hasilnya.
class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key, this.isActive = true});
  final bool isActive;

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  static const _ink = Color(0xFF1E293B);
  static const _muted = Color(0xFF9CA3AF);
  static const _orange = Color(0xFFB45309);
  static const _green = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant EvaluationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _scheduleLoad();
  }

  void _scheduleLoad() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && widget.isActive) context.read<EvaluationViewModel>().load();
  });

  /// Navigasi ke form dan muat ulang target setelah form selesai.
  Future<void> _openTarget([String? locationId]) async {
    // ID lokasi menjadi argumen form; target tersimpan kembali sebagai result.
    final result = await Navigator.pushNamed<ProfitTarget>(
      context,
      AppRoutes.targetForm,
      arguments: locationId,
    );
    if (!mounted) return;
    final vm = context.read<EvaluationViewModel>();
    if (result != null) vm.selectLocation(result.locationId);
    // Ambil ulang target agar kartu Evaluasi menampilkan hasil terbaru.
    await vm.load();
  }

  /// Event hapus: konfirmasi pengguna, hapus lewat ViewModel, tampilkan pesan.
  Future<void> _delete(ProfitTarget target, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus target laba?'),
        content: Text(
          'Target $name akan dihapus. Data evaluasi tidak berubah.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final success = await context.read<EvaluationViewModel>().deleteTarget(
      target,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Target berhasil dihapus'
              : 'Target gagal dihapus. Coba lagi.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();
    final vm = context.watch<EvaluationViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Row(
          children: [
            EvaluationAsset('dashboard_brand'),
            SizedBox(width: 7),
            Text(
              'LapakPindah',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: 'Profil',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBC2B0)),
                ),
                child: const Center(
                  child: EvaluationAsset('dashboard_profile_figma'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: switch (vm.status) {
              ViewStatus.loading => const LoadingView(
                message: 'Memuat evaluasi...',
              ),
              ViewStatus.error => ErrorView(
                message: vm.errorMessage,
                onRetry: vm.load,
              ),
              ViewStatus.success => RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Bang Radit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            'Evaluasi Lokasi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _rankingCard(vm),
                    const SizedBox(height: 6),
                    _chartCard(vm),
                    const SizedBox(height: 6),
                    _targetCard(vm),
                    const SizedBox(height: 8),
                    _manageCard(vm),
                  ],
                ),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    Color background = Colors.white,
    Color border = const Color(0xFFF3F4F6),
  }) => Container(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x15000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: child,
  );

  /// Kartu peringkat dan tren dipisah agar alur target tetap mudah dibaca.
  Widget _rankingCard(EvaluationViewModel vm) =>
      _card(child: RankingCardContent(vm: vm));

  Widget _chartCard(EvaluationViewModel vm) =>
      _card(child: TrendCardContent(vm: vm));

  /// Desain status target; tercapai jika rata-rata laba >= target per sesi.
  Widget _targetCard(EvaluationViewModel vm) {
    final id = vm.selectedLocationId;
    final target = id == null ? null : vm.targetFor(id);
    final average = id == null ? null : vm.averageFor(id);
    final achieved =
        target != null && average != null && average >= target.amount;
    final name = id == null
        ? ''
        : vm.locations.firstWhere((l) => l.id == id).name;
    return _card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Target Laba per Sesi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
                if (target != null && average != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: achieved
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      achieved ? 'Tercapai' : 'Belum tercapai',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: achieved ? _green : _orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (target == null)
              const Text(
                'Belum ada target untuk lokasi ini.',
                style: TextStyle(fontSize: 13, color: _muted),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    average == null
                        ? 'Belum ada riwayat'
                        : formatRupiah(average),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'dari ${formatCompactRupiah(target.amount.toDouble())}',
                        style: const TextStyle(fontSize: 10, color: _muted),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: average == null
                    ? 0
                    : (average / target.amount).clamp(0, 1),
                minHeight: 8,
                backgroundColor: const Color(0xFFF3F4F6),
                color: _orange,
                borderRadius: BorderRadius.circular(999),
                semanticsLabel: 'Pencapaian target laba per sesi',
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: vm.deleting ? null : () => _openTarget(id),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text(
                      'Ubah Target',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: vm.deleting ? null : () => _delete(target, name),
                    icon: const Icon(Icons.delete_outline, size: 15),
                    label: Text(
                      vm.deleting ? 'Menghapus...' : 'Hapus Target',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Pintu masuk FR-18: tap kartu membuka form target.
  Widget _manageCard(EvaluationViewModel vm) => _card(
    background: const Color(0xFFFFFBEB),
    border: const Color(0xFFFFEDD5),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openTarget(vm.selectedLocationId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.track_changes, color: _orange, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola Target',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  Text(
                    'Atur target baru untuk pantau performa.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
