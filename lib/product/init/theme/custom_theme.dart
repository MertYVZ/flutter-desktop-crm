import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class CustomTheme {
  ThemeData get themeData;

  /// Typography system with OOP approach
  TypographySystem get typography;

  /// Get responsive text theme based on current context
  TextTheme getResponsiveTextTheme(BuildContext context);
}

/// Typography System - OOP implementation
abstract class TypographySystem {
  const TypographySystem();

  /// Font family for the typography system
  String get fontFamily => 'Instrument Sans';

  /// Font weights with semantic naming
  FontWeight get thin => FontWeight.w100;
  FontWeight get extraLight => FontWeight.w200;
  FontWeight get light => FontWeight.w300;
  FontWeight get regular => FontWeight.w400;
  FontWeight get medium => FontWeight.w500;
  FontWeight get semiBold => FontWeight.w600;
  FontWeight get bold => FontWeight.w700;
  FontWeight get extraBold => FontWeight.w800;
  FontWeight get black => FontWeight.w900;

  /// Line heights for different text types
  double get lineHeightTight => 1.2;
  double get lineHeightNormal => 1.5;
  double get lineHeightRelaxed => 1.6;
  double get lineHeightLoose => 1.8;

  /// Letter spacing values
  double get letterSpacingTight => -0.5;
  double get letterSpacingNormal => 0;
  double get letterSpacingWide => 0.5;
  double get letterSpacingWider => 1;

  /// Base text style factory
  TextStyle baseTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.instrumentSans(
      fontSize: fontSize,
      fontWeight: fontWeight ?? regular,
      height: height ?? lineHeightNormal,
      letterSpacing: letterSpacing ?? letterSpacingNormal,
      color: ColorName.white,
    );
  }

  /// Display styles
  TextStyle displayLarge({Color? color}) => baseTextStyle(
        fontSize: 48,
        fontWeight: bold,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
        color: color,
      );

  TextStyle displayMedium({Color? color}) => baseTextStyle(
        fontSize: 40,
        fontWeight: bold,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
        color: color,
      );

  TextStyle displaySmall({Color? color}) => baseTextStyle(
        fontSize: 32,
        fontWeight: bold,
        height: lineHeightTight,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  /// Headline styles
  TextStyle headlineLarge({Color? color}) => baseTextStyle(
        fontSize: 24,
        fontWeight: bold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  TextStyle headlineMedium({Color? color}) => baseTextStyle(
        fontSize: 20,
        fontWeight: bold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  TextStyle headlineSmall({Color? color}) => baseTextStyle(
        fontSize: 18,
        fontWeight: bold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  /// Title styles
  TextStyle titleLarge({Color? color}) => baseTextStyle(
        fontSize: 16,
        fontWeight: semiBold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  TextStyle titleMedium({Color? color}) => baseTextStyle(
        fontSize: 14,
        fontWeight: semiBold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  TextStyle titleSmall({Color? color}) => baseTextStyle(
        fontSize: 12,
        fontWeight: semiBold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  /// Body styles
  TextStyle bodyLarge({Color? color}) => baseTextStyle(
        fontSize: 18,
        fontWeight: regular,
        height: lineHeightRelaxed,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  TextStyle bodyMedium({Color? color}) => baseTextStyle(
        fontSize: 16,
        fontWeight: regular,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  TextStyle bodySmall({Color? color}) => baseTextStyle(
        fontSize: 14,
        fontWeight: regular,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: color,
      );

  /// Label styles
  TextStyle labelLarge({Color? color}) => baseTextStyle(
        fontSize: 14,
        fontWeight: medium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
        color: color,
      );

  TextStyle labelMedium({Color? color}) => baseTextStyle(
        fontSize: 12,
        fontWeight: medium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
        color: color,
      );

  TextStyle labelSmall({Color? color}) => baseTextStyle(
        fontSize: 10,
        fontWeight: medium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWider,
        color: color,
      );
}
