import 'package:Ok/feature/price_offers/models/price_offer_unit_type.dart';

enum OfferType {
  okTeknik,
  dengTools,
  vizviz,
  general,
}

extension OfferTypeX on OfferType {
  String get value {
    switch (this) {
      case OfferType.okTeknik:
        return 'okTeknik';
      case OfferType.dengTools:
        return 'dengTools';
      case OfferType.vizviz:
        return 'vizviz';
      case OfferType.general:
        return 'general';
    }
  }

  String get label {
    switch (this) {
      case OfferType.okTeknik:
        return 'Ok Teknik';
      case OfferType.dengTools:
        return 'Deng Tools';
      case OfferType.vizviz:
        return 'VızVız';
      case OfferType.general:
        return 'Genel';
    }
  }

  bool get requiresCustomer => this != OfferType.general;

  PriceOfferUnitType? get defaultUnitType {
    switch (this) {
      case OfferType.okTeknik:
        return PriceOfferUnitType.kg;
      case OfferType.dengTools:
      case OfferType.vizviz:
        return PriceOfferUnitType.adet;
      case OfferType.general:
        return null;
    }
  }

  static OfferType? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final type in OfferType.values) {
      if (type.value == value) {
        return type;
      }
    }

    return null;
  }
}
