/// Satu target laba per sesi yang dimiliki sebuah lokasi.
class ProfitTarget {
  const ProfitTarget({
    required this.id,
    required this.locationId,
    required this.amount,
  });
  final int id;
  final String locationId;
  final int amount;
}

/// Data navigasi: hasil yang benar-benar dikembalikan repository setelah simpan.
class SavedTarget {
  const SavedTarget({required this.target, required this.locationName});
  final ProfitTarget target;
  final String locationName;
}

/// Pilihan pengguna saat menutup halaman hasil penyimpanan.
enum TargetResultAction { dashboard, another }
