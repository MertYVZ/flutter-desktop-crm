import 'package:drift/drift.dart';

class PriceOfferItems extends Table {
  TextColumn get id => text()();
  TextColumn get offerId => text()();
  TextColumn get productName => text()();
  TextColumn get unitType => text()();
  RealColumn get quantity => real()();
  IntColumn get priceMinor => integer()();
  TextColumn get currency => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
