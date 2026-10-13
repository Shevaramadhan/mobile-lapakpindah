import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PengeluaranViewModel>().loadData(),
    );
  }

  Future<void> _openAddForm() async {
    final vm = context.read<PengeluaranViewModel>();
    final sessionId = vm.activeSessionId;
    if (sessionId == null) return;
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(builder: (_) => ChangeNotifierProvider(
        create: (_) => TambahPengeluaranViewModel(sessionId: sessionId),
        child: TambahPengeluaranScreen(sessionId: sessionId),
      )),
    );
    if (!mounted || result == null) return;
    vm.applyNewExpense(result);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Pengeluaran')),
      body: Consumer<PengeluaranViewModel>(
        builder: (context, vm, _) {
          return switch (vm.status) {
            ViewStatus.loading => const LoadingView(message: 'Memuat pengeluaran...'),
            ViewStatus.error => ErrorView(message: vm.errorMessage, onRetry: vm.loadData),
            ViewStatus.success => vm.hasActiveSession ? _buildWithSession(vm) : _buildNoSession(vm),
          };
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

  Widget _buildWithSession(PengeluaranViewModel vm) {
    final session = vm.activeSession!;
    final limitAmount = vm.limit?.limitAmount ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 96),
      children: [
        ActiveSessionBar(session: session),
        const SizedBox(height: AppSpacing.md),
        if (vm.hasLimit) ExpenseLimitCard(totalExpense: vm.totalExpense, limitAmount: limitAmount, remainingLimit: vm.remainingLimit, usagePercent: vm.usagePercent, isLimitReached: vm.isLimitReached),
        const SizedBox(height: AppSpacing.md),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Daftar pengeluaran', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)), Text('${vm.expenses.length} item', style: Theme.of(context).textTheme.bodySmall)]),
        const SizedBox(height: AppSpacing.sm),
        for (final expense in vm.expenses) ...[ExpenseCard(expense: expense), const SizedBox(height: AppSpacing.sm)],
      ],
    );
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
