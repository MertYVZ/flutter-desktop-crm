import 'package:drift/drift.dart';

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
