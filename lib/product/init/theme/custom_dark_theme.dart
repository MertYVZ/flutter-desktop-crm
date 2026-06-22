// ignore_for_file: deprecated_member_use, document_ignores

import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/custom_color_scheme.dart';
import 'package:Ok/product/init/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

final class CustomDarkTheme implements CustomTheme {
  @override
  TypographySystem get typography => const _DarkTypographySystem();

  ThemeData get _themeData => ThemeData(
        useMaterial3: true,
        colorScheme: CustomColorScheme.darkColorScheme,
        filledButtonTheme: FilledButtonThemeData(
          style: AppInteractiveTheme.filledButtonStyle(
            FilledButton.styleFrom(),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppInteractiveTheme.outlinedButtonStyle(
            OutlinedButton.styleFrom(),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppInteractiveTheme.textButtonStyle(
            TextButton.styleFrom(),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: AppInteractiveTheme.iconButtonStyle(
            IconButton.styleFrom(),
          ),
        ),
      );

  @override
  ThemeData get themeData => _themeData.copyWith(
        textTheme: _buildTextTheme(),
      );

  @override
  TextTheme getResponsiveTextTheme(BuildContext context) {
    final baseTextTheme = _buildTextTheme();
    return _applyResponsiveScaling(context, baseTextTheme);
  }

  /// Build base text theme with color scheme integration
  TextTheme _buildTextTheme() {
    const colorScheme = CustomColorScheme.darkColorScheme;

    return TextTheme(
      displayLarge: typography.displayLarge(color: colorScheme.onSurface),
      displayMedium: typography.displayMedium(color: colorScheme.onSurface),
      displaySmall: typography.displaySmall(color: colorScheme.onSurface),
      headlineLarge: typography.headlineLarge(color: colorScheme.onSurface),
      headlineMedium: typography.headlineMedium(color: colorScheme.onSurface),
      headlineSmall: typography.headlineSmall(color: colorScheme.onSurface),
      titleLarge: typography.titleLarge(color: colorScheme.onSurface),
      titleMedium: typography.titleMedium(color: colorScheme.onSurface),
      titleSmall: typography.titleSmall(color: colorScheme.onSurface),
      bodyLarge: typography.bodyLarge(color: colorScheme.onSurface),
      bodyMedium: typography.bodyMedium(color: colorScheme.onSurface),
      bodySmall: typography.bodySmall(color: colorScheme.onSurface),
      labelLarge: typography.labelLarge(color: colorScheme.onSurface),
      labelMedium: typography.labelMedium(color: colorScheme.onSurface),
      labelSmall: typography.labelSmall(color: colorScheme.onSurface),
    );
  }

  /// Apply responsive scaling based on screen size and accessibility
  TextTheme _applyResponsiveScaling(
      BuildContext context, TextTheme baseTextTheme) {
    final scaleFactor = _getResponsiveScale(context);
    final accessibilityScale = MediaQuery.of(context).textScaleFactor;
    final totalScale = scaleFactor * accessibilityScale;

    return baseTextTheme.apply(
      fontSizeFactor: totalScale,
    );
  }

  /// Get responsive scale factor based on screen size
  double _getResponsiveScale(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isMobile) return 1;
    if (ResponsiveBreakpoints.of(context).isTablet) return 1.1;
    if (ResponsiveBreakpoints.of(context).isDesktop) return 1.2;
    return 1.3; // 4K screens
  }
}

/// Dark theme specific typography system
class _DarkTypographySystem extends TypographySystem {
  const _DarkTypographySystem();
}
