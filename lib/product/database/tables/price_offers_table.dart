import 'package:drift/drift.dart';

class PriceOffers extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get offerDate => dateTime()();
  DateTimeColumn get validityDate => dateTime()();
  TextColumn get customerId => text()();
  TextColumn get contactPerson => text()();
  TextColumn get authorizedPhone => text().nullable()();
  TextColumn get mobilePhone => text().nullable()();
  TextColumn get legalText => text()();
  TextColumn get status => text()();
  TextColumn get discountType => text().nullable()();
  RealColumn get discountPercentage => real().nullable()();
  IntColumn get discountAmountMinor => integer().nullable()();
  TextColumn get discountCurrency => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
