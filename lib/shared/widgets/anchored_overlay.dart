import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';

/// Positions [child] relative to an anchor using global coordinates.
///
/// Unlike [CompositedTransformFollower], this is not clipped by scroll views
/// or other ancestors of the anchor widget.
class AnchoredOverlayLayout extends StatelessWidget {
  const AnchoredOverlayLayout({
    required this.anchorOffset,
    required this.anchorSize,
    required this.screenSize,
    required this.menuWidth,
    required this.menuHeight,
    required this.onDismiss,
    required this.child,
    this.gap = AppUiTokens.space4,
    this.alignToAnchorEnd = false,
    super.key,
  });

  final Offset anchorOffset;
  final Size anchorSize;
  final Size screenSize;
  final double menuWidth;
  final double menuHeight;
  final VoidCallback onDismiss;
  final Widget child;
  final double gap;
  final bool alignToAnchorEnd;

  bool get _openUpward {
    final spaceBelow =
        screenSize.height - anchorOffset.dy - anchorSize.height - gap;
    final spaceAbove = anchorOffset.dy - gap;
    return spaceBelow < menuHeight && spaceAbove > spaceBelow;
  }

  @override
  Widget build(BuildContext context) {
    final top = _openUpward
        ? anchorOffset.dy - menuHeight - gap
        : anchorOffset.dy + anchorSize.height + gap;

    final maxLeft = screenSize.width - menuWidth - AppUiTokens.space8;
    const minLeft = AppUiTokens.space8;
    final clampedMaxLeft =
        maxLeft < minLeft ? minLeft : maxLeft;
    final rawLeft = alignToAnchorEnd
        ? anchorOffset.dx + anchorSize.width - menuWidth
        : anchorOffset.dx;
    final left = rawLeft.clamp(minLeft, clampedMaxLeft);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: menuWidth,
          height: menuHeight,
          child: child,
        ),
      ],
    );
  }
}

/// Computes a menu height that fits content first, then the viewport.
double anchoredOverlayMenuHeight({
  required Offset anchorOffset,
  required Size anchorSize,
  required double screenHeight,
  required double preferredHeight,
  double gap = AppUiTokens.space4,
  double minHeight = 44,
}) {
  final spaceBelow =
      screenHeight - anchorOffset.dy - anchorSize.height - gap;
  final spaceAbove = anchorOffset.dy - gap;
  final openUpward = spaceBelow < preferredHeight && spaceAbove > spaceBelow;
  final available = openUpward ? spaceAbove : spaceBelow;

  if (available <= minHeight) {
    return minHeight;
  }

  return preferredHeight.clamp(minHeight, available);
}
