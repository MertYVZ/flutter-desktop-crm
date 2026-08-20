import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_product_names.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/import/models/import_detail.dart';
import 'package:Ok/feature/import/models/import_record_list_item.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class ImportService {
  ImportService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<ImportRecordListItem>> getImports() =>
      _databaseService.imports.getImports();

  Future<List<ImportRecordListItem>> searchImports({String? searchQuery}) =>
      _databaseService.imports.searchImports(searchQuery: searchQuery);

  Future<ImportDetail?> getImportById(String id) =>
      _databaseService.imports.getImportDetailById(id);

  Future<String> createImport({
    required String title,
    required String supplierName,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required ExportTotals totals,
    DateTime? shipmentDate,
    DateTime? deliveryDate,
    String? logisticsName,
    int? logisticsCostMinor,
    int? customsCostMinor,
    int? insuranceCostMinor,
    String? notes,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.imports.createImportWithItems(
      record: ImportRecordsCompanion.insert(
        id: id,
        title: title.trim(),
        supplierName: supplierName.trim(),
        products: ExportProductNames.join(
          items.map((item) => item.productName),
        ),
        currency: Value(currency.value),
        totalAmountMinor: totals.sentTotalMinor,
        shipmentDate: Value(shipmentDate),
        deliveryDate: Value(deliveryDate),
        logisticsName: Value(_nullableTrim(logisticsName)),
        logisticsCostMinor: Value(logisticsCostMinor),
        customsCostMinor: Value(customsCostMinor),
        insuranceCostMinor: Value(insuranceCostMinor),
        notes: Value(_nullableTrim(notes)),
        createdAt: now,
        updatedAt: now,
      ),
      items: _itemCompanions(importId: id, items: items, now: now),
    );

    return id;
  }

  Future<void> updateImport({
    required String id,
    required String title,
    required String supplierName,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required ExportTotals totals,
    DateTime? shipmentDate,
    DateTime? deliveryDate,
    String? logisticsName,
    int? logisticsCostMinor,
    int? customsCostMinor,
    int? insuranceCostMinor,
    String? notes,
  }) async {
    final existing = await _databaseService.imports.getImportById(id);
    if (existing == null) {
      throw StateError('Import record not found');
    }

    final now = DateTime.now();
    final updated = existing.copyWith(
      title: title.trim(),
      supplierName: supplierName.trim(),
      products: ExportProductNames.join(
        items.map((item) => item.productName),
      ),
      currency: currency.value,
      totalAmountMinor: totals.sentTotalMinor,
      shipmentDate: Value(shipmentDate),
      deliveryDate: Value(deliveryDate),
      logisticsName: Value(_nullableTrim(logisticsName)),
      logisticsCostMinor: Value(logisticsCostMinor),
      customsCostMinor: Value(customsCostMinor),
      insuranceCostMinor: Value(insuranceCostMinor),
      notes: Value(_nullableTrim(notes)),
      updatedAt: now,
    );

    await _databaseService.imports.updateImportWithItems(
      record: updated,
      items: _itemCompanions(importId: id, items: items, now: now),
    );
  }

  Future<void> deleteImport(String id) async {
    final affectedRows = await _databaseService.imports.softDeleteImport(id);
    if (affectedRows == 0) {
      throw StateError('Import record not found');
    }
  }

  List<ImportRecordItemsCompanion> _itemCompanions({
    required String importId,
    required List<ExportItemData> items,
    required DateTime now,
  }) {
    return [
      for (final item in items)
        ImportRecordItemsCompanion.insert(
          id: _uuid.v4(),
          importId: importId,
          productName: item.productName.trim(),
          unitType: item.unitType,
          quantity: item.quantity,
          wasteUnitType: Value(_nullableTrim(item.wasteUnitType)),
          wasteQuantity: Value(item.wasteQuantity),
          priceMinor: item.priceMinor,
          sortOrder: item.sortOrder,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
