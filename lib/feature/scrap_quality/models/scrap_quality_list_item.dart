import 'package:equatable/equatable.dart';

final class ScrapQualityListItem extends Equatable {
  const ScrapQualityListItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.quality,
    required this.quantity,
    required this.unit,
    required this.recordDate,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String quality;
  final double quantity;
  final String unit;
  final DateTime recordDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        quality,
        quantity,
        unit,
        recordDate,
        note,
        createdAt,
        updatedAt,
      ];
}
