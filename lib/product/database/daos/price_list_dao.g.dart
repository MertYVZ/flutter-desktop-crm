// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_list_dao.dart';

// ignore_for_file: type=lint
mixin _$PriceListDaoMixin on DatabaseAccessor<AppDatabase> {
  $PriceListsTable get priceLists => attachedDatabase.priceLists;
  $PriceListItemsTable get priceListItems => attachedDatabase.priceListItems;
  PriceListDaoManager get managers => PriceListDaoManager(this);
}

class PriceListDaoManager {
  final _$PriceListDaoMixin _db;
  PriceListDaoManager(this._db);
  $$PriceListsTableTableManager get priceLists =>
      $$PriceListsTableTableManager(_db.attachedDatabase, _db.priceLists);
  $$PriceListItemsTableTableManager get priceListItems =>
      $$PriceListItemsTableTableManager(
          _db.attachedDatabase, _db.priceListItems);
}
