import 'package:intl/intl.dart';

/// Mengubah angka menjadi format Rupiah. Dipakai bersama oleh semua modul.
///
/// Contoh: formatRupiah(400000) → "Rp 400.000"
String formatRupiah(num amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

/// Nominal ringkas untuk kartu evaluasi: Rp 450rb atau Rp 1,5jt.
String formatCompactRupiah(double value) => value.abs() >= 1000000
    ? 'Rp ${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')}jt'
    : 'Rp ${(value / 1000).round()}rb';
