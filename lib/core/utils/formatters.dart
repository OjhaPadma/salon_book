import 'package:intl/intl.dart';

abstract final class Formatters {
  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String inr(double amount) => _inr.format(amount);
}
