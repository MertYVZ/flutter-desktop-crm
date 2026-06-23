import 'package:drift/drift.dart';

import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customer_contacts_table.dart';

part 'customer_contact_dao.g.dart';

@DriftAccessor(tables: [CustomerContacts])
class CustomerContactDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerContactDaoMixin {
  CustomerContactDao(super.db);

  Future<List<CustomerContact>> getContactsByCustomerId(String customerId) =>
      (select(customerContacts)
            ..where(
              (t) => t.customerId.equals(customerId) & t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.isPrimary),
              (t) => OrderingTerm.asc(t.fullName),
            ]))
          .get();

  Future<CustomerContact?> getContactById(String id) => (select(customerContacts)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<int> insertContact(CustomerContactsCompanion contact) =>
      into(customerContacts).insert(contact);

  Future<bool> updateContact(CustomerContact contact) =>
      update(customerContacts).replace(contact);

  Future<int> softDeleteContact(String id) => (update(customerContacts)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(CustomerContactsCompanion(deletedAt: Value(DateTime.now())));

  Future<void> clearPrimaryForCustomer(String customerId) async {
    await (update(customerContacts)
          ..where(
            (t) => t.customerId.equals(customerId) & t.deletedAt.isNull(),
          ))
        .write(const CustomerContactsCompanion(isPrimary: Value(false)));
  }
}
