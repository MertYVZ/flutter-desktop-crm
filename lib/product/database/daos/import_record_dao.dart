import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/import/models/import_detail.dart';
import 'package:Ok/feature/import/models/import_record_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/import_record_items_table.dart';
import 'package:Ok/product/database/tables/import_records_table.dart';
import 'package:drift/drift.dart';

part 'import_record_dao.g.dart';

@DriftAccessor(tables: [ImportRecords, ImportRecordItems])
class ImportRecordDao extends DatabaseAccessor<AppDatabase>
    with _$ImportRecordDaoMixin {
  ImportRecordDao(super.db);

  Future<List<ImportRecordListItem>> getImports() => searchImports();

  Future<List<ImportRecordListItem>> searchImports({
    String? searchQuery,
  }) async {
    final query = select(importRecords)..where((t) => t.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      query.where(
        (t) =>
            t.title.lower().like(pattern) |
            t.supplierName.lower().like(pattern) |
            t.products.lower().like(pattern),
      );
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<ImportRecord?> getImportById(String id) => (select(importRecords)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<ImportDetail?> getImportDetailById(String id) async {
    final record = await getImportById(id);
    if (record == null) {
      return null;
    }

    final items = await (select(importRecordItems)
          ..where((t) => t.importId.equals(id) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return ImportDetail(
      record: record,
      items: items.map(_mapItem).toList(),
    );
  }

  Future<String> createImportWithItems({
    required ImportRecordsCompanion record,
    required List<ImportRecordItemsCompanion> items,
  }) {
    return transaction(() async {
      await into(importRecords).insert(record);
      for (final item in items) {
        await into(importRecordItems).insert(item);
      }
      return record.id.value;
    });
  }

  Future<void> updateImportWithItems({
    required ImportRecord record,
    required List<ImportRecordItemsCompanion> items,
  }) {
    return transaction(() async {
      final success = await update(importRecords).replace(record);
      if (!success) {
        throw StateError('Import record update failed');
      }

      final now = DateTime.now();
      await (update(importRecordItems)
            ..where(
              (t) => t.importId.equals(record.id) & t.deletedAt.isNull(),
            ))
          .write(ImportRecordItemsCompanion(deletedAt: Value(now)));

      for (final item in items) {
        await into(importRecordItems).insert(item);
      }
    });
  }

  Future<int> insertImport(ImportRecordsCompanion record) =>
      into(importRecords).insert(record);

  Future<bool> updateImport(ImportRecord record) =>
      update(importRecords).replace(record);

  Future<int> softDeleteImport(String id) {
    final now = DateTime.now();
    return transaction(() async {
      final affectedRows = await (update(importRecords)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .write(ImportRecordsCompanion(deletedAt: Value(now)));

      await (update(importRecordItems)
            ..where((t) => t.importId.equals(id) & t.deletedAt.isNull()))
          .write(ImportRecordItemsCompanion(deletedAt: Value(now)));

      return affectedRows;
    });
  }

  ImportRecordListItem _mapRowToListItem(ImportRecord record) {
    return ImportRecordListItem(
      id: record.id,
      title: record.title,
      supplierName: record.supplierName,
      products: record.products,
      totalAmountMinor: record.totalAmountMinor,
      currency: record.currency,
      shipmentDate: record.shipmentDate,
      deliveryDate: record.deliveryDate,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  ExportItemData _mapItem(ImportRecordItem item) {
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
