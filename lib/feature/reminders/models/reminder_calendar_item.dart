import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:equatable/equatable.dart';

final class ReminderCalendarItem extends Equatable {
  const ReminderCalendarItem({
    required this.reminderId,
    required this.customerName,
    required this.title,
    required this.period,
    required this.occurrenceDate,
    required this.nextReminderDate,
    required this.status,
    this.note,
  });

  final String reminderId;
  final String customerName;
  final String title;
  final ReminderPeriod period;
  final DateTime occurrenceDate;
  final DateTime nextReminderDate;
  final ReminderStatus status;
  final String? note;

  @override
  List<Object?> get props => [
        reminderId,
        customerName,
        title,
        period,
        occurrenceDate,
        nextReminderDate,
        status,
        note,
      ];
}
