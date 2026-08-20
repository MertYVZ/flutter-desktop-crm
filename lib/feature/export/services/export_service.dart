import 'package:Ok/feature/export/models/export_detail.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_product_names.dart';
import 'package:Ok/feature/export/models/export_record_list_item.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class ExportService {
  ExportService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<ExportRecordListItem>> getExports() =>
      _databaseService.exports.getExports();

  Future<List<ExportRecordListItem>> searchExports({String? searchQuery}) =>
      _databaseService.exports.searchExports(searchQuery: searchQuery);

  Future<ExportDetail?> getExportById(String id) =>
      _databaseService.exports.getExportDetailById(id);

  Future<List<ExportRecordListItem>> getExportsByCustomerId(
    String customerId,
  ) =>
      _databaseService.exports.getExportsByCustomerId(customerId);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createExport({
    required String title,
    required String customerId,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required ExportTotals totals,
    String? customerNameSnapshot,
    String? paymentMethod,
    String? bank,
    DateTime? firstPaymentDate,
    int? firstPaymentAmountMinor,
    DateTime? lastPaymentDate,
    int? lastPaymentAmountMinor,
    String? logisticsName,
    DateTime? shipmentDate,
    DateTime? deliveryDate,
    int? logisticsCostMinor,
    int? customsCostMinor,
    int? insuranceCostMinor,
    String? notes,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.exports.createExportWithItems(
      record: ExportRecordsCompanion.insert(
        id: id,
        title: title.trim(),
        customerId: customerId,
        customerNameSnapshot: Value(_nullableTrim(customerNameSnapshot)),
        productName: ExportProductNames.join(
          items.map((item) => item.productName),
        ),
        currency: Value(currency.value),
        quantityTon: snapshotQuantityTon(items),
        unitPriceMinor: items.first.priceMinor,
        totalPriceMinor: totals.sentTotalMinor,
        paymentMethod: Value(_nullableTrim(paymentMethod)),
        bank: Value(_nullableTrim(bank)),
        firstPaymentDate: Value(firstPaymentDate),
        firstPaymentAmountMinor: Value(firstPaymentAmountMinor),
        lastPaymentDate: Value(lastPaymentDate),
        lastPaymentAmountMinor: Value(lastPaymentAmountMinor),
        wasteKg: Value(snapshotWasteKg(items)),
        netTotalAmountMinor: Value(totals.netTotalMinor),
        logisticsName: Value(_nullableTrim(logisticsName)),
        shipmentDate: Value(shipmentDate),
        deliveryDate: Value(deliveryDate),
        logisticsCostMinor: Value(logisticsCostMinor),
        customsCostMinor: Value(customsCostMinor),
        insuranceCostMinor: Value(insuranceCostMinor),
        notes: Value(_nullableTrim(notes)),
        createdAt: now,
        updatedAt: now,
      ),
      items: _itemCompanions(exportId: id, items: items, now: now),
    );

    return id;
  }

  Future<void> updateExport({
    required String id,
    required String title,
    required String customerId,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required ExportTotals totals,
    String? customerNameSnapshot,
    String? paymentMethod,
    String? bank,
    DateTime? firstPaymentDate,
    int? firstPaymentAmountMinor,
    DateTime? lastPaymentDate,
    int? lastPaymentAmountMinor,
    String? logisticsName,
    DateTime? shipmentDate,
    DateTime? deliveryDate,
    int? logisticsCostMinor,
    int? customsCostMinor,
    int? insuranceCostMinor,
    String? notes,
  }) async {
    final existing = await _databaseService.exports.getExportById(id);
    if (existing == null) {
      throw StateError('Export record not found');
    }

    final now = DateTime.now();
    final updated = existing.copyWith(
      title: title.trim(),
      customerId: customerId,
      customerNameSnapshot: Value(_nullableTrim(customerNameSnapshot)),
      productName: ExportProductNames.join(
        items.map((item) => item.productName),
      ),
      currency: currency.value,
      quantityTon: snapshotQuantityTon(items),
      unitPriceMinor: items.first.priceMinor,
      totalPriceMinor: totals.sentTotalMinor,
      paymentMethod: Value(_nullableTrim(paymentMethod)),
      bank: Value(_nullableTrim(bank)),
      firstPaymentDate: Value(firstPaymentDate),
      firstPaymentAmountMinor: Value(firstPaymentAmountMinor),
      lastPaymentDate: Value(lastPaymentDate),
      lastPaymentAmountMinor: Value(lastPaymentAmountMinor),
      wasteKg: Value(snapshotWasteKg(items)),
      netTotalAmountMinor: Value(totals.netTotalMinor),
      logisticsName: Value(_nullableTrim(logisticsName)),
      shipmentDate: Value(shipmentDate),
      deliveryDate: Value(deliveryDate),
      logisticsCostMinor: Value(logisticsCostMinor),
      customsCostMinor: Value(customsCostMinor),
      insuranceCostMinor: Value(insuranceCostMinor),
      notes: Value(_nullableTrim(notes)),
      updatedAt: now,
    );

    await _databaseService.exports.updateExportWithItems(
      record: updated,
      items: _itemCompanions(exportId: id, items: items, now: now),
    );
  }

  Future<void> deleteExport(String id) async {
    final affectedRows = await _databaseService.exports.softDeleteExport(id);
    if (affectedRows == 0) {
      throw StateError('Export record not found');
    }
  }

  List<ExportRecordItemsCompanion> _itemCompanions({
    required String exportId,
    required List<ExportItemData> items,
    required DateTime now,
  }) {
    return [
      for (final item in items)
        ExportRecordItemsCompanion.insert(
          id: _uuid.v4(),
          exportId: exportId,
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
