import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:equatable/equatable.dart';

final class DashboardCalendarEvent extends Equatable {
  const DashboardCalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.sourceId,
    required this.sourceType,
    this.subtitle,
    this.customerName,
    this.route,
  });

  final String id;
  final String title;
  final String? subtitle;
  final DateTime date;
  final DashboardCalendarEventType type;
  final String? customerName;
  final String? route;
  final String sourceId;
  final String sourceType;

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        date,
        type,
        customerName,
        route,
        sourceId,
        sourceType,
      ];
}
