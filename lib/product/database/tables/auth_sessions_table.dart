import 'package:drift/drift.dart';

import 'package:Ok/product/database/tables/users_table.dart';

/// Active and historical authentication sessions.
class AuthSessions extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text().references(Users, #id)();

  TextColumn get token => text()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get expiresAt => dateTime()();

  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
