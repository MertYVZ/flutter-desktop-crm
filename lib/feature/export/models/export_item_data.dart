import 'package:Ok/feature/price_offers/models/price_offer_unit_type.dart';
import 'package:equatable/equatable.dart';

final class ExportItemData extends Equatable {
  const ExportItemData({
    required this.id,
    required this.productName,
    required this.unitType,
    required this.quantity,
    required this.priceMinor,
    required this.sortOrder,
    this.wasteUnitType,
    this.wasteQuantity = 0,
  });

  final String id;
  final String productName;
  final String unitType;
  final double quantity;
  final String? wasteUnitType;
  final double wasteQuantity;
  final int priceMinor;
  final int sortOrder;

  PriceOfferUnitType? get unit => PriceOfferUnitType.fromLabel(unitType);

  PriceOfferUnitType? get wasteUnit =>
      PriceOfferUnitType.fromLabel(wasteUnitType);

  int get sentTotalMinor => (quantity * priceMinor).round();

  int get wasteTotalMinor {
    final wasteInSentUnits = convertQuantity(
      quantity: wasteQuantity,
      from: wasteUnit ?? unit,
      to: unit,
    );
    if (wasteInSentUnits == null) {
      return 0;
    }

    return (wasteInSentUnits * priceMinor).round();
  }

  @override
  List<Object?> get props => [
        id,
        productName,
        unitType,
        quantity,
        wasteUnitType,
        wasteQuantity,
        priceMinor,
        sortOrder,
      ];
}

double? convertQuantity({
  required double quantity,
  required PriceOfferUnitType? from,
  required PriceOfferUnitType? to,
}) {
  if (from == null || to == null) {
    return quantity;
  }

  if (from == to) {
    return quantity;
  }

  if (from == PriceOfferUnitType.ton && to == PriceOfferUnitType.kg) {
    return quantity * 1000;
  }

  if (from == PriceOfferUnitType.kg && to == PriceOfferUnitType.ton) {
    return quantity / 1000;
  }

  return quantity;
}

double snapshotQuantityTon(Iterable<ExportItemData> items) {
  var tons = 0.0;
  for (final item in items) {
    final converted = convertQuantity(
      quantity: item.quantity,
      from: item.unit,
      to: PriceOfferUnitType.ton,
    );
    if (converted != null &&
        (item.unit == PriceOfferUnitType.ton ||
            item.unit == PriceOfferUnitType.kg)) {
      tons += converted;
    }
  }
  return tons;
}

double snapshotWasteKg(Iterable<ExportItemData> items) {
  var kilograms = 0.0;
  for (final item in items) {
    if (item.wasteQuantity <= 0) {
      continue;
    }

    final converted = convertQuantity(
      quantity: item.wasteQuantity,
      from: item.wasteUnit ?? item.unit,
      to: PriceOfferUnitType.kg,
    );
    if (converted != null &&
        (item.wasteUnit == PriceOfferUnitType.kg ||
            item.wasteUnit == PriceOfferUnitType.ton ||
            (item.wasteUnit == null &&
                (item.unit == PriceOfferUnitType.kg ||
                    item.unit == PriceOfferUnitType.ton)))) {
      kilograms += converted;
    }
  }
  return kilograms;
}
