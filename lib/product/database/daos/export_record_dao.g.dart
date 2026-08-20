// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_record_dao.dart';

// ignore_for_file: type=lint
mixin _$ExportRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExportRecordsTable get exportRecords => attachedDatabase.exportRecords;
  $ExportRecordItemsTable get exportRecordItems =>
      attachedDatabase.exportRecordItems;
  $CustomersTable get customers => attachedDatabase.customers;
  ExportRecordDaoManager get managers => ExportRecordDaoManager(this);
}

class ExportRecordDaoManager {
  final _$ExportRecordDaoMixin _db;
  ExportRecordDaoManager(this._db);
  $$ExportRecordsTableTableManager get exportRecords =>
      $$ExportRecordsTableTableManager(_db.attachedDatabase, _db.exportRecords);
  $$ExportRecordItemsTableTableManager get exportRecordItems =>
      $$ExportRecordItemsTableTableManager(
          _db.attachedDatabase, _db.exportRecordItems);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
