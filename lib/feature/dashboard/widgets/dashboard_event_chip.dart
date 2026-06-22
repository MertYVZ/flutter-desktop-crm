import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';

final class DashboardEventChip extends StatelessWidget {
  const DashboardEventChip({
    required this.type,
    required this.count,
    super.key,
  });

  final DashboardCalendarEventType type;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final color = _colorForType(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$count ${type.pluralLabel}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      height: 1,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    }
  }
}
