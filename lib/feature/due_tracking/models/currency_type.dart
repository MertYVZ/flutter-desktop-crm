enum CurrencyType {
  try_,
  usd,
  eur,
}

extension CurrencyTypeX on CurrencyType {
  String get value {
    switch (this) {
      case CurrencyType.try_:
        return 'TRY';
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.eur:
        return 'EUR';
    }
  }

  String get label => value;

  static CurrencyType? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final currency in CurrencyType.values) {
      if (currency.value == value) {
        return currency;
      }
    }

    return null;
  }
}
