import 'package:Ok/feature/dashboard/models/dashboard_calendar_event.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:flutter/material.dart';

final class DashboardEventListItem extends StatelessWidget {
  const DashboardEventListItem({
    required this.event,
    required this.onTap,
    super.key,
  });

  final DashboardCalendarEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isInteractive = event.route != null;
    final accentColor = _colorForType(event.type);

    return Material(
      color: AppUiTokens.surface,
      borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
      child: InkWell(
        onTap: isInteractive ? onTap : null,
        mouseCursor:
            isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        hoverColor: AppUiTokens.surfaceMuted,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppUiTokens.space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
            border: Border.all(color: AppUiTokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                  border:
                      Border.all(color: accentColor.withValues(alpha: 0.14)),
                ),
                child: Icon(
                  _iconForType(event.type),
                  color: accentColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: AppUiTokens.space12),
              Expanded(
                child: _EventContent(event: event),
              ),
              if (isInteractive)
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppUiTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: AppUiTokens.textMuted,
                  ),
                ),
            ],
          ),
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

class _EventContent extends StatelessWidget {
  const _EventContent({required this.event});

  final DashboardCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    switch (event.type) {
      case DashboardCalendarEventType.meeting:
        return _MeetingContent(event: event);
      case DashboardCalendarEventType.priceOffer:
        return _PriceOfferContent(event: event);
      case DashboardCalendarEventType.reminder:
        return _ReminderContent(event: event);
    }
  }
}

class _MeetingContent extends StatelessWidget {
  const _MeetingContent({required this.event});

  final DashboardCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final parts = _splitSubtitle(event.subtitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryLine(value: event.customerName ?? '-'),
        const SizedBox(height: AppUiTokens.space4),
        _SecondaryLine('${parts.subject} · ${parts.method}'),
        const SizedBox(height: AppUiTokens.space8),
        _MetaLine(
          value: AppDateUtils.formatDateTime(event.date),
          icon: Icons.access_time_rounded,
        ),
      ],
    );
  }
}

class _PriceOfferContent extends StatelessWidget {
  const _PriceOfferContent({required this.event});

  final DashboardCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final parts = _splitSubtitle(event.subtitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryLine(value: event.customerName ?? '-'),
        const SizedBox(height: AppUiTokens.space4),
        _SecondaryLine('${parts.subject} · ${parts.method}'),
        const SizedBox(height: AppUiTokens.space8),
        _MetaLine(
          value: AppDateUtils.formatDate(event.date),
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }
}

class _ReminderContent extends StatelessWidget {
  const _ReminderContent({required this.event});

  final DashboardCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryLine(value: event.title),
        if (event.subtitle != null && event.subtitle!.isNotEmpty) ...[
          const SizedBox(height: AppUiTokens.space4),
          _SecondaryLine(event.subtitle!),
        ],
        const SizedBox(height: AppUiTokens.space8),
        _MetaLine(
          value: event.customerName == null || event.customerName!.isEmpty
              ? AppDateUtils.formatDate(event.date)
              : '${event.customerName} · ${AppDateUtils.formatDate(event.date)}',
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }
}

class _PrimaryLine extends StatelessWidget {
  const _PrimaryLine({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppUiTokens.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
    );
  }
}

class _SecondaryLine extends StatelessWidget {
  const _SecondaryLine(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppUiTokens.textSecondary,
            height: 1.3,
          ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.value,
    required this.icon,
  });

  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppUiTokens.textMuted),
        const SizedBox(width: AppUiTokens.space4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppUiTokens.textMuted,
                  fontSize: 10.5,
                ),
          ),
        ),
      ],
    );
  }
}

({String subject, String method}) _splitSubtitle(String? subtitle) {
  if (subtitle == null || subtitle.isEmpty) {
    return (subject: '-', method: '-');
  }

  final parts = subtitle.split(' · ');
  if (parts.length >= 2) {
    return (subject: parts[0].trim(), method: parts[1].trim());
  }

  return (subject: subtitle.trim(), method: '-');
}
