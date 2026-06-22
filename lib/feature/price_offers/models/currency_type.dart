enum PriceOfferCurrencyType {
  try_,
  usd,
  eur,
}

extension PriceOfferCurrencyTypeX on PriceOfferCurrencyType {
  String get value {
    switch (this) {
      case PriceOfferCurrencyType.try_:
        return 'TRY';
      case PriceOfferCurrencyType.usd:
        return 'USD';
      case PriceOfferCurrencyType.eur:
        return 'EUR';
    }
  }

  String get label {
    switch (this) {
      case PriceOfferCurrencyType.try_:
        return 'TRY';
      case PriceOfferCurrencyType.usd:
        return 'USD';
      case PriceOfferCurrencyType.eur:
        return 'EURO';
    }
  }

  static PriceOfferCurrencyType? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final currency in PriceOfferCurrencyType.values) {
      if (currency.value == value) {
        return currency;
      }
    }

    return null;
  }
}
