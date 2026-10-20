import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapakpindah/core/utils/rupiah_input_formatter.dart';

void main() {
  const formatter = RupiahInputFormatter();

  TextEditingValue value(String text, int cursor) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: cursor),
  );

  test('menambahkan titik ribuan saat mengetik dan menempel nominal', () {
    final typed = formatter.formatEditUpdate(value('', 0), value('50000', 5));
    expect(typed.text, '50.000');
    expect(typed.selection.baseOffset, 6);

    final pasted = formatter.formatEditUpdate(
      value('', 0),
      value('Rp 1.250.000', 12),
    );
    expect(pasted.text, '1.250.000');
    expect(pasted.selection.baseOffset, 9);
  });

  test('posisi kursor tetap mengikuti digit yang diedit di tengah', () {
    final updated = formatter.formatEditUpdate(
      value('50.000', 1),
      value('510.000', 2),
    );
    expect(updated.text, '510.000');
    expect(updated.selection.baseOffset, 2);
    expect(RupiahInputFormatter.formatAmount(100000), '100.000');
  });
}
