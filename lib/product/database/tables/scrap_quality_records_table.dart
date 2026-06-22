import 'package:drift/drift.dart';

class ScrapQualityRecords extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get quality => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
