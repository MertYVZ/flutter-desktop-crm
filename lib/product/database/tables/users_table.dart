import 'package:drift/drift.dart';

/// Local CRM users with password hashing and account lock metadata.
class Users extends Table {
  TextColumn get id => text()();

  TextColumn get username => text().unique()();

  TextColumn get displayName => text()();

  TextColumn get passwordHash => text()();

  TextColumn get passwordSalt => text()();

  IntColumn get passwordIterations => integer()();

  TextColumn get role => text()();

  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get mustChangePassword =>
      boolean().withDefault(const Constant(false))();

  IntColumn get failedLoginCount =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get lockedUntil => dateTime().nullable()();

  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
