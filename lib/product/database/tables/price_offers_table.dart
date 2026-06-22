import 'package:drift/drift.dart';

class PriceOffers extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get offerDate => dateTime()();
  TextColumn get customerId => text()();
  TextColumn get contactPerson => text()();
  TextColumn get authorizedPhone => text().nullable()();
  TextColumn get mobilePhone => text().nullable()();
  TextColumn get legalText => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
