import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:intl/intl.dart';

final class MoneyUtils {
  MoneyUtils._();

  static double minorToDecimal(int amountMinor) => amountMinor / 100;

  static int decimalToMinor(double amount) => (amount * 100).round();

  static int? parseAmountToMinor(String? input) {
    if (input == null) {
      return null;
    }

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final normalized = _normalizeDecimalInput(trimmed);
    final value = double.tryParse(normalized);
    if (value == null) {
      return null;
    }

    return decimalToMinor(value);
  }

  static String formatAmountMinor(int amountMinor, CurrencyType currency) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return '${formatter.format(minorToDecimal(amountMinor))} ${currency.value}';
  }

  static String formatAmountMinorForExport(int amountMinor) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return formatter.format(minorToDecimal(amountMinor));
  }

  static String formatAmountInputFromMinor(int amountMinor) =>
      formatAmountInput(minorToDecimal(amountMinor));

  static String formatAmountInput(double amount) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return formatter.format(amount);
  }

  static String _normalizeDecimalInput(String input) {
    var value = input.replaceAll(' ', '');

    if (value.contains(',')) {
      return value.replaceAll('.', '').replaceAll(',', '.');
    }

    if (value.contains('.')) {
      final lastDot = value.lastIndexOf('.');
      final afterDot = value.substring(lastDot + 1);
      final dotCount = '.'.allMatches(value).length;
      final isUsDecimal = dotCount == 1 &&
          afterDot.isNotEmpty &&
          afterDot.length <= 2 &&
          RegExp(r'^\d+$').hasMatch(afterDot);

      if (isUsDecimal) {
        return value;
      }

      return value.replaceAll('.', '');
    }

    return value;
  }
}
