import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_event_list_item.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class DashboardDayDetailPanel extends StatelessWidget {
  const DashboardDayDetailPanel({
    required this.controller,
    this.fullWidth = false,
    super.key,
  });

  final DashboardController controller;
  final bool fullWidth;

  static const _panelWidth = 392.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      if (selectedDate == null) {
        return Container(
          width: fullWidth ? double.infinity : _panelWidth,
          decoration: BoxDecoration(
            color: AppUiTokens.surface,
            border: Border(
              left: fullWidth
                  ? BorderSide.none
                  : const BorderSide(color: AppUiTokens.border),
            ),
          ),
          child: const _EmptyState(
            title: 'Seçilen Gün',
            message:
                'Takvimden bir gün seçerek o güne ait kayıtları görüntüleyin.',
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

      final content = events.isEmpty
          ? const _EmptyState(
              title: 'Bu gün için kayıt yok',
              message:
                  'Seçtiğiniz tarihte görüşme, teklif veya hatırlatma bulunmuyor.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppUiTokens.space16),
              child: Column(
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
                    title: 'Hatırlatmalar',
                    type: DashboardCalendarEventType.reminder,
                    emptyMessage: 'Hatırlatma yok.',
                    events: reminders,
                    onEventTap: controller.navigateToEvent,
                  ),
                ],
              ),
            );

      return Container(
        width: fullWidth ? double.infinity : _panelWidth,
        decoration: BoxDecoration(
          color: AppUiTokens.surface,
          border: Border(
            left: fullWidth
                ? BorderSide.none
                : const BorderSide(color: AppUiTokens.border),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isHeightBounded = constraints.maxHeight.isFinite;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PanelHeader(
                  title: AppDateUtils.formatDate(selectedDate),
                  weekday: _weekdayLabel(selectedDate),
                  eventCount: events.length,
                  onClose: controller.closeDayPanel,
                ),
                if (isHeightBounded) Expanded(child: content) else content,
              ],
            );
          },
        ),
      );
    });
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
    required this.title,
    required this.weekday,
    required this.eventCount,
    required this.onClose,
  });

  final String title;
  final String weekday;
  final int eventCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppUiTokens.space16,
        AppUiTokens.space16,
        AppUiTokens.space8,
        AppUiTokens.space16,
      ),
      decoration: const BoxDecoration(
        color: AppUiTokens.surface,
        border: Border(
          bottom: BorderSide(color: AppUiTokens.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppUiTokens.accentSoft,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              border: Border.all(color: ColorName.primary),
            ),
            child: const Icon(
              Icons.event_note_outlined,
              size: 21,
              color: ColorName.primary,
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: AppUiTokens.space4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppUiTokens.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
                const SizedBox(height: AppUiTokens.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space8,
                    vertical: AppUiTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppUiTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppUiTokens.border),
                  ),
                  child: Text(
                    eventCount == 0 ? 'Kayıt yok' : '$eventCount kayıt',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppUiTokens.textSecondary,
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
            icon: const Icon(Icons.close, size: 18),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _colorForType(type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              ),
              child: Icon(
                _iconForType(type),
                size: 16,
                color: _colorForType(type),
              ),
            ),
            const SizedBox(width: AppUiTokens.space12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppUiTokens.space8,
                vertical: AppUiTokens.space4,
              ),
              decoration: BoxDecoration(
                color: AppUiTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppUiTokens.border),
              ),
              child: Text(
                '${events.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppUiTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppUiTokens.space8),
        if (events.isEmpty)
          _EmptyState(
            title: emptyMessage,
            message: '',
            compact: true,
          )
        else
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: AppUiTokens.space8),
              child: DashboardEventListItem(
                event: event,
                onTap: () => onEventTap(event),
              ),
            ),
          ),
      ],
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
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppUiTokens.space12,
          vertical: AppUiTokens.space8,
        ),
        decoration: BoxDecoration(
          color: AppUiTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          border: Border.all(color: AppUiTokens.border),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppUiTokens.textMuted,
                height: 1.35,
              ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppUiTokens.space32,
        horizontal: AppUiTokens.space24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppUiTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
              border: Border.all(color: AppUiTokens.border),
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: 28,
              color: AppUiTokens.textMuted.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppUiTokens.space16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppUiTokens.space8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppUiTokens.textSecondary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
