import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/shared/widgets/anchored_overlay.dart';
import 'package:flutter/material.dart';

class AppActionMenuItem {
  const AppActionMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    this.showDividerAfter = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;
  final bool showDividerAfter;
}

/// Custom overflow / action menu with icon+label rows and hover states.
class AppActionMenu extends StatefulWidget {
  const AppActionMenu({
    required this.items,
    this.tooltip,
    this.icon = Icons.more_vert_rounded,
    this.iconColor = AppUiTokens.textSecondary,
    this.iconSize = 24,
    this.minWidth = 196,
    this.enabled = true,
    super.key,
  });

  final List<AppActionMenuItem> items;
  final String? tooltip;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double minWidth;
  final bool enabled;

  @override
  State<AppActionMenu> createState() => _AppActionMenuState();
}

class _AppActionMenuState extends State<AppActionMenu> {
  static const double _itemHeight = 40;
  static const double _verticalPadding = AppUiTokens.space4;

  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int? _hoveredIndex;

  bool get _canInteract => widget.enabled && widget.items.isNotEmpty;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppActionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _toggleOverlay() {
    if (!_canInteract) {
      return;
    }

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _hoveredIndex = null;
      });
    }
  }

  void _handleItemTap(AppActionMenuItem item) {
    if (!item.enabled || item.isLoading) {
      return;
    }
    _removeOverlay();
    item.onTap();
  }

  double _menuHeight(int itemCount, int dividerCount) {
    return _verticalPadding * 2 +
        itemCount * _itemHeight +
        dividerCount * 1;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _triggerKey.currentContext!.findRenderObject()! as RenderBox;
    final anchorSize = renderBox.size;
    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);
    final menuWidth = widget.minWidth;

    final dividerCount =
        widget.items.where((item) => item.showDividerAfter).length;
    final preferredHeight = _menuHeight(widget.items.length, dividerCount);
    final menuHeight = anchoredOverlayMenuHeight(
      anchorOffset: anchorOffset,
      anchorSize: anchorSize,
      screenHeight: screenSize.height,
      preferredHeight: preferredHeight,
      minHeight: _itemHeight + _verticalPadding * 2,
    );

    return OverlayEntry(
      builder: (overlayContext) {
        final menu = Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              border: Border.all(color: AppUiTokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < widget.items.length; index++) ...[
                      _ActionMenuItemTile(
                        item: widget.items[index],
                        isHovered: _hoveredIndex == index,
                        onHover: (hovering) {
                          _hoveredIndex = hovering ? index : null;
                          _overlayEntry?.markNeedsBuild();
                        },
                        onTap: () => _handleItemTap(widget.items[index]),
                      ),
                      if (widget.items[index].showDividerAfter)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppUiTokens.border,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        return AnchoredOverlayLayout(
          anchorOffset: anchorOffset,
          anchorSize: anchorSize,
          screenSize: screenSize,
          menuWidth: menuWidth,
          menuHeight: menuHeight,
          alignToAnchorEnd: true,
          onDismiss: _removeOverlay,
          child: menu,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger = IconButton(
      key: _triggerKey,
      tooltip: widget.tooltip,
      onPressed: _canInteract ? _toggleOverlay : null,
      style: AppInteractiveTheme.iconButtonStyle(
        IconButton.styleFrom(
          foregroundColor: widget.iconColor,
          disabledForegroundColor: AppUiTokens.textMuted,
        ),
      ),
      icon: Icon(widget.icon, size: widget.iconSize),
    );

    return trigger;
  }
}

class _ActionMenuItemTile extends StatelessWidget {
  const _ActionMenuItemTile({
    required this.item,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  final AppActionMenuItem item;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  bool get _isInteractive => item.enabled && !item.isLoading;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !_isInteractive
        ? AppUiTokens.surface
        : isHovered
            ? AppUiTokens.surfaceMuted
            : AppUiTokens.surface;

    final iconColor = !_isInteractive
        ? AppUiTokens.textMuted
        : AppUiTokens.textSecondary;
    final labelColor = !_isInteractive
        ? AppUiTokens.textMuted
        : AppUiTokens.textPrimary;

    return MouseRegion(
      onEnter: (_) {
        if (_isInteractive) {
          onHover(true);
        }
      },
      onExit: (_) => onHover(false),
      cursor: _isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _isInteractive ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: _AppActionMenuState._itemHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiTokens.space12,
          ),
          color: backgroundColor,
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: item.isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Icon(
                        item.icon,
                        size: 20,
                        color: iconColor,
                      ),
              ),
              const SizedBox(width: AppUiTokens.space12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
