import 'package:Ok/feature/import/models/import_record_list_item.dart';
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

  Future<ImportRecord?> getImportById(String id) =>
      _databaseService.imports.getImportById(id);

  Future<String> createImport({
    required String title,
    required String supplierName,
    required String products,
    required int totalAmountMinor,
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

    await _databaseService.imports.insertImport(
      ImportRecordsCompanion.insert(
        id: id,
        title: title.trim(),
        supplierName: supplierName.trim(),
        products: products.trim(),
        totalAmountMinor: totalAmountMinor,
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
    );

    return id;
  }

  Future<void> updateImport({
    required String id,
    required String title,
    required String supplierName,
    required String products,
    required int totalAmountMinor,
    DateTime? shipmentDate,
    DateTime? deliveryDate,
    String? logisticsName,
    int? logisticsCostMinor,
    int? customsCostMinor,
    int? insuranceCostMinor,
    String? notes,
  }) async {
    final existing = await getImportById(id);
    if (existing == null) {
      throw StateError('Import record not found');
    }

    final updated = existing.copyWith(
      title: title.trim(),
      supplierName: supplierName.trim(),
      products: products.trim(),
      totalAmountMinor: totalAmountMinor,
      shipmentDate: Value(shipmentDate),
      deliveryDate: Value(deliveryDate),
      logisticsName: Value(_nullableTrim(logisticsName)),
      logisticsCostMinor: Value(logisticsCostMinor),
      customsCostMinor: Value(customsCostMinor),
      insuranceCostMinor: Value(insuranceCostMinor),
      notes: Value(_nullableTrim(notes)),
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.imports.updateImport(updated);
    if (!success) {
      throw StateError('Import record update failed');
    }
  }

  Future<void> deleteImport(String id) async {
    final affectedRows = await _databaseService.imports.softDeleteImport(id);
    if (affectedRows == 0) {
      throw StateError('Import record not found');
    }
  }

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
