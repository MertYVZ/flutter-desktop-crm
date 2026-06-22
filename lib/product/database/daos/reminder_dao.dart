import 'package:drift/drift.dart';

import 'package:Ok/feature/reminders/models/reminder_date_state_filter.dart';
import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/reminders_table.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders, Customers])
class ReminderDao extends DatabaseAccessor<AppDatabase> with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Future<List<ReminderListItem>> getReminders() => searchReminders();

  Future<List<ReminderListItem>> searchReminders({
    String? searchQuery,
    ReminderPeriod? periodFilter,
    ReminderStatus? statusFilter,
    ReminderDateStateFilter? dateStateFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final startOfToday = _startOfDay(DateTime.now());
    final endOfToday = _endOfDay(DateTime.now());

    final query = select(reminders).join([
      innerJoin(customers, customers.id.equalsExp(reminders.customerId)),
    ]);

    query.where(reminders.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      final matchingPeriods = ReminderPeriod.values
          .where(
            (period) =>
                period.label.toLowerCase().contains(trimmedSearch.toLowerCase()),
          )
          .map((period) => period.value)
          .toList();

      var searchCondition = customers.name.lower().like(pattern) |
          reminders.title.lower().like(pattern) |
          reminders.note.lower().like(pattern);

      if (matchingPeriods.isNotEmpty) {
        searchCondition =
            searchCondition | reminders.period.isIn(matchingPeriods);
      }

      query.where(searchCondition);
    }

    if (periodFilter != null) {
      query.where(reminders.period.equals(periodFilter.value));
    }

    if (statusFilter != null) {
      query.where(reminders.status.equals(statusFilter.value));
    }

    if (dateStateFilter != null) {
      switch (dateStateFilter) {
        case ReminderDateStateFilter.today:
          query.where(
            reminders.nextReminderDate.isBiggerOrEqualValue(startOfToday) &
                reminders.nextReminderDate.isSmallerOrEqualValue(endOfToday),
          );
        case ReminderDateStateFilter.overdue:
          query.where(
            reminders.nextReminderDate.isSmallerThanValue(startOfToday),
          );
        case ReminderDateStateFilter.future:
          query.where(
            reminders.nextReminderDate.isBiggerThanValue(endOfToday),
          );
      }
    }

    if (startDate != null) {
      query.where(
        reminders.nextReminderDate.isBiggerOrEqualValue(_startOfDay(startDate)),
      );
    }

    if (endDate != null) {
      query.where(
        reminders.nextReminderDate.isSmallerOrEqualValue(_endOfDay(endDate)),
      );
    }

    query.orderBy([OrderingTerm.asc(reminders.nextReminderDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<List<ReminderListItem>> getActiveRemindersForCalendar() async {
    final query = select(reminders).join([
      innerJoin(customers, customers.id.equalsExp(reminders.customerId)),
    ])
      ..where(
        reminders.deletedAt.isNull() &
            reminders.status.equals(ReminderStatus.active.value),
      );

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<Reminder?> getReminderById(String id) => (select(reminders)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<ReminderListItem?> getReminderListItemById(String id) async {
    final query = select(reminders).join([
      innerJoin(customers, customers.id.equalsExp(reminders.customerId)),
    ])
      ..where(reminders.id.equals(id) & reminders.deletedAt.isNull());

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    return _mapRowToListItem(row);
  }

  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<bool> updateReminder(Reminder reminder) =>
      update(reminders).replace(reminder);

  Future<int> softDeleteReminder(String id) => (update(reminders)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(RemindersCompanion(deletedAt: Value(DateTime.now())));

  ReminderListItem _mapRowToListItem(TypedResult row) {
    final reminder = row.readTable(reminders);
    final customer = row.readTable(customers);

    return ReminderListItem(
      id: reminder.id,
      customerId: reminder.customerId,
      customerName: customer.name,
      title: reminder.title,
      period: reminder.period,
      startDate: reminder.startDate,
      nextReminderDate: reminder.nextReminderDate,
      lastCompletedAt: reminder.lastCompletedAt,
      note: reminder.note,
      status: reminder.status,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
