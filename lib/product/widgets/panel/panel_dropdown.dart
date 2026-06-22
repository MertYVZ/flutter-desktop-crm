import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/shared/widgets/anchored_overlay.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

/// Minimal desktop dropdown aligned with [PanelTextField] styling.
class PanelDropdown<T> extends StatefulWidget {
  const PanelDropdown({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
    this.enabled = true,
    this.compact = false,
    super.key,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool enabled;
  final bool compact;

  @override
  State<PanelDropdown<T>> createState() => _PanelDropdownState<T>();
}

class _PanelDropdownState<T> extends State<PanelDropdown<T>> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int? _hoveredIndex;

  bool get _canInteract => widget.enabled && widget.onChanged != null;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PanelDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isOpen) {
      return;
    }
    _overlayEntry?.markNeedsBuild();
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

  void _selectItem(T item) {
    widget.onChanged?.call(item);
    _removeOverlay();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _triggerKey.currentContext!.findRenderObject()! as RenderBox;
    final anchorSize = renderBox.size;
    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);
    const itemHeight = 44.0;
    const maxMenuHeight = 240.0;

    final idealHeight =
        (widget.items.length * itemHeight).clamp(itemHeight, maxMenuHeight);
    final menuHeight = anchoredOverlayMenuHeight(
      anchorOffset: anchorOffset,
      anchorSize: anchorSize,
      screenHeight: screenSize.height,
      preferredHeight: idealHeight,
      minHeight: itemHeight,
    );

    return OverlayEntry(
      builder: (overlayContext) {
        final menu = Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
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
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.items.length,
                itemExtent: itemHeight,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = item == widget.value;
                  final isHovered = _hoveredIndex == index;

                  return _DropdownMenuItemTile(
                    label: widget.itemLabel(item),
                    isSelected: isSelected,
                    isHovered: isHovered,
                    onHover: (hovering) {
                      _hoveredIndex = hovering ? index : null;
                      _overlayEntry?.markNeedsBuild();
                    },
                    onTap: () => _selectItem(item),
                  );
                },
              ),
            ),
          ),
        );

        return AnchoredOverlayLayout(
          anchorOffset: anchorOffset,
          anchorSize: anchorSize,
          screenSize: screenSize,
          menuWidth: anchorSize.width,
          menuHeight: menuHeight,
          onDismiss: _removeOverlay,
          child: menu,
        );
      },
    );
  }

  bool get _hasValidSelection =>
      widget.items.any((item) => item == widget.value);

  String get _displayText {
    if (_hasValidSelection) {
      return widget.itemLabel(widget.value as T);
    }

    return widget.hint ?? widget.label;
  }

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = !_hasValidSelection;
    final fieldHeight = widget.compact ? 38.0 : 48.0;
    final horizontalPadding =
        widget.compact ? AppUiTokens.space12 : AppUiTokens.space16;
    final fontSize = widget.compact ? 14.0 : 15.0;

    final trigger = MouseRegion(
      key: _triggerKey,
      cursor: _canInteract
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: fieldHeight,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppUiTokens.surface
                  : AppUiTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(
                color: _isOpen ? ColorName.primary : AppUiTokens.border,
                width: _isOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isPlaceholder
                          ? AppUiTokens.textMuted
                          : AppUiTokens.textPrimary,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: widget.compact ? 18 : 20,
                    color: _canInteract
                        ? AppUiTokens.textSecondary
                        : AppUiTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    if (widget.compact) {
      return trigger;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        trigger,
      ],
    );
  }
}

class _DropdownMenuItemTile extends StatelessWidget {
  const _DropdownMenuItemTile({
    required this.label,
    required this.isSelected,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppUiTokens.accentSoft
        : isHovered
            ? AppUiTokens.surfaceMuted
            : AppUiTokens.surface;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiTokens.space16,
          ),
          color: backgroundColor,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? ColorName.primary
                        : AppUiTokens.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: ColorName.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
