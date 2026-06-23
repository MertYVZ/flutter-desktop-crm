import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';

/// Minimal white surface with a subtle border instead of heavy shadow.
class PanelSurface extends StatelessWidget {
  const PanelSurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppUiTokens.space32),
    this.maxWidth,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppUiTokens.radiusLg);

    final surface = Container(
      width: maxWidth,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppUiTokens.surface,
        borderRadius: radius,
        border: Border.all(color: AppUiTokens.border),
      ),
      child: child,
    );

    if (maxWidth == null) {
      return surface;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: surface,
    );
  }
}
