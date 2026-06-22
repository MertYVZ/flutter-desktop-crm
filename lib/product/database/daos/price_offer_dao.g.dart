// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_offer_dao.dart';

// ignore_for_file: type=lint
mixin _$PriceOfferDaoMixin on DatabaseAccessor<AppDatabase> {
  $PriceOffersTable get priceOffers => attachedDatabase.priceOffers;
  $PriceOfferItemsTable get priceOfferItems => attachedDatabase.priceOfferItems;
  $CustomersTable get customers => attachedDatabase.customers;
  PriceOfferDaoManager get managers => PriceOfferDaoManager(this);
}

class PriceOfferDaoManager {
  final _$PriceOfferDaoMixin _db;
  PriceOfferDaoManager(this._db);
  $$PriceOffersTableTableManager get priceOffers =>
      $$PriceOffersTableTableManager(_db.attachedDatabase, _db.priceOffers);
  $$PriceOfferItemsTableTableManager get priceOfferItems =>
      $$PriceOfferItemsTableTableManager(
          _db.attachedDatabase, _db.priceOfferItems);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
