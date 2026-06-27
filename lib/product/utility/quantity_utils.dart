import 'package:intl/intl.dart';

final class QuantityUtils {
  QuantityUtils._();

  static final NumberFormat _displayFormat = NumberFormat('#,##0.##', 'tr_TR');
  static final NumberFormat _exportFormat = NumberFormat('#,##0.##', 'tr_TR');

  static double? parseQuantity(String? input) {
    if (input == null) {
      return null;
    }

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final normalized = _normalizeDecimalInput(trimmed);
    return double.tryParse(normalized);
  }

  static String formatQuantity(double quantity) => _displayFormat.format(quantity);

  static String formatKg(double quantity) => '${_displayFormat.format(quantity)} KG';

  static String formatForExport(double quantity) =>
      _exportFormat.format(quantity);

  static String formatQuantityInput(double quantity) =>
      _displayFormat.format(quantity);

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
