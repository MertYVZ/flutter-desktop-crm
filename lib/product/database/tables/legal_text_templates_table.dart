import 'package:drift/drift.dart';

/// Default legal text templates per offer type, editable via settings in future.
class LegalTextTemplates extends Table {
  TextColumn get offerType => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {offerType};
}
