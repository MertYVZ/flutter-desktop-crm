import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/shared/widgets/anchored_overlay.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

const _itemHeight = 44.0;
const _searchSectionHeight = 72.0;
const _dividerHeight = 1.0;
const _emptyListHeight = 44.0;
const _maxListHeight = 264.0;

class CustomerSearchDropdown extends StatefulWidget {
  const CustomerSearchDropdown({
    required this.customers,
    required this.selectedCustomerId,
    required this.onChanged,
    this.enabled = true,
    this.allowNullSelection = false,
    this.placeholder = 'Müşteri seçiniz',
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool allowNullSelection;
  final String placeholder;

  @override
  State<CustomerSearchDropdown> createState() =>
      _CustomerSearchDropdownState();
}

class _CustomerSearchDropdownState extends State<CustomerSearchDropdown> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int? _hoveredIndex;
  String _searchQuery = '';

  bool get _canInteract => widget.enabled;

  Customer? get _selectedCustomer {
    if (widget.selectedCustomerId == null) {
      return null;
    }

    for (final customer in widget.customers) {
      if (customer.id == widget.selectedCustomerId) {
        return customer;
      }
    }

    return null;
  }

  List<Customer> get _filteredCustomers {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.customers;
    }

    return widget.customers
        .where((customer) => customer.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomerSearchDropdown oldWidget) {
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
      _searchQuery = '';
      _showOverlay();
    }
  }

  void _showOverlay() {
    final anchorContext = _triggerKey.currentContext;
    if (anchorContext == null) {
      return;
    }

    final renderBox = anchorContext.findRenderObject()! as RenderBox;
    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;
    final screenSize = MediaQuery.sizeOf(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final filtered = _filteredCustomers;
        final itemCount = filtered.length + (widget.allowNullSelection ? 1 : 0);
        final listContentHeight = itemCount == 0
            ? _emptyListHeight
            : itemCount * _itemHeight;
        final idealListHeight =
            listContentHeight.clamp(_emptyListHeight, _maxListHeight);
        final contentHeight =
            _searchSectionHeight + _dividerHeight + idealListHeight;
        final menuHeight = anchoredOverlayMenuHeight(
          anchorOffset: anchorOffset,
          anchorSize: anchorSize,
          screenHeight: screenSize.height,
          preferredHeight: contentHeight,
          minHeight: _searchSectionHeight + _dividerHeight + _itemHeight,
        );
        final listAreaHeight =
            menuHeight - _searchSectionHeight - _dividerHeight;

        return AnchoredOverlayLayout(
          anchorOffset: anchorOffset,
          anchorSize: anchorSize,
          screenSize: screenSize,
          menuWidth: anchorSize.width,
          menuHeight: menuHeight,
          onDismiss: _removeOverlay,
          child: Material(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppUiTokens.space12),
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(
                        color: AppUiTokens.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Müşteri ara...',
                        hintStyle: TextStyle(
                          color: AppUiTokens.textMuted,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppUiTokens.textMuted,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppUiTokens.space12,
                          vertical: AppUiTokens.space8,
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _hoveredIndex = null;
                        _overlayEntry?.markNeedsBuild();
                      },
                    ),
                  ),
                  const Divider(height: _dividerHeight, color: AppUiTokens.border),
                  SizedBox(
                    height: listAreaHeight,
                    child: filtered.isEmpty && !widget.allowNullSelection
                        ? const Center(
                            child: Text(
                              'Müşteri bulunamadı.',
                              style: TextStyle(
                                color: AppUiTokens.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: itemCount,
                            itemExtent: _itemHeight,
                            itemBuilder: (context, index) {
                              if (widget.allowNullSelection && index == 0) {
                                final isSelected =
                                    widget.selectedCustomerId == null;
                                final isHovered = _hoveredIndex == index;

                                return _CustomerMenuItemTile(
                                  label: 'Müşteri seçilmedi',
                                  isSelected: isSelected,
                                  isHovered: isHovered,
                                  onHover: (hovering) {
                                    _hoveredIndex = hovering ? index : null;
                                    _overlayEntry?.markNeedsBuild();
                                  },
                                  onTap: () => _selectCustomer(null),
                                );
                              }

                              final customerIndex =
                                  widget.allowNullSelection ? index - 1 : index;
                              final customer = filtered[customerIndex];
                              final isSelected =
                                  customer.id == widget.selectedCustomerId;
                              final isHovered = _hoveredIndex == index;

                              return _CustomerMenuItemTile(
                                label: customer.name,
                                isSelected: isSelected,
                                isHovered: isHovered,
                                onHover: (hovering) {
                                  _hoveredIndex = hovering ? index : null;
                                  _overlayEntry?.markNeedsBuild();
                                },
                                onTap: () => _selectCustomer(customer),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

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
        _searchQuery = '';
      });
    }
  }

  void _selectCustomer(Customer? customer) {
    widget.onChanged(customer?.id);
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedCustomer;
    final displayText = selected?.name ?? widget.placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Müşteri',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        MouseRegion(
          key: _triggerKey,
          cursor: _canInteract
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: _toggleOverlay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 48,
              padding: const EdgeInsets.symmetric(
                horizontal: AppUiTokens.space16,
              ),
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
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected == null
                            ? AppUiTokens.textMuted
                            : AppUiTokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: _canInteract
                          ? AppUiTokens.textSecondary
                          : AppUiTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerMenuItemTile extends StatelessWidget {
  const _CustomerMenuItemTile({
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
          height: _itemHeight,
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
