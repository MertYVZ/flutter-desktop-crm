import 'package:drift/drift.dart';

import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/scrap_quality_records_table.dart';

part 'scrap_quality_dao.g.dart';

@DriftAccessor(tables: [ScrapQualityRecords, Customers])
class ScrapQualityDao extends DatabaseAccessor<AppDatabase>
    with _$ScrapQualityDaoMixin {
  ScrapQualityDao(super.db);

  Future<List<ScrapQualityListItem>> getRecords() => searchRecords();

  Future<List<ScrapQualityListItem>> searchRecords({
    String? searchQuery,
    String? unitFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = select(scrapQualityRecords).join([
      innerJoin(
        customers,
        customers.id.equalsExp(scrapQualityRecords.customerId),
      ),
    ]);

    query.where(scrapQualityRecords.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      query.where(
        customers.name.lower().like(pattern) |
            scrapQualityRecords.quality.lower().like(pattern) |
            scrapQualityRecords.unit.lower().like(pattern),
      );
    }

    if (unitFilter != null && unitFilter.isNotEmpty) {
      query.where(scrapQualityRecords.unit.equals(unitFilter));
    }

    if (startDate != null) {
      query.where(
        scrapQualityRecords.recordDate
            .isBiggerOrEqualValue(_startOfDay(startDate)),
      );
    }

    if (endDate != null) {
      query.where(
        scrapQualityRecords.recordDate
            .isSmallerOrEqualValue(_endOfDay(endDate)),
      );
    }

    query.orderBy([OrderingTerm.desc(scrapQualityRecords.recordDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<ScrapQualityRecord?> getRecordById(String id) =>
      (select(scrapQualityRecords)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .getSingleOrNull();

  Future<int> insertRecord(ScrapQualityRecordsCompanion record) =>
      into(scrapQualityRecords).insert(record);

  Future<bool> updateRecord(ScrapQualityRecord record) =>
      update(scrapQualityRecords).replace(record);

  Future<int> softDeleteRecord(String id) => (update(scrapQualityRecords)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(
        ScrapQualityRecordsCompanion(deletedAt: Value(DateTime.now())),
      );

  ScrapQualityListItem _mapRowToListItem(TypedResult row) {
    final record = row.readTable(scrapQualityRecords);
    final customer = row.readTable(customers);

    return ScrapQualityListItem(
      id: record.id,
      customerId: record.customerId,
      customerName: customer.name,
      quality: record.quality,
      quantity: record.quantity,
      unit: record.unit,
      recordDate: record.recordDate,
      note: record.note,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
