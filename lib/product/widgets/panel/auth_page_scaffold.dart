import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/auth_brand_panel.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

/// Responsive split auth layout for desktop CRM login flows.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.badge,
    this.maxWidth = 440,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? badge;
  final double maxWidth;

  static const _compactBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUiTokens.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < _compactBreakpoint;
          if (isCompact) {
            return _CompactAuthLayout(
              title: title,
              subtitle: subtitle,
              badge: badge,
              maxWidth: maxWidth,
              child: child,
            );
          }
          return _SplitAuthLayout(
            title: title,
            subtitle: subtitle,
            badge: badge,
            maxWidth: maxWidth,
            child: child,
          );
        },
      ),
    );
  }
}

class _SplitAuthLayout extends StatelessWidget {
  const _SplitAuthLayout({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.maxWidth,
    this.badge,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? badge;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 46,
          child: AuthBrandPanel(),
        ),
        Expanded(
          flex: 54,
          child: Center(
            child: PanelFormScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppUiTokens.space40,
                  vertical: AppUiTokens.space32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: _AuthFormPanel(
                    title: title,
                    subtitle: subtitle,
                    badge: badge,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactAuthLayout extends StatelessWidget {
  const _CompactAuthLayout({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.maxWidth,
    this.badge,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? badge;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PanelFormScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppUiTokens.space24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth + 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthBrandHeader(),
                const SizedBox(height: AppUiTokens.space24),
                PanelSurface(
                  padding: const EdgeInsets.all(AppUiTokens.space32),
                  child: _AuthFormPanel(
                    title: title,
                    subtitle: subtitle,
                    badge: badge,
                    showDivider: false,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.badge,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? badge;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null) ...[
          _AuthBadge(label: badge!),
          const SizedBox(height: AppUiTokens.space16),
        ],
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            color: AppUiTokens.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: AppUiTokens.textSecondary,
            height: 1.5,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: AppUiTokens.space32),
          const Divider(height: 1, color: AppUiTokens.border),
        ],
        const SizedBox(height: AppUiTokens.space32),
        child,
      ],
    );
  }
}

class _AuthBadge extends StatelessWidget {
  const _AuthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppUiTokens.space12,
          vertical: AppUiTokens.space4,
        ),
        decoration: BoxDecoration(
          color: AppUiTokens.accentSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: ColorName.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ColorName.primaryDark,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
