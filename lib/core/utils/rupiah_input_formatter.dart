import 'package:flutter/services.dart';

/// Menampilkan pemisah ribuan saat nominal Rupiah diketik.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  static String formatAmount(int amount) => formatDigits(amount.toString());

  static String formatDigits(String value) {
    // Simpan hanya digit; titik lama dari input atau paste akan dibentuk ulang.
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatDigits(newValue.text);
    // Hitung digit sebelum kursor agar titik baru tidak memindahkan posisi edit.
    final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    var offset = 0;
    var digitCount = 0;
    while (offset < formatted.length && digitCount < digitsBeforeCursor) {
      if (RegExp(r'\d').hasMatch(formatted[offset])) digitCount++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
