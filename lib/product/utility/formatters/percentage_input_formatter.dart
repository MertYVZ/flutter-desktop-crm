import 'package:flutter/services.dart';

/// Sadece tam sayı yüzde değerine izin verir ve değeri [min]–[max] aralığında
/// tutar (varsayılan 1–100). Harf, ondalık ve aralık dışı değerleri engeller.
final class PercentageInputFormatter extends TextInputFormatter {
  const PercentageInputFormatter({this.min = 1, this.max = 100});

  final int min;
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return oldValue;
    }

    final value = int.tryParse(digits);
    if (value == null || value > max) {
      return oldValue;
    }

    final normalized = value.toString();
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}
