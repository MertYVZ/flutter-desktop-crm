import 'package:flutter/material.dart';

/// Shared spacing, colors and radii for minimal panel UI.
abstract final class AppUiTokens {
  static const pageBackground = Color(0xFFF4F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFD1D5DB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const accentSoft = Color(0xFFFFF4E8);

  static const sidebarWidth = 256.0;
  static const topBarHeight = 56.0;
  static const authCardMaxWidth = 420.0;

  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;

  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space40 = 40.0;
}
