import 'package:equatable/equatable.dart';

final class ExportRecordListItem extends Equatable {
  const ExportRecordListItem({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.productName,
    required this.quantityTon,
    required this.totalPriceMinor,
    required this.currency,
    required this.shipmentDate,
    required this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String customerId;
  final String customerName;
  final String productName;
  final double quantityTon;
  final int totalPriceMinor;
  final String currency;
  final DateTime? shipmentDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        customerId,
        customerName,
        productName,
        quantityTon,
        totalPriceMinor,
        currency,
        shipmentDate,
        deliveryDate,
        createdAt,
        updatedAt,
      ];
}
