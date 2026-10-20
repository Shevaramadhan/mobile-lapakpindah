/// Kumpulan aturan validasi form yang dipakai ulang (M4: Form Validation).
///
/// Aturan validator di Flutter:
/// - return null    → input VALID
/// - return 'pesan' → input TIDAK VALID, pesan tampil di bawah field
class Validators {
  Validators._();
  static const minProfitTargetAmount = 100000;

  /// Nominal rupiah bulat; menerima 50000 atau format Indonesia 50.000.
  static int? parseRupiah(String value) {
    final input = value.trim();
    if (!RegExp(r'^(\d+|\d{1,3}(\.\d{3})+)$').hasMatch(input)) return null;
    return int.tryParse(input.replaceAll('.', ''));
  }

  static String? profitTarget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal target wajib diisi';
    }
    final amount = parseRupiah(value);
    if (amount == null) return 'Masukkan nominal rupiah berupa angka bulat';
    if (amount < minProfitTargetAmount) {
      return 'Target laba minimal Rp 100.000 per sesi';
    }
    if (amount > 999999999999) return 'Nominal maksimal Rp 999.999.999.999';
    return null;
  }

  /// Wajib diisi (tidak boleh kosong atau hanya spasi).
  static String? requiredField(
    String? value, {
    String fieldName = 'Field ini',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Format email, contoh "nama@gmail.com".
  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Nomor WhatsApp ATAU email (dipakai di Login).
  /// - Ada "@"  → dicek sebagai email.
  /// - Tanpa "@" → dicek sebagai nomor: 10–14 digit, boleh diawali "+",
  ///   spasi dan strip diabaikan (contoh "0812-3456-7890").
  static String? phoneOrEmail(String? value) {
    final requiredError = requiredField(
      value,
      fieldName: 'Nomor WA atau email',
    );
    if (requiredError != null) return requiredError;

    final input = value!.trim();
    if (input.contains('@')) return email(input);

    final digits = input.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\+?\d{10,14}$').hasMatch(digits)) {
      return 'Nomor WA tidak valid (10–14 digit)';
    }
    return null;
  }

  /// PIN wajib tepat 6 digit angka.
  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'PIN wajib diisi';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'PIN harus 6 digit angka';
    return null;
  }

  /// Minimal [min] karakter (misal untuk catatan atau nama).
  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Field ini',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Maksimal [max] karakter. Kosong dianggap valid (untuk isian opsional).
  static String? maxLength(
    String? value,
    int max, {
    String fieldName = 'Field ini',
  }) {
    if (value != null && value.trim().length > max) {
      return '$fieldName maksimal $max karakter';
    }
    return null;
  }
}
