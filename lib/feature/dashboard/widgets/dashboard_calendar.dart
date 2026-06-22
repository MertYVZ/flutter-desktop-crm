import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
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
          final dayCellHeight = expanded
              ? _expandedDayCellHeight(
                  maxHeight: constraints.maxHeight,
                  weekCount: weekCount,
                  isCompact: isCompact,
                )
              : (isCompact ? 46.0 : 54.0);
          final horizontalPadding =
              expanded ? AppUiTokens.space24 : AppUiTokens.space16;
          final topPadding =
              expanded ? AppUiTokens.space24 : AppUiTokens.space16;
          final bottomPadding =
              expanded ? AppUiTokens.space16 : AppUiTokens.space12;
          final gridPadding =
              expanded ? AppUiTokens.space16 : AppUiTokens.space12;

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
              Padding(
                padding: EdgeInsets.all(gridPadding),
                child: isLoading && controller.calendarEvents.isEmpty
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
                        getMeetingCount: (date) => _countForDate(
                          date,
                          DashboardCalendarEventType.meeting,
                        ),
                        getPriceOfferCount: (date) => _countForDate(
                          date,
                          DashboardCalendarEventType.priceOffer,
                        ),
                        getReminderCount: (date) => _countForDate(
                          date,
                          DashboardCalendarEventType.reminder,
                        ),
                        onDayTap: controller.selectDate,
                      ),
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

  int _countForDate(DateTime date, DashboardCalendarEventType type) {
    final normalized = AppDateUtils.normalizeDate(date);
    return controller.calendarEvents
        .where(
          (event) =>
              event.type == type &&
              AppDateUtils.normalizeDate(event.date) == normalized,
        )
        .length;
  }

  int _weekCountForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = firstDay.weekday - 1 + daysInMonth;
    return (totalCells / 7).ceil();
  }

  double _expandedDayCellHeight({
    required double maxHeight,
    required int weekCount,
    required bool isCompact,
  }) {
    if (!maxHeight.isFinite) {
      return isCompact ? 90 : 108;
    }

    const headerEstimate = 74.0;
    const dividerHeight = 1.0;
    const gridVerticalPadding = AppUiTokens.space16 * 2;
    const weekdayRowHeight = 28.0;
    final rowGaps = (weekCount - 1) * AppUiTokens.space4;
    final availableHeight = maxHeight -
        headerEstimate -
        dividerHeight -
        gridVerticalPadding -
        weekdayRowHeight -
        rowGaps;
    final fittedHeight = availableHeight / weekCount;

    return fittedHeight.clamp(
      isCompact ? 64.0 : 72.0,
      isCompact ? 90.0 : 108.0,
    );
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
    final title = Wrap(
      spacing: AppUiTokens.space16,
      runSpacing: AppUiTokens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          AppDateUtils.turkishMonths[month.month - 1],
          style: (expanded
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.titleSmall)
              ?.copyWith(
            color: AppUiTokens.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          '${month.year}',
          style: (expanded
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.titleSmall)
              ?.copyWith(
            color: AppUiTokens.textPrimary,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
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
    required this.getMeetingCount,
    required this.getPriceOfferCount,
    required this.getReminderCount,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selectedDate;
  final double dayCellHeight;
  final int Function(DateTime date) getMeetingCount;
  final int Function(DateTime date) getPriceOfferCount;
  final int Function(DateTime date) getReminderCount;
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
                        color: AppUiTokens.surfaceMuted,
                        borderRadius:
                            BorderRadius.circular(AppUiTokens.radiusSm),
                      ),
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppUiTokens.textMuted,
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

                  return Expanded(
                    child: _DayCell(
                      date: date,
                      dayNumber: dayNumber,
                      isToday: isToday,
                      isSelected: isSelected,
                      height: dayCellHeight,
                      meetingCount: getMeetingCount(date),
                      priceOfferCount: getPriceOfferCount(date),
                      reminderCount: getReminderCount(date),
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
    required this.meetingCount,
    required this.priceOfferCount,
    required this.reminderCount,
    required this.onTap,
  });

  final DateTime date;
  final int dayNumber;
  final bool isToday;
  final bool isSelected;
  final double height;
  final int meetingCount;
  final int priceOfferCount;
  final int reminderCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? ColorName.primary
        : isToday
            ? ColorName.primary.withValues(alpha: 0.4)
            : hasEvents
                ? _eventAccentColor.withValues(alpha: 0.28)
                : AppUiTokens.border;
    final backgroundColor = isSelected
        ? ColorName.primary.withValues(alpha: 0.08)
        : isToday
            ? AppUiTokens.surfaceMuted
            : hasEvents
                ? const Color(0xFFF8FAFC)
                : AppUiTokens.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
          hoverColor: AppUiTokens.surfaceMuted,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: height,
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: hasEvents || isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Center(
                        child: isToday
                            ? Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: ColorName.primary,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$dayNumber',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                ),
                              )
                            : Text(
                                '$dayNumber',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? ColorName.primary
                                          : AppUiTokens.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                      ),
                    ),
                    const Spacer(),
                    if (totalEventCount > 0)
                      Container(
                        height: 18,
                        constraints: const BoxConstraints(minWidth: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _eventAccentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _eventAccentColor.withValues(alpha: 0.18),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$totalEventCount',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _eventAccentColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    height: 1,
                                  ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (hasEvents)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (meetingCount > 0)
                        const _EventDot(color: Color(0xFF2563EB)),
                      if (priceOfferCount > 0)
                        const _EventDot(color: Color(0xFFF59E0B)),
                      if (reminderCount > 0)
                        const _EventDot(color: Color(0xFF7C3AED)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get hasEvents =>
      meetingCount > 0 || priceOfferCount > 0 || reminderCount > 0;

  int get totalEventCount => meetingCount + priceOfferCount + reminderCount;

  Color get _eventAccentColor {
    if (meetingCount > 0) {
      return const Color(0xFF2563EB);
    }
    if (priceOfferCount > 0) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF7C3AED);
  }
}

class _EventDot extends StatelessWidget {
  const _EventDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
