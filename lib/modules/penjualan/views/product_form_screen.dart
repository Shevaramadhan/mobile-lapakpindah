import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lapakpindah/modules/penjualan/models/product.dart';
import 'package:lapakpindah/modules/penjualan/view_models/sale_view_model.dart';

/// Form tambah/ubah produk, termasuk harga khusus untuk lokasi sesi (FR-13).
class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _specialPriceController = TextEditingController();

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.sellingPrice.toString();
      final special = context.read<SaleViewModel>().specialPriceFor(product.id);
      _specialPriceController.text = special?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _specialPriceController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) =>
      value == null || value.trim().isEmpty ? 'Nama produk wajib diisi' : null;

  String? _validatePrice(String? value) {
    final price = int.tryParse(value ?? '');
    return price == null || price <= 0 ? 'Masukkan harga lebih dari Rp0' : null;
  }

  // Harga khusus boleh kosong (memakai harga normal).
  String? _validateSpecialPrice(String? value) {
    if (value == null || value.isEmpty) return null;
    final price = int.tryParse(value);
    return price == null || price <= 0 ? 'Harga khusus harus lebih dari Rp0' : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SaleViewModel>();
    final price = int.parse(_priceController.text);
    final special = int.tryParse(_specialPriceController.text);

    final saved = _isEdit
        ? vm.updateProduct(
            id: widget.product!.id,
            name: _nameController.text,
            sellingPrice: price,
            specialPrice: special,
          )
        : vm.addProduct(
            name: _nameController.text,
            sellingPrice: price,
            specialPrice: special,
          );

    if (saved) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Gagal menyimpan produk')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 52,
                color: Color(0xFFE87924),
              ),
              const SizedBox(height: 16),
              Text(
                'Informasi Produk',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                maxLength: 80,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Contoh: Es Teh Manis',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Harga Jual',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePrice,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Harga Khusus di ${SaleViewModel.demoLocationName} (opsional)',
                  helperText: 'Kosongkan untuk memakai harga jual normal',
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),
                validator: _validateSpecialPrice,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Produk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE87924),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
