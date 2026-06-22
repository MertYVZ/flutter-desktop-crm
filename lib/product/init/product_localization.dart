import 'package:Ok/product/utility/constants/enums/locales.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@immutable

/// Product Localization Manager
final class ProductLocalization extends EasyLocalization {
  ProductLocalization({
    required super.child,
    super.key,
  }) : super(
          supportedLocales: _supportedItems,
          path: _translationPath,
          useOnlyLangCode: true,
        );

  static final List<Locale> _supportedItems = [
    Locales.en.locale,
    Locales.tr.locale,
  ];

  static const String _translationPath = 'assets/translations';

  /// Update Language Function
  static Future<void> updateLanguage(
          {required BuildContext context, required Locales value}) =>
      context.setLocale(value.locale);
}
