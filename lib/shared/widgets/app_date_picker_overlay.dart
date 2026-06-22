import 'dart:async';

import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/shared/widgets/anchored_overlay.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

const _pickerWidth = 300.0;
const _pickerHeight = 340.0;

Future<DateTime?> showAppDatePickerOverlay({
  required BuildContext context,
  required GlobalKey anchorKey,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final anchorContext = anchorKey.currentContext;
  if (anchorContext == null) {
    return Future.value();
  }

  final renderBox = anchorContext.findRenderObject()! as RenderBox;
  final completer = Completer<DateTime?>();
  late OverlayEntry entry;

  void close([DateTime? result]) {
    if (!completer.isCompleted) {
      entry.remove();
      completer.complete(result);
    }
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      final screenSize = MediaQuery.sizeOf(overlayContext);
      final anchorOffset = renderBox.localToGlobal(Offset.zero);
      final anchorSize = renderBox.size;

      return _AppDatePickerOverlay(
        anchorSize: anchorSize,
        anchorOffset: anchorOffset,
        screenSize: screenSize,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
        onSelected: close,
        onCancel: () => close(),
      );
    },
  );

  Overlay.of(context, rootOverlay: true).insert(entry);
  return completer.future;
}

class _AppDatePickerOverlay extends StatefulWidget {
  const _AppDatePickerOverlay({
    required this.anchorSize,
    required this.anchorOffset,
    required this.screenSize,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
    required this.onCancel,
    this.initialDate,
  });

  final Size anchorSize;
  final Offset anchorOffset;
  final Size screenSize;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onCancel;

  @override
  State<_AppDatePickerOverlay> createState() => _AppDatePickerOverlayState();
}

class _AppDatePickerOverlayState extends State<_AppDatePickerOverlay> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  int? _hoveredDay;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? DateTime.now();
    _selectedDate = AppDateUtils.normalizeDate(initial);
    _focusedMonth = DateTime(initial.year, initial.month);
  }

  bool _isSelectable(DateTime date) {
    final normalized = AppDateUtils.normalizeDate(date);
    final first = AppDateUtils.normalizeDate(widget.firstDate);
    final last = AppDateUtils.normalizeDate(widget.lastDate);
    return !normalized.isBefore(first) && !normalized.isAfter(last);
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _selectDay(DateTime date) {
    if (!_isSelectable(date)) {
      return;
    }

    widget.onSelected(AppDateUtils.normalizeDate(date));
  }

  List<DateTime?> _buildCalendarDays() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final leadingEmpty = firstOfMonth.weekday - DateTime.monday;

    final days = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmpty, null),
      ...List<DateTime?>.generate(
        daysInMonth,
        (index) => DateTime(_focusedMonth.year, _focusedMonth.month, index + 1),
      ),
    ];

    while (days.length % 7 != 0) {
      days.add(null);
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final today = AppDateUtils.normalizeDate(DateTime.now());

    final menu = Material(
      color: Colors.transparent,
      child: Container(
        width: _pickerWidth,
        padding: const EdgeInsets.all(AppUiTokens.space16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MonthHeader(
              label: AppDateUtils.monthYearLabel(_focusedMonth),
              onPrevious: _goToPreviousMonth,
              onNext: _goToNextMonth,
            ),
            const SizedBox(height: AppUiTokens.space12),
            _WeekdayHeader(),
            const SizedBox(height: AppUiTokens.space8),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  if (day == null) {
                    return const SizedBox.shrink();
                  }

                  final normalized = AppDateUtils.normalizeDate(day);
                  final isSelected = normalized == _selectedDate;
                  final isToday = normalized == today;
                  final isEnabled = _isSelectable(day);
                  final isHovered = _hoveredDay == day.day;

                  return _DayCell(
                    day: day.day,
                    isSelected: isSelected,
                    isToday: isToday,
                    isEnabled: isEnabled,
                    isHovered: isHovered,
                    onHover: (hovering) {
                      setState(() {
                        _hoveredDay = hovering ? day.day : null;
                      });
                    },
                    onTap: isEnabled ? () => _selectDay(day) : null,
                  );
                },
              ),
            ),
            const SizedBox(height: AppUiTokens.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  style: AppInteractiveTheme.textButtonStyle(
                    TextButton.styleFrom(
                      foregroundColor: AppUiTokens.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppUiTokens.space16,
                        vertical: AppUiTokens.space8,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final menuHeight = anchoredOverlayMenuHeight(
      anchorOffset: widget.anchorOffset,
      anchorSize: widget.anchorSize,
      screenHeight: widget.screenSize.height,
      preferredHeight: _pickerHeight,
      minHeight: _pickerHeight,
    );

    return AnchoredOverlayLayout(
      anchorOffset: widget.anchorOffset,
      anchorSize: widget.anchorSize,
      screenSize: widget.screenSize,
      menuWidth: _pickerWidth,
      menuHeight: menuHeight,
      onDismiss: widget.onCancel,
      child: menu,
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(icon: Icons.chevron_left_rounded, onPressed: onPrevious),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _NavButton(icon: Icons.chevron_right_rounded, onPressed: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: AppUiTokens.textSecondary),
      style: AppInteractiveTheme.iconButtonStyle(
        IconButton.styleFrom(
          minimumSize: const Size(32, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppDateUtils.turkishWeekdaysShort
          .map(
            (day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppUiTokens.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isEnabled,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isEnabled;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    Color textColor = AppUiTokens.textPrimary;
    BoxBorder? border;

    if (!isEnabled) {
      textColor = AppUiTokens.textMuted.withValues(alpha: 0.5);
    } else if (isSelected) {
      backgroundColor = ColorName.primary;
      textColor = Colors.white;
    } else if (isHovered) {
      backgroundColor = AppUiTokens.surfaceMuted;
    } else if (isToday) {
      border = Border.all(color: ColorName.primary.withValues(alpha: 0.45));
    }

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            border: border,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
