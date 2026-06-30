import 'package:drift/drift.dart';

import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/price_offer_items_table.dart';
import 'package:Ok/product/database/tables/price_offers_table.dart';
import 'package:Ok/product/utility/app_date_utils.dart';

part 'price_offer_dao.g.dart';

@DriftAccessor(tables: [PriceOffers, PriceOfferItems, Customers])
class PriceOfferDao extends DatabaseAccessor<AppDatabase>
    with _$PriceOfferDaoMixin {
  PriceOfferDao(super.db);

  Future<void> applyAutomaticExpiry() async {
    final today = AppDateUtils.normalizeDate(DateTime.now());

    await (update(priceOffers)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.validityDate.isSmallerThanValue(today) &
                t.status.isNotIn([
                  PriceOfferStatus.approved.value,
                  PriceOfferStatus.expired.value,
                ]),
          ))
        .write(
      PriceOffersCompanion(
        status: Value(PriceOfferStatus.expired.value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<PriceOfferListItem>> getOffers() async {
    await applyAutomaticExpiry();
    return searchOffers();
  }

  Future<List<PriceOfferListItem>> searchOffers({
    String? searchQuery,
    OfferType? typeFilter,
    PriceOfferStatus? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await applyAutomaticExpiry();

    final query = select(priceOffers).join([
      innerJoin(customers, customers.id.equalsExp(priceOffers.customerId)),
    ]);

    query.where(priceOffers.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      query.where(
        customers.name.lower().like(pattern) |
            priceOffers.contactPerson.lower().like(pattern) |
            priceOffers.authorizedPhone.lower().like(pattern) |
            priceOffers.mobilePhone.lower().like(pattern),
      );
    }

    if (typeFilter != null) {
      query.where(priceOffers.type.equals(typeFilter.value));
    }

    if (statusFilter != null) {
      query.where(priceOffers.status.equals(statusFilter.value));
    }

    if (startDate != null) {
      query.where(
        priceOffers.offerDate.isBiggerOrEqualValue(_startOfDay(startDate)),
      );
    }

    if (endDate != null) {
      query.where(
        priceOffers.offerDate.isSmallerOrEqualValue(_endOfDay(endDate)),
      );
    }

    query.orderBy([OrderingTerm.desc(priceOffers.offerDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<List<PriceOfferListItem>> getOffersByCustomerId(
    String customerId,
  ) async {
    await applyAutomaticExpiry();

    final query = select(priceOffers).join([
      innerJoin(customers, customers.id.equalsExp(priceOffers.customerId)),
    ])
      ..where(
        priceOffers.deletedAt.isNull() &
            priceOffers.customerId.equals(customerId),
      )
      ..orderBy([OrderingTerm.desc(priceOffers.offerDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<PriceOfferDetail?> getOfferDetailById(String id) async {
    await applyAutomaticExpiry();

    final offerQuery = select(priceOffers).join([
      innerJoin(customers, customers.id.equalsExp(priceOffers.customerId)),
    ])
      ..where(priceOffers.id.equals(id) & priceOffers.deletedAt.isNull());

    final offerRow = await offerQuery.getSingleOrNull();
    if (offerRow == null) {
      return null;
    }

    final offer = offerRow.readTable(priceOffers);
    final customer = offerRow.readTable(customers);

    final items = await (select(priceOfferItems)
          ..where(
            (t) => t.offerId.equals(id) & t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return PriceOfferDetail(
      id: offer.id,
      type: offer.type,
      offerDate: offer.offerDate,
      validityDate: offer.validityDate,
      customerId: offer.customerId,
      customerName: customer.name,
      contactPerson: offer.contactPerson,
      authorizedPhone: offer.authorizedPhone,
      mobilePhone: offer.mobilePhone,
      legalText: offer.legalText,
      status: offer.status,
      discount: PriceOfferDiscount.fromStored(
        type: offer.discountType,
        percentage: offer.discountPercentage,
        amountMinor: offer.discountAmountMinor,
        currency: offer.discountCurrency,
      ),
      createdAt: offer.createdAt,
      updatedAt: offer.updatedAt,
      items: items
          .map(
            (item) => PriceOfferItemData(
              id: item.id,
              productName: item.productName,
              unitType: item.unitType,
              quantity: item.quantity,
              priceMinor: item.priceMinor,
              currency: item.currency,
              sortOrder: item.sortOrder,
            ),
          )
          .toList(),
    );
  }

  Future<String> createOfferWithItems({
    required PriceOffersCompanion offer,
    required List<PriceOfferItemsCompanion> items,
  }) async {
    return transaction(() async {
      await into(priceOffers).insert(offer);
      for (final item in items) {
        await into(priceOfferItems).insert(item);
      }
      return offer.id.value;
    });
  }

  Future<void> updateOfferWithItems({
    required PriceOffer offer,
    required List<PriceOfferItemsCompanion> items,
  }) async {
    await transaction(() async {
      final success = await update(priceOffers).replace(offer);
      if (!success) {
        throw StateError('Price offer update failed');
      }

      final now = DateTime.now();
      await (update(priceOfferItems)
            ..where(
              (t) => t.offerId.equals(offer.id) & t.deletedAt.isNull(),
            ))
          .write(PriceOfferItemsCompanion(deletedAt: Value(now)));

      for (final item in items) {
        await into(priceOfferItems).insert(item);
      }
    });
  }

  Future<int> softDeleteOfferAndItems(String id) async {
    final now = DateTime.now();
    return transaction(() async {
      final offerRows = await (update(priceOffers)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .write(PriceOffersCompanion(deletedAt: Value(now)));

      await (update(priceOfferItems)
            ..where((t) => t.offerId.equals(id) & t.deletedAt.isNull()))
          .write(PriceOfferItemsCompanion(deletedAt: Value(now)));

      return offerRows;
    });
  }

  PriceOfferListItem _mapRowToListItem(TypedResult row) {
    final offer = row.readTable(priceOffers);
    final customer = row.readTable(customers);

    return PriceOfferListItem(
      id: offer.id,
      type: offer.type,
      offerDate: offer.offerDate,
      validityDate: offer.validityDate,
      customerId: offer.customerId,
      customerName: customer.name,
      contactPerson: offer.contactPerson,
      authorizedPhone: offer.authorizedPhone,
      mobilePhone: offer.mobilePhone,
      status: offer.status,
      createdAt: offer.createdAt,
      updatedAt: offer.updatedAt,
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
