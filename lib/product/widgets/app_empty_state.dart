import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.compact = false,
    this.actionLabel,
    this.onAction,
    this.actionFilled = false,
    this.iconColor,
    super.key,
  });

  final String message;
  final String? title;
  final IconData icon;
  final bool compact;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionFilled;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppUiTokens.space12,
          vertical: AppUiTokens.space12,
        ),
        decoration: BoxDecoration(
          color: AppUiTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          border: Border.all(color: AppUiTokens.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor?.withValues(alpha: 0.55) ??
                  AppUiTokens.textMuted.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppUiTokens.space8),
            Expanded(
              child: Text(
                title ?? message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppUiTokens.textSecondary,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppUiTokens.surface,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            border: Border.all(color: AppUiTokens.border),
          ),
          child: Icon(
            icon,
            size: 28,
            color: iconColor?.withValues(alpha: 0.7) ??
                AppUiTokens.textMuted.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppUiTokens.space16),
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (message.isNotEmpty) const SizedBox(height: AppUiTokens.space8),
        ],
        if (message.isNotEmpty)
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppUiTokens.textSecondary,
                  height: 1.45,
                ),
          ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppUiTokens.space16),
          if (actionFilled)
            FilledButton.icon(
              onPressed: onAction,
              style: AppInteractiveTheme.filledButtonStyle(
                FilledButton.styleFrom(
                  backgroundColor: ColorName.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel!),
            )
          else
            OutlinedButton(
              onPressed: onAction,
              style: AppInteractiveTheme.outlinedButtonStyle(
                OutlinedButton.styleFrom(
                  foregroundColor: AppUiTokens.textPrimary,
                  side: const BorderSide(color: AppUiTokens.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space16,
                    vertical: AppUiTokens.space12,
                  ),
                ),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ],
    );
  }
}

class AppTableEmptyState extends StatelessWidget {
  const AppTableEmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.actionFilled = false,
    this.verticalPadding = AppUiTokens.space24,
    super.key,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionFilled;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppUiTokens.space24,
        vertical: verticalPadding,
      ),
      child: Center(
        child: AppEmptyState(
          message: message,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          actionFilled: actionFilled,
        ),
      ),
    );
  }
}
