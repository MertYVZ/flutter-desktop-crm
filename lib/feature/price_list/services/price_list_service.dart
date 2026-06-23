import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
import 'package:Ok/feature/price_list/models/price_list_list_item.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class PriceListService {
  PriceListService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<PriceList?> getActivePriceList() =>
      _databaseService.priceLists.getActivePriceList();

  Future<PriceList?> getPriceListById(String id) =>
      _databaseService.priceLists.getPriceListById(id);

  Future<List<PriceListListItem>> getArchivedPriceLists({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _databaseService.priceLists.getArchivedPriceLists(
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
      );

  Future<List<PriceListItemModel>> getItemsByPriceListId(
    String priceListId, {
    String? searchQuery,
    String? currencyFilter,
  }) =>
      _databaseService.priceLists.getItemsByPriceListId(
        priceListId,
        searchQuery: searchQuery,
        currencyFilter: currencyFilter,
      );

  Future<String> createActivePriceList({
    required String title,
    required DateTime effectiveDate,
    String? description,
    required bool copyFromActive,
  }) async {
    final id = _uuid.v4();
    return _databaseService.priceLists.createActivePriceList(
      id: id,
      title: title.trim(),
      effectiveDate: effectiveDate,
      description: description,
      copyFromActive: copyFromActive,
    );
  }

  Future<void> archivePriceList(String id) =>
      _databaseService.priceLists.archivePriceList(id);

  Future<void> updatePriceList({
    required String id,
    required String title,
    required DateTime effectiveDate,
    String? description,
  }) async {
    final existing = await getPriceListById(id);
    if (existing == null) {
      throw StateError('Price list not found');
    }

    if (existing.status != PriceListStatus.active.value) {
      throw StateError('Only active price lists can be updated');
    }

    final updated = existing.copyWith(
      title: title.trim(),
      effectiveDate: effectiveDate,
      description: Value(_nullableTrim(description)),
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.priceLists.updatePriceList(updated);
    if (!success) {
      throw StateError('Price list update failed');
    }
  }

  Future<String> createItem({
    required String priceListId,
    required String productName,
    required PriceListCurrency currency,
    required int minPriceMinor,
    required int maxPriceMinor,
  }) async {
    final list = await getPriceListById(priceListId);
    if (list == null) {
      throw StateError('Price list not found');
    }

    if (list.status != PriceListStatus.active.value) {
      throw StateError('Only active price lists allow item changes');
    }

    final isDuplicate = await _databaseService.priceLists.hasDuplicateProduct(
      priceListId: priceListId,
      productName: productName,
      currency: currency.value,
    );
    if (isDuplicate) {
      throw Exception('duplicate');
    }

    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.priceLists.insertItem(
      PriceListItemsCompanion.insert(
        id: id,
        priceListId: priceListId,
        productName: productName.trim(),
        currency: currency.value,
        minPriceMinor: minPriceMinor,
        maxPriceMinor: maxPriceMinor,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateItem({
    required String id,
    required String productName,
    required PriceListCurrency currency,
    required int minPriceMinor,
    required int maxPriceMinor,
  }) async {
    final existing = await _databaseService.priceLists.getItemById(id);
    if (existing == null) {
      throw StateError('Item not found');
    }

    final list = await getPriceListById(existing.priceListId);
    if (list == null || list.status != PriceListStatus.active.value) {
      throw StateError('Only active price lists allow item changes');
    }

    final isDuplicate = await _databaseService.priceLists.hasDuplicateProduct(
      priceListId: existing.priceListId,
      productName: productName,
      currency: currency.value,
      excludeItemId: id,
    );
    if (isDuplicate) {
      throw Exception('duplicate');
    }

    final updated = existing.copyWith(
      productName: productName.trim(),
      currency: currency.value,
      minPriceMinor: minPriceMinor,
      maxPriceMinor: maxPriceMinor,
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.priceLists.updateItem(updated);
    if (!success) {
      throw StateError('Item update failed');
    }
  }

  Future<void> deleteItem(String id) async {
    final existing = await _databaseService.priceLists.getItemById(id);
    if (existing == null) {
      throw StateError('Item not found');
    }

    final list = await getPriceListById(existing.priceListId);
    if (list == null || list.status != PriceListStatus.active.value) {
      throw StateError('Only active price lists allow item changes');
    }

    final affected = await _databaseService.priceLists.softDeleteItem(id);
    if (affected == 0) {
      throw StateError('Item not found');
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
