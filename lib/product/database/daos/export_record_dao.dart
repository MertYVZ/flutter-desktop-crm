import 'package:Ok/feature/export/models/export_detail.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_record_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/export_record_items_table.dart';
import 'package:Ok/product/database/tables/export_records_table.dart';
import 'package:drift/drift.dart';

part 'export_record_dao.g.dart';

@DriftAccessor(tables: [ExportRecords, ExportRecordItems, Customers])
class ExportRecordDao extends DatabaseAccessor<AppDatabase>
    with _$ExportRecordDaoMixin {
  ExportRecordDao(super.db);

  Future<List<ExportRecordListItem>> getExports() => searchExports();

  Future<List<ExportRecordListItem>> searchExports({
    String? searchQuery,
  }) async {
    final query = select(exportRecords).join([
      leftOuterJoin(
          customers, customers.id.equalsExp(exportRecords.customerId)),
    ])
      ..where(exportRecords.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      query.where(
        exportRecords.title.lower().like(pattern) |
            customers.name.lower().like(pattern) |
            exportRecords.customerNameSnapshot.lower().like(pattern) |
            exportRecords.productName.lower().like(pattern),
      );
    }

    query.orderBy([OrderingTerm.desc(exportRecords.createdAt)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<List<ExportRecordListItem>> getExportsByCustomerId(
    String customerId,
  ) async {
    final query = select(exportRecords).join([
      leftOuterJoin(
          customers, customers.id.equalsExp(exportRecords.customerId)),
    ])
      ..where(
        exportRecords.deletedAt.isNull() &
            exportRecords.customerId.equals(customerId),
      )
      ..orderBy([OrderingTerm.desc(exportRecords.createdAt)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<ExportRecord?> getExportById(String id) => (select(exportRecords)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<ExportDetail?> getExportDetailById(String id) async {
    final record = await getExportById(id);
    if (record == null) {
      return null;
    }

    final items = await (select(exportRecordItems)
          ..where((t) => t.exportId.equals(id) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return ExportDetail(
      record: record,
      items: items.map(_mapItem).toList(),
    );
  }

  Future<String> createExportWithItems({
    required ExportRecordsCompanion record,
    required List<ExportRecordItemsCompanion> items,
  }) {
    return transaction(() async {
      await into(exportRecords).insert(record);
      for (final item in items) {
        await into(exportRecordItems).insert(item);
      }
      return record.id.value;
    });
  }

  Future<void> updateExportWithItems({
    required ExportRecord record,
    required List<ExportRecordItemsCompanion> items,
  }) {
    return transaction(() async {
      final success = await update(exportRecords).replace(record);
      if (!success) {
        throw StateError('Export record update failed');
      }

      final now = DateTime.now();
      await (update(exportRecordItems)
            ..where(
              (t) => t.exportId.equals(record.id) & t.deletedAt.isNull(),
            ))
          .write(ExportRecordItemsCompanion(deletedAt: Value(now)));

      for (final item in items) {
        await into(exportRecordItems).insert(item);
      }
    });
  }

  Future<int> insertExport(ExportRecordsCompanion record) =>
      into(exportRecords).insert(record);

  Future<bool> updateExport(ExportRecord record) =>
      update(exportRecords).replace(record);

  Future<int> softDeleteExport(String id) {
    final now = DateTime.now();
    return transaction(() async {
      final affectedRows = await (update(exportRecords)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .write(ExportRecordsCompanion(deletedAt: Value(now)));

      await (update(exportRecordItems)
            ..where((t) => t.exportId.equals(id) & t.deletedAt.isNull()))
          .write(ExportRecordItemsCompanion(deletedAt: Value(now)));

      return affectedRows;
    });
  }

  ExportRecordListItem _mapRowToListItem(TypedResult row) {
    final record = row.readTable(exportRecords);
    final customer = row.readTableOrNull(customers);
    final snapshot = record.customerNameSnapshot?.trim();
    final joinedName = customer?.name.trim();

    return ExportRecordListItem(
      id: record.id,
      title: record.title,
      customerId: record.customerId,
      customerName: (snapshot != null && snapshot.isNotEmpty)
          ? snapshot
          : (joinedName ?? ''),
      productName: record.productName,
      quantityTon: record.quantityTon,
      totalPriceMinor: record.totalPriceMinor,
      currency: record.currency,
      shipmentDate: record.shipmentDate,
      deliveryDate: record.deliveryDate,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  ExportItemData _mapItem(ExportRecordItem item) {
    return ExportItemData(
      id: item.id,
      productName: item.productName,
      unitType: item.unitType,
      quantity: item.quantity,
      wasteUnitType: item.wasteUnitType,
      wasteQuantity: item.wasteQuantity,
      priceMinor: item.priceMinor,
      sortOrder: item.sortOrder,
    );
  }
}
