import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class AppBadgeStyle {
  const AppBadgeStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}

enum AppStatusTone {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

extension AppStatusToneStyle on AppStatusTone {
  AppBadgeStyle get badgeStyle {
    switch (this) {
      case AppStatusTone.success:
        return AppBadgeStyle(
          backgroundColor: const Color(0xFFECFDF5),
          borderColor: ColorName.success.withValues(alpha: 0.22),
          textColor: const Color(0xFF047857),
        );
      case AppStatusTone.warning:
        return AppBadgeStyle(
          backgroundColor: const Color(0xFFFFFBEB),
          borderColor: ColorName.warning.withValues(alpha: 0.28),
          textColor: const Color(0xFFB45309),
        );
      case AppStatusTone.error:
        return AppBadgeStyle(
          backgroundColor: const Color(0xFFFEF2F2),
          borderColor: ColorName.error.withValues(alpha: 0.22),
          textColor: const Color(0xFFDC2626),
        );
      case AppStatusTone.info:
        return AppBadgeStyle(
          backgroundColor: const Color(0xFFEFF6FF),
          borderColor: ColorName.info.withValues(alpha: 0.22),
          textColor: const Color(0xFF2563EB),
        );
      case AppStatusTone.neutral:
        return const AppBadgeStyle(
          backgroundColor: Color(0xFFF3F4F6),
          borderColor: AppUiTokens.borderStrong,
          textColor: AppUiTokens.textSecondary,
        );
      case AppStatusTone.primary:
        return AppBadgeStyle(
          backgroundColor: AppUiTokens.accentSoft,
          borderColor: ColorName.primary.withValues(alpha: 0.18),
          textColor: ColorName.primaryDark,
        );
    }
  }
}

const appNeutralBadgeStyle = AppBadgeStyle(
  backgroundColor: AppUiTokens.surfaceMuted,
  borderColor: AppUiTokens.border,
  textColor: AppUiTokens.textSecondary,
);

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    required this.style,
    this.compact = false,
    super.key,
  });

  final String label;
  final AppBadgeStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        compact ? AppUiTokens.space8 : AppUiTokens.space12;

    return Wrap(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: style.borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppUiTokens.space4,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: style.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 12 : null,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
