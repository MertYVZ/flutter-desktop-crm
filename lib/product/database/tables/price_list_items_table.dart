import 'package:drift/drift.dart';

class PriceListItems extends Table {
  TextColumn get id => text()();

  TextColumn get priceListId => text()();

  TextColumn get productName => text()();

  TextColumn get currency => text()();

  IntColumn get minPriceMinor => integer()();

  IntColumn get maxPriceMinor => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
