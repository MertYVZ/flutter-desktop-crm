import 'package:flutter/material.dart';

/// Project Supported Locales
enum Locales {
  en(locale: Locale('en', 'US')),
  tr(locale: Locale('tr', 'TR'));

  const Locales({required this.locale});

  final Locale locale;
}
