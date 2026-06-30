enum PriceOfferDiscountType {
  none,
  percentage,
  fixed,
}

extension PriceOfferDiscountTypeX on PriceOfferDiscountType {
  String get value {
    switch (this) {
      case PriceOfferDiscountType.none:
        return 'none';
      case PriceOfferDiscountType.percentage:
        return 'percentage';
      case PriceOfferDiscountType.fixed:
        return 'fixed';
    }
  }

  String get label {
    switch (this) {
      case PriceOfferDiscountType.none:
        return 'İndirim Yok';
      case PriceOfferDiscountType.percentage:
        return 'Yüzde (%)';
      case PriceOfferDiscountType.fixed:
        return 'Tutar';
    }
  }

  bool get isActive => this != PriceOfferDiscountType.none;

  static PriceOfferDiscountType fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return PriceOfferDiscountType.none;
    }

    for (final type in PriceOfferDiscountType.values) {
      if (type.value == value) {
        return type;
      }
    }

    return PriceOfferDiscountType.none;
  }
}
