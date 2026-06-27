import 'package:Ok/feature/reminders/models/reminder_calendar_item.dart';
import 'package:Ok/feature/reminders/models/reminder_date_state_filter.dart';
import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/feature/reminders/services/reminder_schedule_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class RemindersService {
  RemindersService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<ReminderListItem>> getReminders() =>
      _databaseService.reminders.getReminders();

  Future<List<ReminderListItem>> searchReminders({
    String? searchQuery,
    ReminderPeriod? periodFilter,
    ReminderStatus? statusFilter,
    ReminderDateStateFilter? dateStateFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _databaseService.reminders.searchReminders(
      searchQuery: searchQuery,
      periodFilter: periodFilter,
      statusFilter: statusFilter,
      dateStateFilter: dateStateFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ReminderListItem?> getReminderById(String id) =>
      _databaseService.reminders.getReminderListItemById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createReminder({
    required String customerId,
    required String title,
    required ReminderPeriod period,
    required DateTime startDate,
    String? note,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final normalizedStartDate = ReminderScheduleService.normalizeDate(startDate);

    await _databaseService.reminders.insertReminder(
      RemindersCompanion.insert(
        id: id,
        customerId: customerId,
        title: title.trim(),
        period: period.value,
        startDate: normalizedStartDate,
        nextReminderDate: normalizedStartDate,
        status: ReminderStatus.active.value,
        note: Value(_nullableTrim(note)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateReminder({
    required String id,
    required String customerId,
    required String title,
    required ReminderPeriod period,
    required DateTime startDate,
    required ReminderStatus status,
    String? note,
  }) async {
    final existing = await _databaseService.reminders.getReminderById(id);
    if (existing == null) {
      throw StateError('Reminder not found');
    }

    final normalizedStartDate =
        ReminderScheduleService.normalizeDate(startDate);
    final scheduleChanged = existing.period != period.value ||
        ReminderScheduleService.normalizeDate(existing.startDate) !=
            normalizedStartDate;
    final nextReminderDate = scheduleChanged
        ? normalizedStartDate
        : ReminderScheduleService.normalizeDate(existing.nextReminderDate);

    final updated = existing.copyWith(
      customerId: customerId,
      title: title.trim(),
      period: period.value,
      startDate: normalizedStartDate,
      nextReminderDate: nextReminderDate,
      status: status.value,
      note: Value(_nullableTrim(note)),
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.reminders.updateReminder(updated);
    if (!success) {
      throw StateError('Reminder update failed');
    }
  }

  Future<void> completeReminder(String id) async {
    final existing = await _databaseService.reminders.getReminderById(id);
    if (existing == null) {
      throw StateError('Reminder not found');
    }

    final period = ReminderPeriodX.fromValue(existing.period);
    if (period == null) {
      throw StateError('Invalid reminder period');
    }

    final now = DateTime.now();
    final updated = existing.copyWith(
      lastCompletedAt: Value(now),
      nextReminderDate: ReminderScheduleService.calculateNextReminderDate(
        existing.nextReminderDate,
        period,
      ),
      updatedAt: now,
    );

    final success = await _databaseService.reminders.updateReminder(updated);
    if (!success) {
      throw StateError('Reminder complete failed');
    }
  }

  Future<void> deleteReminder(String id) async {
    final affectedRows =
        await _databaseService.reminders.softDeleteReminder(id);
    if (affectedRows == 0) {
      throw StateError('Reminder not found');
    }
  }

  Future<List<ReminderCalendarItem>> getReminderCalendarItemsForMonth(
    DateTime month,
  ) async {
    final reminders =
        await _databaseService.reminders.getActiveRemindersForCalendar();
    final items = <ReminderCalendarItem>[];

    for (final reminder in reminders) {
      final period = reminder.reminderPeriod;
      final status = reminder.reminderStatus;
      if (period == null || status == null) {
        continue;
      }

      final occurrences = ReminderScheduleService.generateOccurrencesForMonth(
        anchorDate: reminder.startDate,
        period: period,
        month: month,
      );

      for (final occurrenceDate in occurrences) {
        items.add(
          ReminderCalendarItem(
            reminderId: reminder.id,
            customerName: reminder.customerName,
            title: reminder.title,
            period: period,
            occurrenceDate: occurrenceDate,
            nextReminderDate: reminder.nextReminderDate,
            status: status,
            note: reminder.note,
          ),
        );
      }
    }

    return items;
  }

  String? _nullableTrim(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
