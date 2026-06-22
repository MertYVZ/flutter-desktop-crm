import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class ScrapQualityService {
  ScrapQualityService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<ScrapQualityListItem>> getRecords() =>
      _databaseService.scrapQualityRecords.getRecords();

  Future<List<ScrapQualityListItem>> searchRecords({
    String? searchQuery,
    String? unitFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _databaseService.scrapQualityRecords.searchRecords(
      searchQuery: searchQuery,
      unitFilter: unitFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ScrapQualityRecord?> getRecordById(String id) =>
      _databaseService.scrapQualityRecords.getRecordById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createRecord({
    required String customerId,
    required String quality,
    required double quantity,
    required String unit,
    required DateTime recordDate,
    String? note,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.scrapQualityRecords.insertRecord(
      ScrapQualityRecordsCompanion.insert(
        id: id,
        customerId: customerId,
        quality: quality.trim(),
        quantity: quantity,
        unit: unit.trim(),
        recordDate: recordDate,
        note: Value(_nullableTrim(note)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateRecord({
    required String id,
    required String customerId,
    required String quality,
    required double quantity,
    required String unit,
    required DateTime recordDate,
    String? note,
  }) async {
    final existing = await getRecordById(id);
    if (existing == null) {
      throw StateError('Scrap quality record not found');
    }

    final updated = existing.copyWith(
      customerId: customerId,
      quality: quality.trim(),
      quantity: quantity,
      unit: unit.trim(),
      recordDate: recordDate,
      note: Value(_nullableTrim(note)),
      updatedAt: DateTime.now(),
    );

    final success =
        await _databaseService.scrapQualityRecords.updateRecord(updated);
    if (!success) {
      throw StateError('Scrap quality record update failed');
    }
  }

  Future<void> deleteRecord(String id) async {
    final affectedRows =
        await _databaseService.scrapQualityRecords.softDeleteRecord(id);
    if (affectedRows == 0) {
      throw StateError('Scrap quality record not found');
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
