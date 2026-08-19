import 'package:Ok/feature/export/models/export_record_list_item.dart';
import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
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

  Future<ExportRecord?> getExportById(String id) =>
      _databaseService.exports.getExportById(id);

  Future<List<ExportRecordListItem>> getExportsByCustomerId(
    String customerId,
  ) =>
      _databaseService.exports.getExportsByCustomerId(customerId);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<List<PriceListItemModel>> getActivePriceListProducts() async {
    final list = await _databaseService.priceLists.getActivePriceList();
    if (list == null) {
      return const [];
    }

    return _databaseService.priceLists.getItemsByPriceListId(list.id);
  }

  Future<String> createExport({
    required String title,
    required String customerId,
    required String productName,
    required double quantityTon,
    required int unitPriceMinor,
    required int totalPriceMinor,
    String? customerNameSnapshot,
    String? productId,
    String? paymentMethod,
    String? bank,
    DateTime? firstPaymentDate,
    int? firstPaymentAmountMinor,
    DateTime? lastPaymentDate,
    int? lastPaymentAmountMinor,
    double? wasteKg,
    int? netTotalAmountMinor,
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

    await _databaseService.exports.insertExport(
      ExportRecordsCompanion.insert(
        id: id,
        title: title.trim(),
        customerId: customerId,
        customerNameSnapshot: Value(_nullableTrim(customerNameSnapshot)),
        productName: productName.trim(),
        productId: Value(_nullableTrim(productId)),
        quantityTon: quantityTon,
        unitPriceMinor: unitPriceMinor,
        totalPriceMinor: totalPriceMinor,
        paymentMethod: Value(_nullableTrim(paymentMethod)),
        bank: Value(_nullableTrim(bank)),
        firstPaymentDate: Value(firstPaymentDate),
        firstPaymentAmountMinor: Value(firstPaymentAmountMinor),
        lastPaymentDate: Value(lastPaymentDate),
        lastPaymentAmountMinor: Value(lastPaymentAmountMinor),
        wasteKg: Value(wasteKg),
        netTotalAmountMinor: Value(netTotalAmountMinor),
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
    );

    return id;
  }

  Future<void> updateExport({
    required String id,
    required String title,
    required String customerId,
    required String productName,
    required double quantityTon,
    required int unitPriceMinor,
    required int totalPriceMinor,
    String? customerNameSnapshot,
    String? productId,
    String? paymentMethod,
    String? bank,
    DateTime? firstPaymentDate,
    int? firstPaymentAmountMinor,
    DateTime? lastPaymentDate,
    int? lastPaymentAmountMinor,
    double? wasteKg,
    int? netTotalAmountMinor,
    String? logisticsName,
    DateTime? shipmentDate,
    DateTime? deliveryDate,
    int? logisticsCostMinor,
    int? customsCostMinor,
    int? insuranceCostMinor,
    String? notes,
  }) async {
    final existing = await getExportById(id);
    if (existing == null) {
      throw StateError('Export record not found');
    }

    final updated = existing.copyWith(
      title: title.trim(),
      customerId: customerId,
      customerNameSnapshot: Value(_nullableTrim(customerNameSnapshot)),
      productName: productName.trim(),
      productId: Value(_nullableTrim(productId)),
      quantityTon: quantityTon,
      unitPriceMinor: unitPriceMinor,
      totalPriceMinor: totalPriceMinor,
      paymentMethod: Value(_nullableTrim(paymentMethod)),
      bank: Value(_nullableTrim(bank)),
      firstPaymentDate: Value(firstPaymentDate),
      firstPaymentAmountMinor: Value(firstPaymentAmountMinor),
      lastPaymentDate: Value(lastPaymentDate),
      lastPaymentAmountMinor: Value(lastPaymentAmountMinor),
      wasteKg: Value(wasteKg),
      netTotalAmountMinor: Value(netTotalAmountMinor),
      logisticsName: Value(_nullableTrim(logisticsName)),
      shipmentDate: Value(shipmentDate),
      deliveryDate: Value(deliveryDate),
      logisticsCostMinor: Value(logisticsCostMinor),
      customsCostMinor: Value(customsCostMinor),
      insuranceCostMinor: Value(insuranceCostMinor),
      notes: Value(_nullableTrim(notes)),
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.exports.updateExport(updated);
    if (!success) {
      throw StateError('Export record update failed');
    }
  }

  Future<void> deleteExport(String id) async {
    final affectedRows = await _databaseService.exports.softDeleteExport(id);
    if (affectedRows == 0) {
      throw StateError('Export record not found');
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
