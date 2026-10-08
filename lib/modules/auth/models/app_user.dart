/// Model data pengguna (pemilik usaha).
///
/// PRD v2 hanya memiliki satu peran: pemilik usaha (owner/operator).
/// Login memakai nomor WhatsApp ATAU email.
/// PIN sengaja TIDAK disimpan di model agar tidak ikut tersebar ke UI.
class AppUser {
  final int id;

  /// Nama yang ditampilkan di sapaan dashboard, misal "Bang Radit".
  final String displayName;

  /// Nomor WhatsApp dalam format lokal, misal "081234567890".
  final String phone;

  /// Email dalam huruf kecil, misal "radit@gmail.com".
  final String email;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.email,
  });
}
