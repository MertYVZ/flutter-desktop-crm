import 'package:drift/drift.dart';

import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_list_item.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/due_records_table.dart';

part 'due_record_dao.g.dart';

@DriftAccessor(tables: [DueRecords, Customers])
class DueRecordDao extends DatabaseAccessor<AppDatabase>
    with _$DueRecordDaoMixin {
  DueRecordDao(super.db);

  Future<List<DueRecordListItem>> getDueRecords() => searchDueRecords();

  Future<List<DueRecordListItem>> searchDueRecords({
    String? searchQuery,
    DueRecordDisplayStatusFilter? statusFilter,
    CurrencyType? currencyFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final startOfToday = _startOfDay(DateTime.now());
    final query = select(dueRecords).join([
      innerJoin(customers, customers.id.equalsExp(dueRecords.customerId)),
    ]);

    query.where(dueRecords.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      query.where(
        customers.name.lower().like(pattern) |
            dueRecords.invoiceNo.lower().like(pattern),
      );
    }

    if (statusFilter != null) {
      switch (statusFilter) {
        case DueRecordDisplayStatusFilter.pending:
          query.where(
            dueRecords.status.equals(DueRecordStatus.pending.value) &
                dueRecords.dueDate.isBiggerOrEqualValue(startOfToday),
          );
        case DueRecordDisplayStatusFilter.overdue:
          query.where(
            dueRecords.status.equals(DueRecordStatus.pending.value) &
                dueRecords.dueDate.isSmallerThanValue(startOfToday),
          );
        case DueRecordDisplayStatusFilter.paid:
          query.where(dueRecords.status.equals(DueRecordStatus.paid.value));
      }
    }

    if (currencyFilter != null) {
      query.where(dueRecords.currency.equals(currencyFilter.value));
    }

    if (startDate != null) {
      query.where(
        dueRecords.dueDate.isBiggerOrEqualValue(_startOfDay(startDate)),
      );
    }

    if (endDate != null) {
      query.where(
        dueRecords.dueDate.isSmallerOrEqualValue(_endOfDay(endDate)),
      );
    }

    query.orderBy([OrderingTerm.asc(dueRecords.dueDate)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<DueRecord?> getDueRecordById(String id) => (select(dueRecords)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<int> insertDueRecord(DueRecordsCompanion record) =>
      into(dueRecords).insert(record);

  Future<bool> updateDueRecord(DueRecord record) =>
      update(dueRecords).replace(record);

  Future<int> softDeleteDueRecord(String id) => (update(dueRecords)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(DueRecordsCompanion(deletedAt: Value(DateTime.now())));

  DueRecordListItem _mapRowToListItem(TypedResult row) {
    final record = row.readTable(dueRecords);
    final customer = row.readTable(customers);

    return DueRecordListItem(
      id: record.id,
      customerId: record.customerId,
      customerName: customer.name,
      invoiceNo: record.invoiceNo,
      amountMinor: record.amountMinor,
      currency: record.currency,
      dueDate: record.dueDate,
      status: record.status,
      paidAt: record.paidAt,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
