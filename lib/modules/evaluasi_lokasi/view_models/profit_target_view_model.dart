import 'package:flutter/foundation.dart';

import '../../../core/utils/rupiah_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/view_status.dart';
import '../../sesi_lokasi/models/location.dart';
import '../../sesi_lokasi/repositories/location_repository.dart';
import '../models/profit_target.dart';
import '../repositories/profit_target_repository.dart';

/// State dan aksi form FR-18: View -> ViewModel -> Repository.
/// notifyListeners memberi tahu form saat input, loading, atau error berubah.
class ProfitTargetViewModel extends ChangeNotifier {
  ProfitTargetViewModel({
    required this.repository,
    required this.locationsRepository,
  });
  final ProfitTargetRepository repository;
  final LocationRepository locationsRepository;

  // State yang dibaca form: data, pilihan pengguna, proses, dan pesan gagal.
  ViewStatus status = ViewStatus.loading;
  List<Location> locations = [];
  List<ProfitTarget> _targets = [];
  String? locationId;
  String amountText = '';
  String? saveError;
  bool isSaving = false;
  bool dirty = false;
  bool _disposed = false;
  int _request = 0;
  bool get isValid =>
      locationId != null && Validators.profitTarget(amountText) == null;

  /// Muat lokasi dan target lama; ID awal berasal dari layar Evaluasi.
  Future<void> begin(String? initialLocationId) async {
    // Nomor request mencegah hasil pemuatan lama menimpa form yang dibuka belakangan.
    final request = ++_request;
    status = ViewStatus.loading;
    saveError = null;
    dirty = false;
    locationId = null;
    amountText = '';
    notifyListeners();
    try {
      final loadedLocations = await locationsRepository.fetchAll();
      final loadedTargets = await repository.fetchAll();
      if (_disposed || request != _request) return;
      locations = loadedLocations;
      _targets = loadedTargets;
      if (locations.any((l) => l.id == initialLocationId)) {
        locationId = initialLocationId;
        amountText = _existingAmount(initialLocationId!);
      }
      status = ViewStatus.success;
    } catch (_) {
      if (_disposed || request != _request) return;
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  String _existingAmount(String id) {
    final amount = _targets
        .where((t) => t.locationId == id)
        .firstOrNull
        ?.amount;
    return amount == null ? '' : RupiahInputFormatter.formatAmount(amount);
  }

  /// Event dropdown: pilih lokasi dan tampilkan target yang sudah ada.
  void selectLocation(String? id) {
    if (isSaving) return;
    locationId = id;
    amountText = id == null ? '' : _existingAmount(id);
    dirty = true;
    saveError = null;
    notifyListeners();
  }

  /// Event input: salin teks dari controller ke state ViewModel.
  void changeAmount(String text) {
    if (isSaving || text == amountText) return;
    amountText = text;
    dirty = true;
    saveError = null;
    // context.watch pada View akan membangun ulang UI setelah state berubah.
    notifyListeners();
  }

  /// Simpan jika valid; kembalikan data hasil, atau null jika gagal.
  Future<SavedTarget?> save() async {
    if (isSaving || !isValid) return null;
    // Salin input sebelum await agar data hasil sesuai transaksi yang disimpan.
    final location = locations.where((l) => l.id == locationId).firstOrNull;
    if (location == null) return null;
    // Tampilan `100.000` diubah menjadi integer 100000 sebelum disimpan.
    final amount = Validators.parseRupiah(amountText)!;
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      // Repository mengembalikan target tersimpan; hasil ini dikirim ke layar sukses.
      final target = await repository.save(location.id, amount);
      dirty = false;
      return SavedTarget(target: target, locationName: location.name);
    } catch (_) {
      // Form tetap terbuka dan isian tidak dibuang agar bisa dicoba lagi.
      saveError =
          'Target gagal disimpan. Isian tetap tersimpan di form; coba lagi.';
      return null;
    } finally {
      isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
