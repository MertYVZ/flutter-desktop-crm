import 'package:drift/drift.dart';

/// Customer contact persons with soft-delete support.
class CustomerContacts extends Table {
  TextColumn get id => text()();

  TextColumn get customerId => text()();

  TextColumn get fullName => text()();

  TextColumn get title => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get phone => text().nullable()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
