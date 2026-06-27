import 'package:drift/drift.dart';

import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
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
    String? customerIdFilter,
    String? cityFilter,
    String? scrapTypeFilter,
    ScrapSalesStatus? salesStatusFilter,
    DateTime? startDate,
    DateTime? endDate,
    double? minOfferPrice,
    double? maxOfferPrice,
    bool onlyPurchased = false,
    bool onlyNotPurchased = false,
    bool onlyPending = false,
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
            scrapQualityRecords.unit.lower().like(pattern) |
            scrapQualityRecords.city.lower().like(pattern) |
            scrapQualityRecords.note.lower().like(pattern),
      );
    }

    if (unitFilter != null && unitFilter.isNotEmpty) {
      query.where(scrapQualityRecords.unit.equals(unitFilter));
    }

    if (customerIdFilter != null && customerIdFilter.isNotEmpty) {
      query.where(scrapQualityRecords.customerId.equals(customerIdFilter));
    }

    if (cityFilter != null && cityFilter.isNotEmpty) {
      query.where(scrapQualityRecords.city.equals(cityFilter));
    }

    if (scrapTypeFilter != null && scrapTypeFilter.isNotEmpty) {
      query.where(scrapQualityRecords.quality.equals(scrapTypeFilter));
    }

    if (salesStatusFilter != null) {
      query.where(scrapQualityRecords.salesStatus.equals(salesStatusFilter.value));
    }

    if (onlyPurchased) {
      query.where(
        scrapQualityRecords.salesStatus.equals(ScrapSalesStatus.purchased.value),
      );
    }

    if (onlyNotPurchased) {
      query.where(
        scrapQualityRecords.salesStatus
            .equals(ScrapSalesStatus.notPurchased.value),
      );
    }

    if (onlyPending) {
      query.where(
        scrapQualityRecords.salesStatus.isIn([
          ScrapSalesStatus.waiting.value,
          ScrapSalesStatus.unresolved.value,
        ]),
      );
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

    if (minOfferPrice != null) {
      query.where(
        scrapQualityRecords.offerPrice.isBiggerOrEqualValue(minOfferPrice),
      );
    }

    if (maxOfferPrice != null) {
      query.where(
        scrapQualityRecords.offerPrice.isSmallerOrEqualValue(maxOfferPrice),
      );
    }

    query.orderBy([OrderingTerm.desc(scrapQualityRecords.recordDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<List<ScrapQualityListItem>> getRecordsByCustomerId(
    String customerId,
  ) async {
    final query = select(scrapQualityRecords).join([
      innerJoin(
        customers,
        customers.id.equalsExp(scrapQualityRecords.customerId),
      ),
    ])
      ..where(
        scrapQualityRecords.deletedAt.isNull() &
            scrapQualityRecords.customerId.equals(customerId),
      )
      ..orderBy([OrderingTerm.desc(scrapQualityRecords.recordDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<List<String>> getDistinctScrapTypes() async {
    final rows = await customSelect(
      '''
      SELECT DISTINCT quality
      FROM scrap_quality_records
      WHERE deleted_at IS NULL AND TRIM(quality) != ''
      ORDER BY quality COLLATE NOCASE ASC
      ''',
      readsFrom: {scrapQualityRecords},
    ).get();

    return rows
        .map((row) => row.read<String>('quality').trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Future<List<String>> getDistinctCities() async {
    final rows = await customSelect(
      '''
      SELECT DISTINCT city
      FROM scrap_quality_records
      WHERE deleted_at IS NULL AND city IS NOT NULL AND TRIM(city) != ''
      ORDER BY city COLLATE NOCASE ASC
      ''',
      readsFrom: {scrapQualityRecords},
    ).get();

    return rows
        .map((row) => row.read<String>('city').trim())
        .where((value) => value.isNotEmpty)
        .toList();
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
      customerNameSnapshot: record.customerNameSnapshot,
      quality: record.quality,
      quantity: record.quantity,
      unit: record.unit,
      quantityKg: record.quantityKg,
      city: record.city,
      salesStatus: record.salesStatus,
      offerPrice: record.offerPrice,
      targetPrice: record.targetPrice,
      lostReason: record.lostReason,
      followUpDate: record.followUpDate,
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
