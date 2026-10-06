import 'package:flutter/material.dart';
import '../../models/lapak.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Detail sebuah lapak.
///
/// Data diterima lewat `arguments` named route (M4: Passing Arguments):
///   Navigator.pushNamed(context, AppRoutes.detail, arguments: lapak);
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // ── Buka form catatan, TUNGGU hasilnya, lalu tampilkan (M4: Returning Data) ──
  Future<void> _bukaFormCatatan() async {
    // Route dari `routes: {}` bertipe dynamic, jadi hasilnya di-cast ke String?
    // (bukan pushNamed<String>, yang akan menyebabkan type error).
    final hasil =
        await Navigator.pushNamed(context, AppRoutes.catatanForm) as String?;

    // null jika pengguna menekan tombol kembali tanpa menyimpan
    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan lapak berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Baca argument yang dikirim layar sebelumnya ──
    final item = ModalRoute.of(context)?.settings.arguments as Lapak?;

    // Argument tidak dikirim → tampilkan pesan, jangan crash
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Lapak')),
        body: const Center(child: Text('Data lapak tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: AppColors.surfaceCard,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Judul & tanggal lapak ──
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Keterangan lapak ──
          Text(item.description),
          const Divider(height: 32),

          // ── Catatan yang dikembalikan dari form ──
          Text(
            _catatan == null
                ? 'Belum ada catatan untuk lokasi ini.'
                : 'Catatan Evaluasi:\n$_catatan',
            style: TextStyle(
              color: _catatan == null ? Colors.grey : AppColors.textPrimary,
              fontStyle: _catatan == null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
        ],
      ),
    );
  }
}
