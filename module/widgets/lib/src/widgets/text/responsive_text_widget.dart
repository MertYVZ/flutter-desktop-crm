import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  const ResponsiveText({
    required this.text,
    super.key,
    this.style,
    this.maxLines = 1,
    this.textAlign,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor,
    this.maxLinesToDisplay,
    this.locale,
    this.strutStyle,
    this.minFontSize,
  });
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLinesToDisplay;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final double? minFontSize;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      maxLines: maxLinesToDisplay ?? maxLines,
      minFontSize: minFontSize ?? 16, // İstediğiniz minimum font boyutu
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
    );
  }
}
