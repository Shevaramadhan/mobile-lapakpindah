import 'package:intl/intl.dart';
String formatRupiah(num amount) => NumberFormat.currency(locale:'id_ID',symbol:'Rp ',decimalDigits:0).format(amount);
