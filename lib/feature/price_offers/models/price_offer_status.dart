enum PriceOfferStatus {
  draft,
  sent,
  approved,
  rejected,
  cancelled,
}

extension PriceOfferStatusX on PriceOfferStatus {
  String get value {
    switch (this) {
      case PriceOfferStatus.draft:
        return 'draft';
      case PriceOfferStatus.sent:
        return 'sent';
      case PriceOfferStatus.approved:
        return 'approved';
      case PriceOfferStatus.rejected:
        return 'rejected';
      case PriceOfferStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case PriceOfferStatus.draft:
        return 'Taslak';
      case PriceOfferStatus.sent:
        return 'Gönderildi';
      case PriceOfferStatus.approved:
        return 'Onaylandı';
      case PriceOfferStatus.rejected:
        return 'Reddedildi';
      case PriceOfferStatus.cancelled:
        return 'İptal';
    }
  }

  static PriceOfferStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final status in PriceOfferStatus.values) {
      if (status.value == value) {
        return status;
      }
    }

    return null;
  }
}
