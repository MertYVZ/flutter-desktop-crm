// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'due_record_dao.dart';

// ignore_for_file: type=lint
mixin _$DueRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $DueRecordsTable get dueRecords => attachedDatabase.dueRecords;
  $CustomersTable get customers => attachedDatabase.customers;
  DueRecordDaoManager get managers => DueRecordDaoManager(this);
}

class DueRecordDaoManager {
  final _$DueRecordDaoMixin _db;
  DueRecordDaoManager(this._db);
  $$DueRecordsTableTableManager get dueRecords =>
      $$DueRecordsTableTableManager(_db.attachedDatabase, _db.dueRecords);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
