// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_dao.dart';

// ignore_for_file: type=lint
mixin _$MeetingDaoMixin on DatabaseAccessor<AppDatabase> {
  $MeetingsTable get meetings => attachedDatabase.meetings;
  $CustomersTable get customers => attachedDatabase.customers;
  MeetingDaoManager get managers => MeetingDaoManager(this);
}

class MeetingDaoManager {
  final _$MeetingDaoMixin _db;
  MeetingDaoManager(this._db);
  $$MeetingsTableTableManager get meetings =>
      $$MeetingsTableTableManager(_db.attachedDatabase, _db.meetings);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
