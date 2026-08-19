import 'package:Ok/feature/import/models/import_record_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/import_records_table.dart';
import 'package:drift/drift.dart';

part 'import_record_dao.g.dart';

@DriftAccessor(tables: [ImportRecords])
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

  Future<int> insertImport(ImportRecordsCompanion record) =>
      into(importRecords).insert(record);

  Future<bool> updateImport(ImportRecord record) =>
      update(importRecords).replace(record);

  Future<int> softDeleteImport(String id) => (update(importRecords)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(ImportRecordsCompanion(deletedAt: Value(DateTime.now())));

  ImportRecordListItem _mapRowToListItem(ImportRecord record) {
    return ImportRecordListItem(
      id: record.id,
      title: record.title,
      supplierName: record.supplierName,
      products: record.products,
      totalAmountMinor: record.totalAmountMinor,
      shipmentDate: record.shipmentDate,
      deliveryDate: record.deliveryDate,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
