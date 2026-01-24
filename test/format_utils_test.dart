import 'package:flutter_test/flutter_test.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  test('FormatUtils.formatDate formats correctly', () async {
    // Mon, 17 December 2001
    final date = DateTime(2001, 12, 17);
    final formatted = FormatUtils.formatDate(date);
    expect(formatted, 'Mon, 17 December 2001');
  });

  test('FormatUtils.formatNumber formats correctly', () {
    // 1,000,000.00
    final number = 1000000.0;
    final formatted = FormatUtils.formatNumber(number);
    expect(formatted, '1,000,000.00');

    // 100.00
    final number2 = 100.0;
    final formatted2 = FormatUtils.formatNumber(number2);
    expect(formatted2, '100.00');
  });
}
