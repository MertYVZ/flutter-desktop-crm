// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrap_quality_dao.dart';

// ignore_for_file: type=lint
mixin _$ScrapQualityDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScrapQualityRecordsTable get scrapQualityRecords =>
      attachedDatabase.scrapQualityRecords;
  $CustomersTable get customers => attachedDatabase.customers;
  ScrapQualityDaoManager get managers => ScrapQualityDaoManager(this);
}

class ScrapQualityDaoManager {
  final _$ScrapQualityDaoMixin _db;
  ScrapQualityDaoManager(this._db);
  $$ScrapQualityRecordsTableTableManager get scrapQualityRecords =>
      $$ScrapQualityRecordsTableTableManager(
          _db.attachedDatabase, _db.scrapQualityRecords);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
