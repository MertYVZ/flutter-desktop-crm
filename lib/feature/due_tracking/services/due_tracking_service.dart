import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_list_item.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class DueTrackingService {
  DueTrackingService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<DueRecordListItem>> getDueRecords() =>
      _databaseService.dueRecords.getDueRecords();

  Future<List<DueRecordListItem>> searchDueRecords({
    String? searchQuery,
    DueRecordDisplayStatusFilter? statusFilter,
    CurrencyType? currencyFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _databaseService.dueRecords.searchDueRecords(
      searchQuery: searchQuery,
      statusFilter: statusFilter,
      currencyFilter: currencyFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<DueRecord?> getDueRecordById(String id) =>
      _databaseService.dueRecords.getDueRecordById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createDueRecord({
    required String customerId,
    required String invoiceNo,
    required int amountMinor,
    required CurrencyType currency,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.dueRecords.insertDueRecord(
      DueRecordsCompanion.insert(
        id: id,
        customerId: customerId,
        invoiceNo: invoiceNo.trim(),
        amountMinor: amountMinor,
        currency: currency.value,
        dueDate: dueDate,
        status: DueRecordStatus.pending.value,
        paidAt: const Value.absent(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateDueRecord({
    required String id,
    required String customerId,
    required String invoiceNo,
    required int amountMinor,
    required CurrencyType currency,
    required DateTime dueDate,
    required DueRecordStatus status,
  }) async {
    final existing = await getDueRecordById(id);
    if (existing == null) {
      throw StateError('Due record not found');
    }

    final now = DateTime.now();
    final paidAt = status == DueRecordStatus.paid ? now : null;

    final updated = existing.copyWith(
      customerId: customerId,
      invoiceNo: invoiceNo.trim(),
      amountMinor: amountMinor,
      currency: currency.value,
      dueDate: dueDate,
      status: status.value,
      paidAt: Value(paidAt),
      updatedAt: now,
    );

    final success = await _databaseService.dueRecords.updateDueRecord(updated);
    if (!success) {
      throw StateError('Due record update failed');
    }
  }

  Future<void> deleteDueRecord(String id) async {
    final affectedRows =
        await _databaseService.dueRecords.softDeleteDueRecord(id);
    if (affectedRows == 0) {
      throw StateError('Due record not found');
    }
  }
}
