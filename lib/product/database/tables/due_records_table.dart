import 'package:drift/drift.dart';

class DueRecords extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get invoiceNo => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
