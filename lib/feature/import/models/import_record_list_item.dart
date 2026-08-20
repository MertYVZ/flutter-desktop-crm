import 'package:equatable/equatable.dart';

final class ImportRecordListItem extends Equatable {
  const ImportRecordListItem({
    required this.id,
    required this.title,
    required this.supplierName,
    required this.products,
    required this.totalAmountMinor,
    required this.currency,
    required this.shipmentDate,
    required this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String supplierName;
  final String products;
  final int totalAmountMinor;
  final String currency;
  final DateTime? shipmentDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        supplierName,
        products,
        totalAmountMinor,
        currency,
        shipmentDate,
        deliveryDate,
        createdAt,
        updatedAt,
      ];
}
