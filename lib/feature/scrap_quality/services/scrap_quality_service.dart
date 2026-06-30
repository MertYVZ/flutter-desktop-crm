import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_lost_reason.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_kg_utils.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
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
  }) {
    return _databaseService.scrapQualityRecords.searchRecords(
      searchQuery: searchQuery,
      unitFilter: unitFilter,
      customerIdFilter: customerIdFilter,
      cityFilter: cityFilter,
      scrapTypeFilter: scrapTypeFilter,
      salesStatusFilter: salesStatusFilter,
      startDate: startDate,
      endDate: endDate,
      minOfferPrice: minOfferPrice,
      maxOfferPrice: maxOfferPrice,
      onlyPurchased: onlyPurchased,
      onlyNotPurchased: onlyNotPurchased,
      onlyPending: onlyPending,
    );
  }

  Future<List<String>> getDistinctScrapTypes() =>
      _databaseService.scrapQualityRecords.getDistinctScrapTypes();

  Future<List<String>> getDistinctCities() =>
      _databaseService.scrapQualityRecords.getDistinctCities();

  Future<ScrapQualityRecord?> getRecordById(String id) =>
      _databaseService.scrapQualityRecords.getRecordById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createRecord({
    required String customerId,
    required String customerName,
    required String scrapType,
    required String qualityGrade,
    required double quantity,
    required String unit,
    required ScrapQualityUnit? unitEnum,
    required double quantityKg,
    required DateTime recordDate,
    required ScrapSalesStatus salesStatus,
    CurrencyType? currency,
    String? city,
    double? offerPrice,
    double? targetPrice,
    ScrapLostReason? lostReason,
    String? customLostReason,
    DateTime? followUpDate,
    String? note,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final normalizedDate = AppDateUtils.normalizeDate(recordDate);

    await _databaseService.scrapQualityRecords.insertRecord(
      ScrapQualityRecordsCompanion.insert(
        id: id,
        customerId: customerId,
        customerNameSnapshot: Value(customerName.trim()),
        quality: scrapType.trim(),
        qualityGrade: Value(_nullableTrim(qualityGrade)),
        quantity: quantity,
        unit: unit.trim(),
        quantityKg: Value(quantityKg),
        city: Value(_nullableTrim(city)),
        salesStatus: Value(salesStatus.value),
        offerPrice: Value(offerPrice),
        targetPrice: Value(targetPrice),
        currency: Value((currency ?? CurrencyType.try_).value),
        lostReason: Value(
          _resolveLostReason(lostReason, customLostReason),
        ),
        followUpDate: Value(
          followUpDate == null ? null : AppDateUtils.normalizeDate(followUpDate),
        ),
        recordDate: normalizedDate,
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
    required String customerName,
    required String scrapType,
    required String qualityGrade,
    required double quantity,
    required String unit,
    required ScrapQualityUnit? unitEnum,
    required double quantityKg,
    required DateTime recordDate,
    required ScrapSalesStatus salesStatus,
    CurrencyType? currency,
    String? city,
    double? offerPrice,
    double? targetPrice,
    ScrapLostReason? lostReason,
    String? customLostReason,
    DateTime? followUpDate,
    String? note,
  }) async {
    final existing = await getRecordById(id);
    if (existing == null) {
      throw StateError('Scrap quality record not found');
    }

    final updated = existing.copyWith(
      customerId: customerId,
      customerNameSnapshot: Value(customerName.trim()),
      quality: scrapType.trim(),
      qualityGrade: Value(_nullableTrim(qualityGrade)),
      quantity: quantity,
      unit: unit.trim(),
      quantityKg: quantityKg,
      city: Value(_nullableTrim(city)),
      salesStatus: salesStatus.value,
      offerPrice: Value(offerPrice),
      targetPrice: Value(targetPrice),
      currency: Value((currency ?? CurrencyType.try_).value),
      lostReason: Value(
        _resolveLostReason(lostReason, customLostReason),
      ),
      followUpDate: Value(
        followUpDate == null ? null : AppDateUtils.normalizeDate(followUpDate),
      ),
      recordDate: AppDateUtils.normalizeDate(recordDate),
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

  double resolveQuantityKg({
    required double quantity,
    required String unitLabel,
    required ScrapQualityUnit? unit,
    double? manualQuantityKg,
  }) {
    return ScrapKgUtils.resolveQuantityKg(
      quantity: quantity,
      unitLabel: unitLabel,
      unit: unit,
      manualQuantityKg: manualQuantityKg,
    );
  }

  String? _resolveLostReason(
    ScrapLostReason? lostReason,
    String? customLostReason,
  ) {
    if (lostReason == null) {
      return _nullableTrim(customLostReason);
    }

    if (lostReason == ScrapLostReason.other) {
      final custom = _nullableTrim(customLostReason);
      return custom ?? lostReason.label;
    }

    return lostReason.value;
  }

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
