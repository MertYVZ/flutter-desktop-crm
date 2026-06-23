import 'package:drift/drift.dart';

class PriceLists extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get effectiveDate => dateTime()();

  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
