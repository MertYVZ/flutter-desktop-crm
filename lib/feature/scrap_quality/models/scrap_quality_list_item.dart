import 'package:Ok/feature/scrap_quality/models/scrap_lost_reason.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:equatable/equatable.dart';

final class ScrapQualityListItem extends Equatable {
  const ScrapQualityListItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerNameSnapshot,
    required this.quality,
    required this.quantity,
    required this.unit,
    required this.quantityKg,
    required this.city,
    required this.salesStatus,
    required this.offerPrice,
    required this.targetPrice,
    required this.lostReason,
    required this.followUpDate,
    required this.recordDate,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String? customerNameSnapshot;
  final String quality;
  final double quantity;
  final String unit;
  final double quantityKg;
  final String? city;
  final String salesStatus;
  final double? offerPrice;
  final double? targetPrice;
  final String? lostReason;
  final DateTime? followUpDate;
  final DateTime recordDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get scrapType => quality;

  ScrapSalesStatus? get salesStatusEnum =>
      ScrapSalesStatusX.fromValue(salesStatus);

  ScrapLostReason? get lostReasonEnum => ScrapLostReasonX.fromValue(lostReason);

  String? get lostReasonLabel {
    final enumValue = lostReasonEnum;
    if (enumValue != null) {
      return enumValue.label;
    }
    return lostReason;
  }

  String get displayCustomerName =>
      customerName.isNotEmpty ? customerName : (customerNameSnapshot ?? '');

  String get notePreview {
    final value = note?.trim();
    if (value == null || value.isEmpty) {
      return '—';
    }
    if (value.length <= 40) {
      return value;
    }
    return '${value.substring(0, 40)}…';
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerNameSnapshot,
        quality,
        quantity,
        unit,
        quantityKg,
        city,
        salesStatus,
        offerPrice,
        targetPrice,
        lostReason,
        followUpDate,
        recordDate,
        note,
        createdAt,
        updatedAt,
      ];
}
