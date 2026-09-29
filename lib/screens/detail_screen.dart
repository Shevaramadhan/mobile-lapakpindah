import 'package:flutter/material.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';

/// Detail menerima Item dari Home, lalu menerima kembali catatan dari Form.
class DetailScreen extends StatefulWidget {
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.storefront, size: 56),
          ),
          const SizedBox(height: 20),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(item.subtitle),
          const SizedBox(height: 16),
          Text(item.description),
          const Divider(height: 32),
          Text(
            _catatan == null
                ? 'Belum ada catatan.'
                : 'Catatan: $_catatan',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
        ],
      ),
    );
  }
}
