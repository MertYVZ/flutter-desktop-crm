// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_contact_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerContactDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomerContactsTable get customerContacts =>
      attachedDatabase.customerContacts;
  CustomerContactDaoManager get managers => CustomerContactDaoManager(this);
}

class CustomerContactDaoManager {
  final _$CustomerContactDaoMixin _db;
  CustomerContactDaoManager(this._db);
  $$CustomerContactsTableTableManager get customerContacts =>
      $$CustomerContactsTableTableManager(
          _db.attachedDatabase, _db.customerContacts);
}
