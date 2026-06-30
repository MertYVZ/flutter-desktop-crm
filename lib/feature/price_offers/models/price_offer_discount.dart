import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount_type.dart';
import 'package:equatable/equatable.dart';

/// Bir fiyat teklifine uygulanan genel indirim.
///
/// İki tip indirim desteklenir:
/// - [PriceOfferDiscountType.percentage]: [percentage] kadar yüzdelik indirim
///   tüm para birimi alt toplamlarına uygulanır.
/// - [PriceOfferDiscountType.fixed]: [amountMinor] kadar tutar yalnızca
///   [currency] para biriminin toplamından düşülür.
final class PriceOfferDiscount extends Equatable {
  const PriceOfferDiscount({
    required this.type,
    this.percentage,
    this.amountMinor,
    this.currency,
  });

  const PriceOfferDiscount.none() : this(type: PriceOfferDiscountType.none);

  factory PriceOfferDiscount.fromStored({
    required String? type,
    required double? percentage,
    required int? amountMinor,
    required String? currency,
  }) {
    final discountType = PriceOfferDiscountTypeX.fromValue(type);

    switch (discountType) {
      case PriceOfferDiscountType.none:
        return const PriceOfferDiscount.none();
      case PriceOfferDiscountType.percentage:
        return PriceOfferDiscount(
          type: discountType,
          percentage: percentage,
        );
      case PriceOfferDiscountType.fixed:
        return PriceOfferDiscount(
          type: discountType,
          amountMinor: amountMinor,
          currency: PriceOfferCurrencyTypeX.fromValue(currency),
        );
    }
  }

  final PriceOfferDiscountType type;
  final double? percentage;
  final int? amountMinor;
  final PriceOfferCurrencyType? currency;

  bool get isActive {
    switch (type) {
      case PriceOfferDiscountType.none:
        return false;
      case PriceOfferDiscountType.percentage:
        return percentage != null && percentage! > 0;
      case PriceOfferDiscountType.fixed:
        return amountMinor != null && amountMinor! > 0 && currency != null;
    }
  }

  @override
  List<Object?> get props => [type, percentage, amountMinor, currency];
}
