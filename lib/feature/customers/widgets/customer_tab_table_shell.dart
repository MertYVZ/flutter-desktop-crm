import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Lightweight content shell for customer detail sections — no nested panels.
class CustomerSectionContent extends StatelessWidget {
  const CustomerSectionContent({
    required this.isLoading,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
    this.emptyActionLabel,
    this.onEmptyAction,
    super.key,
  });

  final bool isLoading;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppUiTokens.space32),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppEmptyState(
                message: emptyMessage,
                actionLabel: emptyActionLabel,
                onAction: onEmptyAction,
              ),
              if (isLoading)
                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppUiTokens.textMuted.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, thickness: 1, color: AppUiTokens.border),
              children[i],
            ],
          ],
        ),
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppUiTokens.surface.withValues(alpha: 0.72),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CustomerListRow extends StatelessWidget {
  const CustomerListRow({
    required this.title,
    this.subtitle,
    this.trailing = const [],
    this.onTap,
    super.key,
  });

  final String title;
  final Widget? subtitle;
  final List<Widget> trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppUiTokens.space12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppUiTokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppUiTokens.space4),
                  DefaultTextStyle(
                    style: const TextStyle(
                      color: AppUiTokens.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing.isNotEmpty) ...[
            const SizedBox(width: AppUiTokens.space12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: trailing,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class CustomerRowMeta extends StatelessWidget {
  const CustomerRowMeta({
    required this.items,
    super.key,
  });

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final visible = items.where((item) => item.trim().isNotEmpty).toList();
    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(visible.join(' · '));
  }
}

class CustomerSectionActionButton extends StatelessWidget {
  const CustomerSectionActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color ?? AppUiTokens.textPrimary,
              ),
            )
          : Icon(icon, size: 20, color: color ?? AppUiTokens.textPrimary),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

@Deprecated('Use CustomerSectionActionButton')
typedef CustomerTabActionButton = CustomerSectionActionButton;

String truncateText(String? value, {int maxLength = 100}) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }

  final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return '${normalized.substring(0, maxLength)}...';
}
