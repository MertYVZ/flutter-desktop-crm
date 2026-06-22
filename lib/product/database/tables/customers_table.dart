import 'package:drift/drift.dart';

/// CRM customer records with soft-delete support.
class Customers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get type => text()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get city => text().nullable()();

  TextColumn get country => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
