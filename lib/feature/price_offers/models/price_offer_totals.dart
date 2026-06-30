import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';

/// Tek bir para birimi için brüt toplam, uygulanan indirim ve net toplam.
final class PriceOfferCurrencyTotal {
  const PriceOfferCurrencyTotal({
    required this.currency,
    required this.grossMinor,
    required this.discountMinor,
  });

  final PriceOfferCurrencyType currency;
  final int grossMinor;
  final int discountMinor;

  int get netMinor => grossMinor - discountMinor;

  bool get hasDiscount => discountMinor > 0;
}

/// Ürün satırlarından ve indirimden para birimi bazlı toplamları hesaplar.
final class PriceOfferTotalsCalculator {
  const PriceOfferTotalsCalculator._();

  /// Ürün satırlarından para birimi bazlı brüt toplamları çıkarır.
  static Map<PriceOfferCurrencyType, int> grossFromItems(
    List<PriceOfferItemData> items,
  ) {
    final totals = <PriceOfferCurrencyType, double>{};

    for (final item in items) {
      final currency =
          item.currencyType ?? PriceOfferCurrencyTypeX.fromValue(item.currency);
      if (currency == null) {
        continue;
      }

      totals[currency] = (totals[currency] ?? 0) + item.rowTotalMinor;
    }

    return {
      for (final entry in totals.entries) entry.key: entry.value.round(),
    };
  }

  /// Brüt toplam haritasına indirimi uygulayıp, para birimi enum sırasına göre
  /// sıralı toplam listesini döndürür.
  static List<PriceOfferCurrencyTotal> apply({
    required Map<PriceOfferCurrencyType, int> grossByCurrency,
    required PriceOfferDiscount discount,
  }) {
    final result = <PriceOfferCurrencyTotal>[];

    for (final currency in PriceOfferCurrencyType.values) {
      if (!grossByCurrency.containsKey(currency)) {
        continue;
      }

      final grossMinor = grossByCurrency[currency]!;
      final discountMinor = _discountForCurrency(
        currency: currency,
        grossMinor: grossMinor,
        discount: discount,
      );

      result.add(
        PriceOfferCurrencyTotal(
          currency: currency,
          grossMinor: grossMinor,
          discountMinor: discountMinor,
        ),
      );
    }

    return result;
  }

  static List<PriceOfferCurrencyTotal> fromItems({
    required List<PriceOfferItemData> items,
    required PriceOfferDiscount discount,
  }) {
    return apply(
      grossByCurrency: grossFromItems(items),
      discount: discount,
    );
  }

  static int _discountForCurrency({
    required PriceOfferCurrencyType currency,
    required int grossMinor,
    required PriceOfferDiscount discount,
  }) {
    if (!discount.isActive || grossMinor <= 0) {
      return 0;
    }

    switch (discount.type) {
      case PriceOfferDiscountType.none:
        return 0;
      case PriceOfferDiscountType.percentage:
        final percentage = discount.percentage;
        if (percentage == null || percentage <= 0) {
          return 0;
        }
        final raw = (grossMinor * percentage / 100).round();
        return raw.clamp(0, grossMinor);
      case PriceOfferDiscountType.fixed:
        if (discount.currency != currency) {
          return 0;
        }
        final amount = discount.amountMinor;
        if (amount == null || amount <= 0) {
          return 0;
        }
        return amount.clamp(0, grossMinor);
    }
  }
}
