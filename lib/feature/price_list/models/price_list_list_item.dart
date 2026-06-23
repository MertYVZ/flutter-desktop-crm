import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:equatable/equatable.dart';

final class PriceListListItem extends Equatable {
  const PriceListListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.effectiveDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.archivedAt,
    required this.itemCount,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime effectiveDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final int itemCount;

  PriceListStatus? get priceListStatus => PriceListStatusX.fromValue(status);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        effectiveDate,
        status,
        createdAt,
        updatedAt,
        archivedAt,
        itemCount,
      ];
}
