import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class DashboardCalendar extends StatelessWidget {
  const DashboardCalendar({
    required this.controller,
    this.expanded = false,
    super.key,
  });

  final DashboardController controller;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final month = controller.selectedMonth.value;
      final isLoading = controller.isLoadingCalendar.value;
      final selectedDate = controller.selectedDate.value;
      final today = AppDateUtils.normalizeDate(DateTime.now());

      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;
          final weekCount = _weekCountForMonth(month);
          final dayCellHeight = isCompact ? 88.0 : 100.0;
          final horizontalPadding =
              expanded ? AppUiTokens.space24 : AppUiTokens.space16;
          final topPadding =
              expanded ? AppUiTokens.space24 : AppUiTokens.space16;
          final bottomPadding =
              expanded ? AppUiTokens.space16 : AppUiTokens.space12;
          final gridPadding =
              expanded ? AppUiTokens.space16 : AppUiTokens.space12;

          final grid = isLoading && controller.calendarEvents.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppUiTokens.space40,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _CalendarGrid(
                  month: month,
                  today: today,
                  selectedDate: selectedDate,
                  dayCellHeight: dayCellHeight,
                  getEventsForDate: controller.getEventsForDate,
                  onDayTap: controller.selectDate,
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: _CalendarHeader(
                  month: month,
                  isCompact: isCompact,
                  expanded: expanded,
                  onPrevious: () => _changeMonthByDelta(-1),
                  onNext: () => _changeMonthByDelta(1),
                  onToday: () {
                    final now = DateTime.now();
                    controller
                      ..changeMonth(DateTime(now.year, now.month))
                      ..selectDate(now);
                  },
                ),
              ),
              const Divider(height: 1, color: AppUiTokens.border),
              if (expanded)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(gridPadding),
                    child: LayoutBuilder(
                      builder: (context, gridConstraints) {
                        final fittedDayCellHeight = _expandedDayCellHeight(
                          maxHeight: gridConstraints.maxHeight,
                          weekCount: weekCount,
                          isCompact: isCompact,
                        );

                        if (isLoading && controller.calendarEvents.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        return _CalendarGrid(
                          month: month,
                          today: today,
                          selectedDate: selectedDate,
                          dayCellHeight: fittedDayCellHeight,
                          getEventsForDate: controller.getEventsForDate,
                          onDayTap: controller.selectDate,
                        );
                      },
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.all(gridPadding),
                  child: grid,
                ),
            ],
          );
        },
      );
    });
  }

  void _changeMonthByDelta(int delta) {
    final current = controller.selectedMonth.value;
    controller.changeMonth(
      DateTime(current.year, current.month + delta),
    );
  }

  static int weekCountForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = firstDay.weekday - 1 + daysInMonth;
    return (totalCells / 7).ceil();
  }

  /// Fixed height for the non-expanded calendar used in dashboard split layout.
  static double estimatedHeight({
    required double width,
    required DateTime month,
  }) {
    final isCompact = width < 760;
    final weekCount = weekCountForMonth(month);
    final dayCellHeight = isCompact ? 88.0 : 100.0;
    const headerContentHeight = 44.0;
    const compactHeaderContentHeight = 84.0;
    const dividerHeight = 1.0;
    const weekdayRowHeight = 28.0;

    final gridRowsHeight =
        weekCount * dayCellHeight + (weekCount - 1) * AppUiTokens.space4;

    return AppUiTokens.space16 +
        (isCompact ? compactHeaderContentHeight : headerContentHeight) +
        AppUiTokens.space12 +
        dividerHeight +
        AppUiTokens.space12 * 2 +
        weekdayRowHeight +
        gridRowsHeight +
        4;
  }

  int _weekCountForMonth(DateTime month) => weekCountForMonth(month);

  double _expandedDayCellHeight({
    required double maxHeight,
    required int weekCount,
    required bool isCompact,
  }) {
    if (!maxHeight.isFinite || maxHeight <= 0) {
      return isCompact ? 80.0 : 88.0;
    }

    const weekdayRowHeight = 28.0;
    const safetyBuffer = 6.0;
    final rowGaps = (weekCount - 1) * AppUiTokens.space4;
    final availableHeight =
        maxHeight - weekdayRowHeight - rowGaps - safetyBuffer;
    if (availableHeight <= 0) {
      return 56.0;
    }

    final fittedHeight = availableHeight / weekCount;

    return fittedHeight.clamp(56.0, isCompact ? 124.0 : 148.0);
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.isCompact,
    required this.expanded,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime month;
  final bool isCompact;
  final bool expanded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final monthStyle = expanded
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.headlineSmall;
    final yearStyle = expanded
        ? Theme.of(context).textTheme.headlineSmall
        : Theme.of(context).textTheme.titleLarge;

    final title = Wrap(
      spacing: AppUiTokens.space12,
      runSpacing: AppUiTokens.space4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          AppDateUtils.turkishMonths[month.month - 1],
          style: monthStyle?.copyWith(
            color: AppUiTokens.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        Text(
          '${month.year}',
          style: yearStyle?.copyWith(
            color: AppUiTokens.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.1,
          ),
        ),
      ],
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavButton(icon: Icons.chevron_left, onTap: onPrevious),
        const SizedBox(width: AppUiTokens.space4),
        _NavButton(icon: Icons.chevron_right, onTap: onNext),
        const SizedBox(width: AppUiTokens.space8),
        _TodayButton(onTap: onToday),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: AppUiTokens.space12),
          Align(alignment: Alignment.centerRight, child: controls),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: AppUiTokens.space12),
        controls,
      ],
    );
  }
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space8),
          decoration: BoxDecoration(
            color: AppUiTokens.surface,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
            border: Border.all(color: AppUiTokens.border),
          ),
          alignment: Alignment.center,
          child: Text(
            'Bugün',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ColorName.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: AppUiTokens.surface,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
            border: Border.all(color: AppUiTokens.border),
          ),
          child: Icon(icon, size: 18, color: AppUiTokens.textSecondary),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.today,
    required this.selectedDate,
    required this.dayCellHeight,
    required this.getEventsForDate,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selectedDate;
  final double dayCellHeight;
  final List<DashboardCalendarEvent> Function(DateTime date) getEventsForDate;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday;
    final weekCount = _weekCount(startWeekday, daysInMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: AppDateUtils.turkishWeekdaysShort
              .map(
                (day) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 2,
                      right: 2,
                      bottom: AppUiTokens.space4,
                    ),
                    child: Container(
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppUiTokens.textPrimary,
                        borderRadius:
                            BorderRadius.circular(AppUiTokens.radiusSm),
                      ),
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...List.generate(
          weekCount,
          (weekIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: weekIndex == weekCount - 1 ? 0 : AppUiTokens.space4,
              ),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final cellIndex = weekIndex * 7 + dayIndex;
                  final dayNumber = cellIndex - startWeekday + 2;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return Expanded(
                      child: SizedBox(height: dayCellHeight),
                    );
                  }

                  final date = DateTime(month.year, month.month, dayNumber);
                  final normalized = AppDateUtils.normalizeDate(date);
                  final isToday = normalized == today;
                  final isSelected = selectedDate != null &&
                      normalized == AppDateUtils.normalizeDate(selectedDate!);
                  final events = getEventsForDate(date);

                  return Expanded(
                    child: _DayCell(
                      date: date,
                      dayNumber: dayNumber,
                      isToday: isToday,
                      isSelected: isSelected,
                      height: dayCellHeight,
                      events: events,
                      onTap: () => onDayTap(date),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  int _weekCount(int startWeekday, int daysInMonth) {
    final totalCells = startWeekday - 1 + daysInMonth;
    return (totalCells / 7).ceil();
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
    required this.height,
    required this.events,
    required this.onTap,
  });

  final DateTime date;
  final int dayNumber;
  final bool isToday;
  final bool isSelected;
  final double height;
  final List<DashboardCalendarEvent> events;
  final VoidCallback onTap;

  static const _cellPadding = AppUiTokens.space8;
  static const _headerBlockHeight = 24.0;
  static const _headerBadgeGap = AppUiTokens.space12;
  static const _badgeHeight = 26.0;
  static const _badgeSpacing = 5.0;

  ({List<DashboardCalendarEvent> visible, int hidden}) _resolveVisibleEvents(
    double height,
  ) {
    final badgeAreaHeight = height -
        (_cellPadding * 2) -
        _headerBlockHeight -
        (events.isEmpty ? 0 : _headerBadgeGap);

    if (badgeAreaHeight < _badgeHeight || events.isEmpty) {
      return (visible: const [], hidden: 0);
    }

    for (var count = events.length.clamp(0, 4); count >= 0; count--) {
      final hidden = events.length - count;
      final neededHeight = _badgesBlockHeight(
        badgeCount: count,
        includeOverflow: hidden > 0,
      );
      if (neededHeight <= badgeAreaHeight + 0.5) {
        return (
          visible: events.take(count).toList(),
          hidden: hidden,
        );
      }
    }

    return (visible: const [], hidden: 0);
  }

  double _badgesBlockHeight({
    required int badgeCount,
    required bool includeOverflow,
  }) {
    if (badgeCount <= 0 && !includeOverflow) {
      return 0;
    }

    var height = badgeCount * _badgeHeight;
    if (badgeCount > 1) {
      height += (badgeCount - 1) * _badgeSpacing;
    }
    if (includeOverflow) {
      if (badgeCount > 0) {
        height += _badgeSpacing;
      }
      height += _badgeHeight;
    }
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final hasEvents = events.isNotEmpty;
    final accentColor = hasEvents ? _primaryEventColor : AppUiTokens.border;
    final borderColor = isSelected
        ? ColorName.primary
        : isToday
            ? ColorName.primary.withValues(alpha: 0.4)
            : AppUiTokens.border;
    final backgroundColor = isSelected
        ? ColorName.primary.withValues(alpha: 0.08)
        : isToday
            ? AppUiTokens.surfaceMuted
            : AppUiTokens.surface;
    final resolved = _resolveVisibleEvents(height);
    final visibleEvents = resolved.visible;
    final hiddenCount = resolved.hidden;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          hoverColor: AppUiTokens.surfaceMuted,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: height,
            padding: const EdgeInsets.all(_cellPadding),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected || isToday
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _headerBlockHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DayNumberBadge(
                        dayNumber: dayNumber,
                        isToday: isToday,
                        isSelected: isSelected,
                      ),
                      const Spacer(),
                      if (hasEvents)
                        Container(
                          height: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppUiTokens.radiusSm),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${events.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (visibleEvents.isNotEmpty || hiddenCount > 0) ...[
                  const SizedBox(height: _headerBadgeGap),
                  if (visibleEvents.isNotEmpty)
                    for (var i = 0; i < visibleEvents.length; i++) ...[
                      _DayEventBadge(event: visibleEvents[i]),
                      if (i < visibleEvents.length - 1 || hiddenCount > 0)
                        const SizedBox(height: _badgeSpacing),
                    ],
                  if (hiddenCount > 0)
                    _DayEventBadge.overflow(count: hiddenCount),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _primaryEventColor {
    for (final event in events) {
      return _colorForType(event.type);
    }
    return AppUiTokens.border;
  }

  static Color _colorForType(DashboardCalendarEventType type) {
    switch (type) {
      case DashboardCalendarEventType.meeting:
        return const Color(0xFF2563EB);
      case DashboardCalendarEventType.priceOffer:
        return const Color(0xFFF59E0B);
      case DashboardCalendarEventType.reminder:
        return const Color(0xFF7C3AED);
      case DashboardCalendarEventType.dueRecord:
        return const Color(0xFF059669);
    }
  }
}

class _DayNumberBadge extends StatelessWidget {
  const _DayNumberBadge({
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
  });

  final int dayNumber;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: ColorName.primary,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNumber',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              color: ColorName.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            )
          : null,
      child: Text(
        '$dayNumber',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? ColorName.primary : AppUiTokens.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
      ),
    );
  }
}

class _DayEventBadge extends StatelessWidget {
  const _DayEventBadge({required this.event}) : count = null;

  const _DayEventBadge.overflow({required this.count}) : event = null;

  final DashboardCalendarEvent? event;
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (count != null) {
      return _BadgeShell(
        color: AppUiTokens.textMuted,
        label: '+$count kayıt',
        typeLabel: null,
      );
    }

    final currentEvent = event!;
    final color = _DayCell._colorForType(currentEvent.type);

    return _BadgeShell(
      color: color,
      label: _contentLabel(currentEvent),
      typeLabel: currentEvent.type.label,
    );
  }

  String _contentLabel(DashboardCalendarEvent event) {
    final subtitle = event.subtitle?.trim();
    if (subtitle != null && subtitle.isNotEmpty) {
      return subtitle;
    }

    final customer = event.customerName?.trim();
    if (customer != null && customer.isNotEmpty) {
      return customer;
    }

    return event.title;
  }
}

class _BadgeShell extends StatelessWidget {
  const _BadgeShell({
    required this.color,
    required this.label,
    required this.typeLabel,
  });

  final Color color;
  final String label;
  final String? typeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _DayCell._badgeHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          if (typeLabel != null) ...[
            Text(
              typeLabel!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '·',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppUiTokens.textMuted,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
