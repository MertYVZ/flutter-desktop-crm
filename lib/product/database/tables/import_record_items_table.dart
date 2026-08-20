import 'package:drift/drift.dart';

class ImportRecordItems extends Table {
  TextColumn get id => text()();
  TextColumn get importId => text()();
  TextColumn get productName => text()();
  TextColumn get unitType => text()();
  RealColumn get quantity => real()();
  TextColumn get wasteUnitType => text().nullable()();
  RealColumn get wasteQuantity => real().withDefault(const Constant(0))();
  IntColumn get priceMinor => integer()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
