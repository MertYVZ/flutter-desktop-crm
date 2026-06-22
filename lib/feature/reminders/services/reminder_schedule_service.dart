import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/product/utility/app_date_utils.dart';

final class ReminderScheduleService {
  ReminderScheduleService._();

  static const _maxLoopIterations = 10000;

  static DateTime calculateNextReminderDate(
    DateTime currentDate,
    ReminderPeriod period,
  ) {
    final normalized = normalizeDate(currentDate);

    switch (period) {
      case ReminderPeriod.daily:
        return normalized.add(const Duration(days: 1));
      case ReminderPeriod.weekly:
        return normalized.add(const Duration(days: 7));
      case ReminderPeriod.biweekly:
        return normalized.add(const Duration(days: 14));
      case ReminderPeriod.monthly:
        return _addMonths(normalized, 1);
      case ReminderPeriod.sixMonthly:
        return _addMonths(normalized, 6);
      case ReminderPeriod.nineMonthly:
        return _addMonths(normalized, 9);
      case ReminderPeriod.yearly:
        return _addMonths(normalized, 12);
    }
  }

  static List<DateTime> generateOccurrencesForMonth({
    required DateTime anchorDate,
    required ReminderPeriod period,
    required DateTime month,
  }) {
    final monthStart = startOfMonth(month);
    final monthEnd = endOfMonth(month);
    var current = normalizeDate(anchorDate);

    if (current.isAfter(monthEnd)) {
      return const [];
    }

    var safety = 0;
    while (current.isBefore(monthStart) && safety < _maxLoopIterations) {
      current = calculateNextReminderDate(current, period);
      safety++;
      if (current.isAfter(monthEnd)) {
        return const [];
      }
    }

    final occurrences = <DateTime>[];
    while (!current.isAfter(monthEnd) && safety < _maxLoopIterations) {
      occurrences.add(current);
      current = calculateNextReminderDate(current, period);
      safety++;
    }

    return occurrences;
  }

  static DateTime normalizeDate(DateTime date) => AppDateUtils.normalizeDate(date);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  static bool isSameDay(DateTime a, DateTime b) {
    final normalizedA = normalizeDate(a);
    final normalizedB = normalizeDate(b);
    return normalizedA.year == normalizedB.year &&
        normalizedA.month == normalizedB.month &&
        normalizedA.day == normalizedB.day;
  }

  static bool isOverdue(DateTime date) {
    final today = normalizeDate(DateTime.now());
    return normalizeDate(date).isBefore(today);
  }

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isFuture(DateTime date) {
    final today = normalizeDate(DateTime.now());
    return normalizeDate(date).isAfter(today);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final totalMonths = date.month + months;
    final year = date.year + ((totalMonths - 1) ~/ 12);
    final month = ((totalMonths - 1) % 12) + 1;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
    return DateTime(year, month, day);
  }
}
