import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_event_list_item.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class DashboardDayDetailPanel extends StatelessWidget {
  const DashboardDayDetailPanel({
    required this.controller,
    this.fullWidth = false,
    this.showLeftBorder = false,
    this.embeddedInSplitView = false,
    super.key,
  });

  final DashboardController controller;
  final bool fullWidth;
  final bool showLeftBorder;
  final bool embeddedInSplitView;

  static const _panelWidth = 392.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      if (selectedDate == null) {
        return _buildPanelShell(
          showLeftBorder: showLeftBorder,
          child: embeddedInSplitView
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(
                      child: AppEmptyState(
                        title: 'Seçilen Gün',
                        message:
                            'Takvimden bir gün seçerek o güne ait kayıtları görüntüleyin.',
                        icon: Icons.event_busy_outlined,
                      ),
                    ),
                  ],
                )
              : const AppEmptyState(
                  title: 'Seçilen Gün',
                  message:
                      'Takvimden bir gün seçerek o güne ait kayıtları görüntüleyin.',
                  icon: Icons.event_busy_outlined,
                ),
        );
      }

      final events = controller.selectedDateEvents;
      final meetings = events
          .where((event) => event.type == DashboardCalendarEventType.meeting)
          .toList();
      final priceOffers = events
          .where((event) => event.type == DashboardCalendarEventType.priceOffer)
          .toList();
      final reminders = events
          .where((event) => event.type == DashboardCalendarEventType.reminder)
          .toList();
      final dueRecords = events
          .where((event) => event.type == DashboardCalendarEventType.dueRecord)
          .toList();

      return _buildPanelShell(
        showLeftBorder: showLeftBorder,
        child: _buildPanelBody(
          context: context,
          selectedDate: selectedDate,
          events: events,
          meetings: meetings,
          priceOffers: priceOffers,
          reminders: reminders,
          dueRecords: dueRecords,
        ),
      );
    });
  }

  Widget _buildPanelShell({
    required bool showLeftBorder,
    required Widget child,
  }) {
    return Container(
      width: fullWidth ? double.infinity : _panelWidth,
      decoration: BoxDecoration(
        color: AppUiTokens.surfaceMuted,
        border: showLeftBorder
            ? const Border(
                left: BorderSide(color: AppUiTokens.border),
              )
            : null,
      ),
      child: child,
    );
  }

  Widget _buildPanelBody({
    required BuildContext context,
    required DateTime selectedDate,
    required List<DashboardCalendarEvent> events,
    required List<DashboardCalendarEvent> meetings,
    required List<DashboardCalendarEvent> priceOffers,
    required List<DashboardCalendarEvent> reminders,
    required List<DashboardCalendarEvent> dueRecords,
  }) {
    final eventGroups = _buildEventGroups(
      meetings: meetings,
      priceOffers: priceOffers,
      reminders: reminders,
      dueRecords: dueRecords,
    );

    final contentPadding = const EdgeInsets.fromLTRB(
      AppUiTokens.space16,
      AppUiTokens.space12,
      AppUiTokens.space16,
      AppUiTokens.space16,
    );

    final content = events.isEmpty
        ? const AppEmptyState(
            title: 'Bu gün için kayıt yok',
            message:
                'Seçtiğiniz tarihte görüşme, teklif, vade veya hatırlatma bulunmuyor.',
            icon: Icons.event_busy_outlined,
          )
        : embeddedInSplitView
            ? SingleChildScrollView(
                padding: contentPadding,
                physics: const ClampingScrollPhysics(),
                child: eventGroups,
              )
            : Padding(
                padding: contentPadding,
                child: eventGroups,
              );

    final header = _PanelHeader(
      selectedDate: selectedDate,
      weekday: _weekdayLabel(selectedDate),
      eventCount: events.length,
      onClose: controller.closeDayPanel,
    );

    if (embeddedInSplitView) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(child: content),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        content,
      ],
    );
  }

  Widget _buildEventGroups({
    required List<DashboardCalendarEvent> meetings,
    required List<DashboardCalendarEvent> priceOffers,
    required List<DashboardCalendarEvent> reminders,
    required List<DashboardCalendarEvent> dueRecords,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EventGroup(
          title: 'Görüşmeler',
          type: DashboardCalendarEventType.meeting,
          emptyMessage: 'Görüşme kaydı yok.',
          events: meetings,
          onEventTap: controller.navigateToEvent,
        ),
        const SizedBox(height: AppUiTokens.space12),
        _EventGroup(
          title: 'Fiyat Teklifleri',
          type: DashboardCalendarEventType.priceOffer,
          emptyMessage: 'Fiyat teklifi yok.',
          events: priceOffers,
          onEventTap: controller.navigateToEvent,
        ),
        const SizedBox(height: AppUiTokens.space12),
        _EventGroup(
          title: 'Vadeler',
          type: DashboardCalendarEventType.dueRecord,
          emptyMessage: 'Vade kaydı yok.',
          events: dueRecords,
          onEventTap: controller.navigateToEvent,
        ),
        const SizedBox(height: AppUiTokens.space12),
        _EventGroup(
          title: 'Hatırlatmalar',
          type: DashboardCalendarEventType.reminder,
          emptyMessage: 'Hatırlatma yok.',
          events: reminders,
          onEventTap: controller.navigateToEvent,
        ),
      ],
    );
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return weekdays[date.weekday - 1];
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.selectedDate,
    required this.weekday,
    required this.eventCount,
    required this.onClose,
  });

  final DateTime selectedDate;
  final String weekday;
  final int eventCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final monthLabel = AppDateUtils.turkishMonths[selectedDate.month - 1];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppUiTokens.space16,
        AppUiTokens.space16,
        AppUiTokens.space8,
        AppUiTokens.space16,
      ),
      decoration: BoxDecoration(
        color: AppUiTokens.surface,
        border: const Border(
          bottom: BorderSide(color: AppUiTokens.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorName.primary.withValues(alpha: 0.14),
                  ColorName.primary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              border: Border.all(
                color: ColorName.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${selectedDate.day}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: ColorName.primary,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthLabel.substring(0, 3).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ColorName.primary.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.6,
                        height: 1,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppUiTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppUiTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: AppUiTokens.space4),
                Text(
                  AppDateUtils.formatDate(selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppUiTokens.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                ),
                const SizedBox(height: AppUiTokens.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space8,
                    vertical: AppUiTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: eventCount > 0
                        ? ColorName.primary.withValues(alpha: 0.1)
                        : AppUiTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: eventCount > 0
                          ? ColorName.primary.withValues(alpha: 0.2)
                          : AppUiTokens.border,
                    ),
                  ),
                  child: Text(
                    eventCount == 0 ? 'Kayıt yok' : '$eventCount kayıt',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: eventCount > 0
                              ? ColorName.primary
                              : AppUiTokens.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            mouseCursor: SystemMouseCursors.click,
            style: IconButton.styleFrom(
              backgroundColor: AppUiTokens.surfaceMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              ),
            ),
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppUiTokens.textMuted,
            tooltip: 'Kapat',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _EventGroup extends StatelessWidget {
  const _EventGroup({
    required this.title,
    required this.type,
    required this.emptyMessage,
    required this.events,
    required this.onEventTap,
  });

  final String title;
  final DashboardCalendarEventType type;
  final String emptyMessage;
  final List<DashboardCalendarEvent> events;
  final ValueChanged<DashboardCalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _colorForType(type);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppUiTokens.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppUiTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 3,
              color: accentColor,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppUiTokens.space12,
                AppUiTokens.space12,
                AppUiTokens.space12,
                AppUiTokens.space8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.radiusSm),
                    ),
                    child: Icon(
                      _iconForType(type),
                      size: 17,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: AppUiTokens.space12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppUiTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 26),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppUiTokens.space8,
                      vertical: AppUiTokens.space4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${events.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppUiTokens.space12,
                  0,
                  AppUiTokens.space12,
                  AppUiTokens.space12,
                ),
                child: AppEmptyState(
                  compact: true,
                  title: emptyMessage,
                  message: '',
                  icon: _iconForType(type),
                  iconColor: accentColor,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppUiTokens.space12,
                  0,
                  AppUiTokens.space12,
                  AppUiTokens.space12,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < events.length; i++) ...[
                      DashboardEventListItem(
                        event: events[i],
                        onTap: () => onEventTap(events[i]),
                      ),
                      if (i < events.length - 1)
                        const SizedBox(height: AppUiTokens.space8),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForType(DashboardCalendarEventType type) {
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

  IconData _iconForType(DashboardCalendarEventType type) {
    switch (type) {
      case DashboardCalendarEventType.meeting:
        return Icons.forum_outlined;
      case DashboardCalendarEventType.priceOffer:
        return Icons.request_quote_outlined;
      case DashboardCalendarEventType.reminder:
        return Icons.notifications_none_rounded;
      case DashboardCalendarEventType.dueRecord:
        return Icons.payments_outlined;
    }
  }
}
