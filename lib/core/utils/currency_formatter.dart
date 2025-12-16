import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();
  static String toRupiah(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  static String formatNumber(num number) {
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  static int parseToInteger(String formattedString) {
    final String cleanString = formattedString.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }
}