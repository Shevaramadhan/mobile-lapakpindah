import 'package:intl/intl.dart';

/// Mengubah angka menjadi format Rupiah. Dipakai bersama oleh semua modul.
///
/// Contoh: formatRupiah(400000) → "Rp 400.000"
String formatRupiah(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
