import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
import 'package:Ok/feature/price_list/models/price_list_list_item.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/price_list_items_table.dart';
import 'package:Ok/product/database/tables/price_lists_table.dart';

part 'price_list_dao.g.dart';

@DriftAccessor(tables: [PriceLists, PriceListItems])
class PriceListDao extends DatabaseAccessor<AppDatabase>
    with _$PriceListDaoMixin {
  PriceListDao(super.db);

  static const _uuid = Uuid();

  Future<PriceList?> getActivePriceList() => (select(priceLists)
        ..where(
          (t) =>
              t.status.equals(PriceListStatus.active.value) &
              t.deletedAt.isNull(),
        ))
      .getSingleOrNull();

  Future<PriceList?> getPriceListById(String id) => (select(priceLists)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<List<PriceListListItem>> getArchivedPriceLists({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final trimmedSearch = searchQuery?.trim();
    final pattern = trimmedSearch != null && trimmedSearch.isNotEmpty
        ? '%${trimmedSearch.toLowerCase()}%'
        : null;

    final lists = await (select(priceLists)
          ..where((t) {
            var expression =
                t.status.equals(PriceListStatus.archived.value) &
                    t.deletedAt.isNull();

            if (pattern != null) {
              expression = expression &
                  (t.title.lower().like(pattern) |
                      t.description.lower().like(pattern));
            }

            if (startDate != null) {
              expression = expression &
                  t.effectiveDate.isBiggerOrEqualValue(_startOfDay(startDate));
            }

            if (endDate != null) {
              expression = expression &
                  t.effectiveDate.isSmallerOrEqualValue(_endOfDay(endDate));
            }

            return expression;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.archivedAt)]))
        .get();

    final result = <PriceListListItem>[];

    for (final list in lists) {
      final itemCount = await _countItems(list.id);
      result.add(_mapToListItem(list, itemCount));
    }

    return result;
  }

  Future<List<PriceListItemModel>> getItemsByPriceListId(
    String priceListId, {
    String? searchQuery,
    String? currencyFilter,
  }) async {
    final trimmedSearch = searchQuery?.trim();
    final pattern = trimmedSearch != null && trimmedSearch.isNotEmpty
        ? '%${trimmedSearch.toLowerCase()}%'
        : null;

    final rows = await (select(priceListItems)
          ..where((t) {
            var expression = t.priceListId.equals(priceListId) &
                t.deletedAt.isNull();

            if (pattern != null) {
              expression = expression &
                  (t.productName.lower().like(pattern) |
                      t.currency.lower().like(pattern));
            }

            if (currencyFilter != null && currencyFilter.isNotEmpty) {
              expression = expression & t.currency.equals(currencyFilter);
            }

            return expression;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.productName)]))
        .get();

    return rows.map(_mapToItemModel).toList();
  }

  Future<bool> hasDuplicateProduct({
    required String priceListId,
    required String productName,
    required String currency,
    String? excludeItemId,
  }) async {
    final normalizedName = productName.trim().toLowerCase();

    final existing = await (select(priceListItems)
          ..where((t) {
            var expression = t.priceListId.equals(priceListId) &
                t.deletedAt.isNull() &
                t.productName.lower().equals(normalizedName) &
                t.currency.equals(currency);

            if (excludeItemId != null) {
              expression = expression & t.id.equals(excludeItemId).not();
            }

            return expression;
          }))
        .getSingleOrNull();

    return existing != null;
  }

  Future<String> createActivePriceList({
    required String id,
    required String title,
    required DateTime effectiveDate,
    String? description,
    required bool copyFromActive,
  }) async {
    return transaction(() async {
      final now = DateTime.now();
      PriceList? sourceList;

      final currentActive = await getActivePriceList();
      if (currentActive != null) {
        sourceList = currentActive;
        await (update(priceLists)..where((t) => t.id.equals(currentActive.id)))
            .write(
          PriceListsCompanion(
            status: Value(PriceListStatus.archived.value),
            archivedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      await into(priceLists).insert(
        PriceListsCompanion.insert(
          id: id,
          title: title.trim(),
          description: Value(_nullableTrim(description)),
          effectiveDate: effectiveDate,
          status: PriceListStatus.active.value,
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (copyFromActive && sourceList != null) {
        await _copyItems(fromListId: sourceList.id, toListId: id, now: now);
      }

      return id;
    });
  }

  Future<void> archivePriceList(String id) async {
    final now = DateTime.now();
    final affected = await (update(priceLists)..where(
          (t) =>
              t.id.equals(id) &
              t.status.equals(PriceListStatus.active.value) &
              t.deletedAt.isNull(),
        ))
        .write(
      PriceListsCompanion(
        status: Value(PriceListStatus.archived.value),
        archivedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (affected == 0) {
      throw StateError('Active price list not found');
    }
  }

  Future<bool> updatePriceList(PriceList record) =>
      update(priceLists).replace(record);

  Future<String> insertItem(PriceListItemsCompanion item) async {
    await into(priceListItems).insert(item);
    return item.id.value;
  }

  Future<bool> updateItem(PriceListItem record) =>
      update(priceListItems).replace(record);

  Future<int> softDeleteItem(String id) => (update(priceListItems)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(
        PriceListItemsCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> softDeleteArchivedPriceList(String id) => transaction(() async {
        final now = DateTime.now();
        final affected = await (update(priceLists)
              ..where(
                (t) =>
                    t.id.equals(id) &
                    t.status.equals(PriceListStatus.archived.value) &
                    t.deletedAt.isNull(),
              ))
            .write(
          PriceListsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        if (affected == 0) {
          throw StateError('Archived price list not found');
        }

        await (update(priceListItems)
              ..where(
                (t) => t.priceListId.equals(id) & t.deletedAt.isNull(),
              ))
            .write(
          PriceListItemsCompanion(deletedAt: Value(now)),
        );
      });

  Future<PriceListItem?> getItemById(String id) => (select(priceListItems)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<void> _copyItems({
    required String fromListId,
    required String toListId,
    required DateTime now,
  }) async {
    final sourceItems = await (select(priceListItems)
          ..where(
            (t) => t.priceListId.equals(fromListId) & t.deletedAt.isNull(),
          ))
        .get();

    for (final item in sourceItems) {
      await into(priceListItems).insert(
        PriceListItemsCompanion.insert(
          id: _uuid.v4(),
          priceListId: toListId,
          productName: item.productName,
          currency: item.currency,
          minPriceMinor: item.minPriceMinor,
          maxPriceMinor: item.maxPriceMinor,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<int> _countItems(String priceListId) async {
    final query = selectOnly(priceListItems)
      ..addColumns([priceListItems.id.count()])
      ..where(
        priceListItems.priceListId.equals(priceListId) &
            priceListItems.deletedAt.isNull(),
      );

    final row = await query.getSingle();
    return row.read(priceListItems.id.count()) ?? 0;
  }

  PriceListListItem _mapToListItem(PriceList list, int itemCount) =>
      PriceListListItem(
        id: list.id,
        title: list.title,
        description: list.description,
        effectiveDate: list.effectiveDate,
        status: list.status,
        createdAt: list.createdAt,
        updatedAt: list.updatedAt,
        archivedAt: list.archivedAt,
        itemCount: itemCount,
      );

  PriceListItemModel _mapToItemModel(PriceListItem item) => PriceListItemModel(
        id: item.id,
        priceListId: item.priceListId,
        productName: item.productName,
        currency: item.currency,
        minPriceMinor: item.minPriceMinor,
        maxPriceMinor: item.maxPriceMinor,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
