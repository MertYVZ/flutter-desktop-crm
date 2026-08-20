import 'package:drift/drift.dart';

class ExportRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get customerId => text()();
  TextColumn get customerNameSnapshot => text().nullable()();
  TextColumn get productName => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('TRY'))();
  RealColumn get quantityTon => real()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get totalPriceMinor => integer()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get bank => text().nullable()();
  DateTimeColumn get firstPaymentDate => dateTime().nullable()();
  IntColumn get firstPaymentAmountMinor => integer().nullable()();
  DateTimeColumn get lastPaymentDate => dateTime().nullable()();
  IntColumn get lastPaymentAmountMinor => integer().nullable()();
  RealColumn get wasteKg => real().nullable()();
  IntColumn get netTotalAmountMinor => integer().nullable()();
  TextColumn get logisticsName => text().nullable()();
  DateTimeColumn get shipmentDate => dateTime().nullable()();
  DateTimeColumn get deliveryDate => dateTime().nullable()();
  IntColumn get logisticsCostMinor => integer().nullable()();
  IntColumn get customsCostMinor => integer().nullable()();
  IntColumn get insuranceCostMinor => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
