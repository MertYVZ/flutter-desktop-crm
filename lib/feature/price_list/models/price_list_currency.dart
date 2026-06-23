enum PriceListCurrency {
  try_,
  usd,
  eur,
}

extension PriceListCurrencyX on PriceListCurrency {
  String get value {
    switch (this) {
      case PriceListCurrency.try_:
        return 'TRY';
      case PriceListCurrency.usd:
        return 'USD';
      case PriceListCurrency.eur:
        return 'EUR';
    }
  }

  String get label {
    switch (this) {
      case PriceListCurrency.try_:
        return 'TRY';
      case PriceListCurrency.usd:
        return 'USD';
      case PriceListCurrency.eur:
        return 'EURO';
    }
  }

  static PriceListCurrency? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final currency in PriceListCurrency.values) {
      if (currency.value == value) {
        return currency;
      }
    }

    return null;
  }
}
