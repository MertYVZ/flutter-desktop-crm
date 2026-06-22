import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/feature/reminders/services/reminder_schedule_service.dart';
import 'package:equatable/equatable.dart';

final class ReminderListItem extends Equatable {
  const ReminderListItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.period,
    required this.startDate,
    required this.nextReminderDate,
    required this.lastCompletedAt,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String period;
  final String title;
  final DateTime startDate;
  final DateTime nextReminderDate;
  final DateTime? lastCompletedAt;
  final String? note;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderPeriod? get reminderPeriod => ReminderPeriodX.fromValue(period);

  ReminderStatus? get reminderStatus => ReminderStatusX.fromValue(status);

  bool get isOverdue =>
      ReminderScheduleService.isOverdue(nextReminderDate);

  bool get isToday => ReminderScheduleService.isToday(nextReminderDate);

  bool get isFuture => ReminderScheduleService.isFuture(nextReminderDate);

  bool get isPassive => status == ReminderStatus.passive.value;

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        title,
        period,
        startDate,
        nextReminderDate,
        lastCompletedAt,
        note,
        status,
        createdAt,
        updatedAt,
      ];
}
