// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_dao.dart';

// ignore_for_file: type=lint
mixin _$ReminderDaoMixin on DatabaseAccessor<AppDatabase> {
  $RemindersTable get reminders => attachedDatabase.reminders;
  $CustomersTable get customers => attachedDatabase.customers;
  ReminderDaoManager get managers => ReminderDaoManager(this);
}

class ReminderDaoManager {
  final _$ReminderDaoMixin _db;
  ReminderDaoManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
