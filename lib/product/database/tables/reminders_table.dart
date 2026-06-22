import 'package:drift/drift.dart';

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get title => text()();
  TextColumn get period => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextReminderDate => dateTime()();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
