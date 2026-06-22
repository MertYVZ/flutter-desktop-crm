import 'package:drift/drift.dart';

class Meetings extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()();
  TextColumn get subject => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
