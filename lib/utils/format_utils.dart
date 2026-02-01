import 'package:intl/intl.dart';

class FormatUtils {
  /// Formats date to "Mon, 17 December 2001"
  static String formatDate(DateTime date) {
    return DateFormat('EEE, d MMMM yyyy').format(date);
  }

  static String formatSimpleDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Formats number to "1,000,000.00"
  static String formatNumber(double number) {
    return NumberFormat('#,##0.00').format(number);
  }
}
