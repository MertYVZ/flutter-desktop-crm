import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats monetary input using Turkish locale: `1.250,50`.
final class TurkishAmountInputFormatter extends TextInputFormatter {
  const TurkishAmountInputFormatter({this.maxFractionDigits = 2});

  final int maxFractionDigits;

  static final NumberFormat _integerFormatter =
      NumberFormat('#,##0', 'tr_TR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText = newValue.text;
    if (rawText.isEmpty) {
      return newValue;
    }

    final hasTrailingComma = rawText.endsWith(',');
    final commaIndex = rawText.lastIndexOf(',');

    var integerRaw = (commaIndex >= 0 ? rawText.substring(0, commaIndex) : rawText)
        .replaceAll(RegExp(r'[^\d]'), '');
    var fractionRaw = commaIndex >= 0
        ? rawText.substring(commaIndex + 1).replaceAll(RegExp(r'[^\d]'), '')
        : '';

    if (integerRaw.length > 1) {
      integerRaw = integerRaw.replaceFirst(RegExp('^0+'), '');
    }

    if (fractionRaw.length > maxFractionDigits) {
      fractionRaw = fractionRaw.substring(0, maxFractionDigits);
    }

    if (integerRaw.isEmpty && fractionRaw.isEmpty && !hasTrailingComma) {
      return oldValue;
    }

    final formattedInteger = integerRaw.isEmpty
        ? '0'
        : _integerFormatter.format(int.parse(integerRaw));

    final formatted = switch ((hasTrailingComma, fractionRaw.isEmpty)) {
      (true, true) => '$formattedInteger,',
      (_, false) => '$formattedInteger,$fractionRaw',
      _ => formattedInteger,
    };

    final cursorPosition = _resolveCursorPosition(
      oldValue: oldValue,
      newValue: newValue,
      formatted: formatted,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  int _resolveCursorPosition({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
    required String formatted,
  }) {
    final oldCursor = oldValue.selection.baseOffset;
    if (oldCursor >= oldValue.text.length) {
      return formatted.length;
    }

    final digitsBeforeCursor = oldValue.text
        .substring(0, oldCursor.clamp(0, oldValue.text.length))
        .replaceAll(RegExp(r'[^\d]'), '')
        .length;

    var digitCount = 0;
    for (var index = 0; index < formatted.length; index++) {
      if (RegExp(r'\d').hasMatch(formatted[index])) {
        digitCount++;
      }

      if (digitCount >= digitsBeforeCursor) {
        return index + 1;
      }
    }

    if (newValue.text.endsWith(',') && formatted.endsWith(',')) {
      return formatted.length;
    }

    return formatted.length;
  }
}
