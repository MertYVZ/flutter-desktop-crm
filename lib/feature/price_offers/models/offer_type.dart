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
