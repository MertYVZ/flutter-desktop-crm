import 'package:drift/drift.dart';

class ImportRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get supplierName => text()();
  TextColumn get products => text()();
  TextColumn get currency => text().withDefault(const Constant('TRY'))();
  IntColumn get totalAmountMinor => integer()();
  DateTimeColumn get shipmentDate => dateTime().nullable()();
  DateTimeColumn get deliveryDate => dateTime().nullable()();
  TextColumn get logisticsName => text().nullable()();
  IntColumn get logisticsCostMinor => integer().nullable()();
  IntColumn get customsCostMinor => integer().nullable()();
  IntColumn get insuranceCostMinor => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
