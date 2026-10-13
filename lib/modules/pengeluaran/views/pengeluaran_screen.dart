import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/utils/format_rupiah.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/core/widgets/state_views.dart';
import 'package:lapakpindah/modules/pengeluaran/models/expense.dart';
import 'package:lapakpindah/modules/pengeluaran/view_models/pengeluaran_view_model.dart';
import 'package:lapakpindah/modules/pengeluaran/view_models/tambah_pengeluaran_view_model.dart';
import 'package:lapakpindah/modules/pengeluaran/views/tambah_pengeluaran_screen.dart';
import 'package:lapakpindah/modules/pengeluaran/views/widgets/active_session_bar.dart';
import 'package:lapakpindah/modules/pengeluaran/views/widgets/expense_card.dart';
import 'package:lapakpindah/modules/pengeluaran/views/widgets/expense_limit_card.dart';

class PengeluaranScreen extends StatefulWidget {
  const PengeluaranScreen({super.key, this.onNavigateToLocationTab});
  final VoidCallback? onNavigateToLocationTab;
  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  /// 0 = Sesi Aktif, 1 = Riwayat Semua Sesi (FR-10).
  int _viewIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PengeluaranViewModel>();
      vm.loadData();
      vm.loadHistory();
    });
  }

  Future<void> _openAddForm() async {
    final vm = context.read<PengeluaranViewModel>();
    final sessionId = vm.activeSessionId;
    if (sessionId == null) return;
    final wasLimitReached = vm.isLimitReached;
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(builder: (_) => ChangeNotifierProvider(
        create: (_) => TambahPengeluaranViewModel(sessionId: sessionId),
        child: TambahPengeluaranScreen(sessionId: sessionId),
      )),
    );
    if (!mounted || result == null) return;
    vm.applyNewExpense(result);
    vm.loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text('Pengeluaran ditambahkan!', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
    // FR-09: peringatan bila pengeluaran baru membuat total melewati batas.
    if (!wasLimitReached && vm.isLimitReached) {
      _showLimitWarningDialog();
    }
  }

  /// Dialog peringatan saat batas pengeluaran tercapai/terlampaui (FR-09).
  void _showLimitWarningDialog() {
    final vm = context.read<PengeluaranViewModel>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Color(0xFFB91C1C), size: 40),
        title: const Text('Batas pengeluaran tercapai'),
        content: Text(
          'Total pengeluaran sesi ini sudah mencapai '
          '${formatRupiah(vm.totalExpense)}, melewati batas '
          '${formatRupiah(vm.limit?.limitAmount ?? 0)}. '
          'Pertimbangkan untuk menekan biaya berikutnya.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  /// Dialog ubah batas pengeluaran harian (FR-08).
  Future<void> _editLimit(double currentLimit) async {
    final vm = context.read<PengeluaranViewModel>();
    final controller = TextEditingController(
      text: currentLimit.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    final newValue = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah batas pengeluaran'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Batas harian',
              prefixText: 'Rp  ',
            ),
            validator: (value) {
              final parsed = double.tryParse((value ?? '').replaceAll('.', ''));
              if (parsed == null || parsed <= 0) {
                return 'Batas harus lebih dari Rp 0';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(
                  dialogContext,
                  double.parse(controller.text.replaceAll('.', '')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newValue == null || !mounted) return;
    final ok = await vm.setLimit(newValue);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
        content: Text(
          ok
              ? 'Batas pengeluaran diubah menjadi ${formatRupiah(newValue)}'
              : 'Gagal mengubah batas pengeluaran.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Pengeluaran')),
      body: Consumer<PengeluaranViewModel>(
        builder: (context, vm, _) {
          if (vm.status == ViewStatus.loading) {
            return const LoadingView(message: 'Memuat pengeluaran...');
          }
          if (vm.status == ViewStatus.error) {
            return ErrorView(message: vm.errorMessage, onRetry: vm.loadData);
          }
          return Column(
            children: [
              _buildViewSwitcher(),
              Expanded(
                child: _viewIndex == 0
                    ? (vm.hasActiveSession ? _buildWithSession(vm) : _buildNoSession(vm))
                    : _buildHistory(vm),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<PengeluaranViewModel>(
        builder: (context, vm, _) {
          if (vm.status != ViewStatus.success || !vm.hasActiveSession) return const SizedBox.shrink();
          return FloatingActionButton(
            heroTag: 'fab-pengeluaran',
            tooltip: 'Tambah pengeluaran',
            onPressed: _openAddForm,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  /// Pemilih tampilan: Sesi Aktif vs Riwayat (FR-10).
  Widget _buildViewSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Sesi Aktif'), icon: Icon(Icons.play_circle_outline, size: 18)),
          ButtonSegment(value: 1, label: Text('Riwayat'), icon: Icon(Icons.history, size: 18)),
        ],
        selected: {_viewIndex},
        onSelectionChanged: (s) => setState(() => _viewIndex = s.first),
        showSelectedIcon: false,
      ),
    );
  }

  // ── Filter kategori (FR-07) ──
  Widget _buildCategoryFilter(PengeluaranViewModel vm) {
    final selected = vm.selectedCategory;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: selected == null,
            onSelected: (_) => vm.setCategoryFilter(null),
          ),
          for (final cat in ExpenseCategory.values) ...[
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: Text(cat.label),
              selected: selected == cat,
              onSelected: (_) => vm.setCategoryFilter(cat),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWithSession(PengeluaranViewModel vm) {
    final session = vm.activeSession!;
    final limitAmount = vm.limit?.limitAmount ?? 0;
    final filtered = vm.filteredExpenses;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 96),
      children: [
        ActiveSessionBar(session: session),
        const SizedBox(height: AppSpacing.md),
        if (vm.hasLimit)
          ExpenseLimitCard(
            totalExpense: vm.totalExpense,
            limitAmount: limitAmount,
            remainingLimit: vm.remainingLimit,
            usagePercent: vm.usagePercent,
            isLimitReached: vm.isLimitReached,
            onEditLimit: () => _editLimit(limitAmount),
          ),
        const SizedBox(height: AppSpacing.md),
        _buildCategoryFilter(vm),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daftar pengeluaran', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text('${filtered.length} item', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                'Tidak ada pengeluaran untuk kategori ini.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (final expense in filtered) ...[ExpenseCard(expense: expense), const SizedBox(height: AppSpacing.sm)],
      ],
    );
  }

  // ── Riwayat seluruh sesi (FR-10) ──
  Widget _buildHistory(PengeluaranViewModel vm) {
    final textTheme = Theme.of(context).textTheme;
    if (vm.historyStatus == ViewStatus.loading) {
      return const LoadingView(message: 'Memuat riwayat...');
    }
    if (vm.historyStatus == ViewStatus.error) {
      return ErrorView(message: vm.errorMessage, onRetry: vm.loadHistory);
    }
    if (vm.historyGroups.isEmpty) {
      return Center(
        child: Text('Belum ada riwayat pengeluaran.', style: textTheme.bodySmall),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 96),
      children: [
        for (final group in vm.historyGroups) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.session.locationName, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(_formatDate(group.session.openTime), style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(formatRupiah(group.total), style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final expense in group.expenses) ...[ExpenseCard(expense: expense), const SizedBox(height: AppSpacing.sm)],
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')} WIB';
  }

  Widget _buildNoSession(PengeluaranViewModel vm) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC7D2FE))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Belum ada sesi berjalan', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF3730A3))), const SizedBox(height: 4), Text('Pengeluaran hanya bisa dicatat saat lapak dibuka.', style: textTheme.bodySmall?.copyWith(color: const Color(0xFF3730A3)))])),
        const SizedBox(height: 72),
        Center(child: Container(width: 80, height: 80, decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle), child: Icon(Icons.receipt_long_outlined, size: 36, color: colorScheme.primary))),
        const SizedBox(height: AppSpacing.lg),
        Text('Belum ada sesi berjalan', textAlign: TextAlign.center, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sm),
        Text('Buka lapak di tab Lokasi untuk mulai\nmencatat pengeluaran.', textAlign: TextAlign.center, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(onPressed: widget.onNavigateToLocationTab, child: const Text('Ke tab Lokasi')),
      ],
    );
  }
}
