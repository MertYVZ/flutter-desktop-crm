import 'package:drift/drift.dart';

class ScrapQualityRecords extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get customerNameSnapshot => text().nullable()();
  TextColumn get quality => text()();
  TextColumn get qualityGrade => text().nullable()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get quantityKg => real().withDefault(const Constant(0))();
  TextColumn get city => text().nullable()();
  TextColumn get salesStatus =>
      text().withDefault(const Constant('unresolved'))();
  RealColumn get offerPrice => real().nullable()();
  RealColumn get targetPrice => real().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get lostReason => text().nullable()();
  DateTimeColumn get followUpDate => dateTime().nullable()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
