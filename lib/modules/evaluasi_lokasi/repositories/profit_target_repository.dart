import '../../../core/utils/validators.dart';
import '../models/profit_target.dart';

/// Target disimpan di memori dan dibagikan ke form serta dashboard.
class ProfitTargetRepository {
  // Tidak static: data hanya bertahan selama instance aplikasi ini hidup.
  final Map<String, ProfitTarget> _targets = {};
  int _nextId = 1;

  /// Read: kirim daftar target tanpa membuka Map internal untuk diubah.
  Future<List<ProfitTarget>> fetchAll() async =>
      List.unmodifiable(_targets.values);

  /// Create/Update: ID lokasi yang sama akan memakai ID target sebelumnya.
  Future<ProfitTarget> save(String locationId, int amount) async {
    // Pertahankan aturan minimum meski save dipanggil tanpa melalui form.
    if (locationId.isEmpty ||
        amount < Validators.minProfitTargetAmount ||
        amount > 999999999999) {
      throw ArgumentError('Data target tidak valid');
    }
    // Jeda singkat membuat state loading terlihat saat demo.
    await Future.delayed(const Duration(milliseconds: 250));
    // Kunci Map adalah ID lokasi: satu lokasi hanya punya satu target aktif.
    final target = ProfitTarget(
      id: _targets[locationId]?.id ?? _nextId++,
      locationId: locationId,
      amount: amount,
    );
    _targets[locationId] = target;
    return target;
  }

  /// Delete: hanya target yang dihapus, bukan lokasi atau data sesi.
  Future<void> delete(int id) async {
    _targets.removeWhere((_, target) => target.id == id);
  }
}
