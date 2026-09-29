import 'package:flutter/material.dart';
import '../utils/validators.dart';

/// Form catatan yang mengembalikan teks ke Detail menggunakan Navigator.pop().
class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _catatanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tulis catatan untuk lapak ini...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.minLength(
                  value,
                  5,
                  fieldName: 'Catatan',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
