// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_record_dao.dart';

// ignore_for_file: type=lint
mixin _$ImportRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImportRecordsTable get importRecords => attachedDatabase.importRecords;
  ImportRecordDaoManager get managers => ImportRecordDaoManager(this);
}

class ImportRecordDaoManager {
  final _$ImportRecordDaoMixin _db;
  ImportRecordDaoManager(this._db);
  $$ImportRecordsTableTableManager get importRecords =>
      $$ImportRecordsTableTableManager(_db.attachedDatabase, _db.importRecords);
}
