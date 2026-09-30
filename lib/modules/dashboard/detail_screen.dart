import 'package:flutter/material.dart';
import '../../models/lapak.dart'; // Sesuaikan path jika berbeda
import '../../routes/app_routes.dart'; // Sesuaikan path jika berbeda
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class DetailScreen extends StatefulWidget {
  // Data yang DITERIMA dari Home
  final Lapak item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // Fungsi buka form, TUNGGU hasilnya, lalu tampilkan
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return; // null jika pengguna menekan tombol back tanpa simpan

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan lapak berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.item"
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: AppColors.surfaceCard,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
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
          Text(item.description),
          
          const Divider(height: 32),
          
          // Teks untuk menampilkan catatan yang dikembalikan
          Text(
            _catatan == null ? 'Belum ada catatan untuk lokasi ini.' : 'Catatan Evaluasi:\n$_catatan',
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