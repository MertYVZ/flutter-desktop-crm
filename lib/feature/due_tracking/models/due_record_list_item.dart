import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:equatable/equatable.dart';

final class DueRecordListItem extends Equatable {
  const DueRecordListItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.invoiceNo,
    required this.amountMinor,
    required this.currency,
    required this.dueDate,
    required this.status,
    required this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String invoiceNo;
  final int amountMinor;
  final String currency;
  final DateTime dueDate;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CurrencyType? get currencyType => CurrencyTypeX.fromValue(currency);

  DueRecordStatus? get recordStatus => DueRecordStatusX.fromValue(status);

  DueRecordDisplayStatus get displayStatus =>
      DueRecordDisplayStatusX.fromRecord(status: status, dueDate: dueDate);

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        invoiceNo,
        amountMinor,
        currency,
        dueDate,
        status,
        paidAt,
        createdAt,
        updatedAt,
      ];
}
