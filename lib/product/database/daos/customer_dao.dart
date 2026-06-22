import 'package:drift/drift.dart';

import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';

part 'customer_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase> with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<List<Customer>> getActiveCustomers() => (select(customers)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  Future<List<Customer>> getSelectableCustomers() => (select(customers)
        ..where(
          (t) => t.deletedAt.isNull() & t.status.equals('active'),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<List<Customer>> searchCustomers({
    String? searchQuery,
    String? typeFilter,
    String? statusFilter,
    String? cityFilter,
  }) {
    return (select(customers)
          ..where((t) {
            var expression = t.deletedAt.isNull();

            final trimmedSearch = searchQuery?.trim();
            if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
              final pattern = '%${trimmedSearch.toLowerCase()}%';
              expression = expression &
                  (t.name.lower().like(pattern) |
                      t.phone.lower().like(pattern) |
                      t.email.lower().like(pattern) |
                      t.city.lower().like(pattern));
            }

            if (typeFilter != null && typeFilter.isNotEmpty) {
              expression = expression & t.type.equals(typeFilter);
            }

            if (statusFilter != null && statusFilter.isNotEmpty) {
              expression = expression & t.status.equals(statusFilter);
            }

            final trimmedCity = cityFilter?.trim();
            if (trimmedCity != null && trimmedCity.isNotEmpty) {
              final cityPattern = '%${trimmedCity.toLowerCase()}%';
              expression = expression & t.city.lower().like(cityPattern);
            }

            return expression;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Customer?> getCustomerById(String id) => (select(customers)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<int> insertCustomer(CustomersCompanion customer) =>
      into(customers).insert(customer);

  Future<bool> updateCustomer(Customer customer) =>
      update(customers).replace(customer);

  Future<int> softDeleteCustomer(String id) => (update(customers)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(CustomersCompanion(deletedAt: Value(DateTime.now())));
}
