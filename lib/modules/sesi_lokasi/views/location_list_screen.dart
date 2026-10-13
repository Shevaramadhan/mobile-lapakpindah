import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/core/theme/app_spacing.dart';
import 'package:lapakpindah/core/utils/view_status.dart';
import 'package:lapakpindah/core/widgets/state_views.dart';
import 'package:lapakpindah/modules/sesi_lokasi/models/location.dart';
import 'package:lapakpindah/modules/sesi_lokasi/view_models/location_view_model.dart';
import 'package:lapakpindah/modules/sesi_lokasi/views/widgets/location_card.dart';
import 'package:lapakpindah/routes/app_routes.dart';

/// Layar Daftar Lokasi (tab "Lokasi", Figma M1·1).
///
/// Awal & akhir workflow Tambah Lokasi:
/// tombol + membuka form, lalu menerima lokasi baru sebagai hasil (result).
class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  @override
  void initState() {
    super.initState();
    // Muat daftar setelah frame pertama agar aman memakai context.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<LocationViewModel>().loadLocations(),
    );
  }

  // ── Event: tombol + ditekan → buka form, tunggu hasilnya ──
  Future<void> _openAddForm() async {
    // pushNamed mengembalikan Future yang selesai saat form ditutup.
    // Isinya = data yang dikirim form lewat Navigator.pop(context, data).
    final result = await Navigator.pushNamed(context, AppRoutes.locationForm);

    // Setelah await, pastikan layar masih ada sebelum memakai context
    if (!mounted) return;

    // Result: lokasi baru dari form → tampilkan pesan berhasil.
    // (null = pengguna kembali tanpa menyimpan, tidak perlu pesan)
    if (result is Location) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi "${result.name}" ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Lokasi'),
      ),
      // Consumer: bagian ini dibangun ulang setiap ViewModel memanggil notifyListeners()
      body: Consumer<LocationViewModel>(
        builder: (context, vm, _) {
          return switch (vm.status) {
            ViewStatus.loading => const LoadingView(
              message: 'Memuat lokasi...',
            ),
            ViewStatus.error => ErrorView(
              message: vm.errorMessage,
              onRetry: vm.loadLocations,
            ),
            ViewStatus.success =>
              vm.locations.isEmpty
                  // Feedback: daftar masih kosong
                  ? const EmptyView(
                      message: 'Belum ada lokasi.\nTekan + untuk menambah lokasi jualan.',
                      icon: Icons.location_off_outlined,
                    )
                  : _buildList(vm.locations),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah lokasi',
        onPressed: _openAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Daftar kartu lokasi ──
  Widget _buildList(List<Location> locations) {
    return ListView.separated(
      // Ruang bawah agar kartu terakhir tidak tertutup tombol +
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        88,
      ),
      // +1 untuk judul "Lokasi tersimpan (n)" di baris pertama
      itemCount: locations.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'Lokasi tersimpan (${locations.length})',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return LocationCard(location: locations[index - 1]);
      },
    );
  }
}
