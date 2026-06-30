import 'package:flutter/services.dart';

/// Sadece sayısal (ondalıklı) girişe izin verir: rakamlar ve tek bir ondalık
/// ayırıcı (virgül veya nokta). Harf ve diğer karakterleri engeller.
final class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter({this.maxFractionDigits = 2});

  final int maxFractionDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    final pattern = RegExp('^\\d*([.,]\\d{0,$maxFractionDigits})?\$');
    if (!pattern.hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }
}
