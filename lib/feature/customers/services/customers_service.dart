import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class CustomersService {
  CustomersService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<Customer>> getCustomers() =>
      _databaseService.customers.getActiveCustomers();

  Future<List<Customer>> searchCustomers({
    String? searchQuery,
    CustomerType? typeFilter,
    CustomerStatus? statusFilter,
    String? cityFilter,
  }) {
    return _databaseService.customers.searchCustomers(
      searchQuery: searchQuery,
      typeFilter: typeFilter?.value,
      statusFilter: statusFilter?.value,
      cityFilter: cityFilter,
    );
  }

  Future<Customer?> getCustomerById(String id) =>
      _databaseService.customers.getCustomerById(id);

  Future<String> createCustomer({
    required String name,
    required CustomerType type,
    required String city,
    required String country,
    String? phone,
    String? email,
    String? address,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.customers.insertCustomer(
      CustomersCompanion.insert(
        id: id,
        name: name.trim(),
        type: type.value,
        phone: Value(_nullableTrim(phone)),
        email: Value(_nullableTrim(email)),
        city: Value(city.trim()),
        country: Value(country.trim()),
        address: Value(_nullableTrim(address)),
        status: CustomerStatus.active.value,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    required CustomerType type,
    required String city,
    required String country,
    required CustomerStatus status,
    String? phone,
    String? email,
    String? address,
  }) async {
    final existing = await getCustomerById(id);
    if (existing == null) {
      throw StateError('Customer not found');
    }

    final updated = existing.copyWith(
      name: name.trim(),
      type: type.value,
      phone: Value(_nullableTrim(phone)),
      email: Value(_nullableTrim(email)),
      city: Value(city.trim()),
      country: Value(country.trim()),
      address: Value(_nullableTrim(address)),
      status: status.value,
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.customers.updateCustomer(updated);
    if (!success) {
      throw StateError('Customer update failed');
    }
  }

  Future<void> deleteCustomer(String id) async {
    final affectedRows =
        await _databaseService.customers.softDeleteCustomer(id);
    if (affectedRows == 0) {
      throw StateError('Customer not found');
    }
  }

  String? _nullableTrim(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
