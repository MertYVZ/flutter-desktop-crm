import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:equatable/equatable.dart';

final class PriceListItemModel extends Equatable {
  const PriceListItemModel({
    required this.id,
    required this.priceListId,
    required this.productName,
    required this.currency,
    required this.minPriceMinor,
    required this.maxPriceMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String priceListId;
  final String productName;
  final String currency;
  final int minPriceMinor;
  final int maxPriceMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

  PriceListCurrency? get currencyType =>
      PriceListCurrencyX.fromValue(currency);

  @override
  List<Object?> get props => [
        id,
        priceListId,
        productName,
        currency,
        minPriceMinor,
        maxPriceMinor,
        createdAt,
        updatedAt,
      ];
}
