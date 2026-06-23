enum PriceListStatus {
  active,
  archived,
  draft,
}

extension PriceListStatusX on PriceListStatus {
  String get value {
    switch (this) {
      case PriceListStatus.active:
        return 'active';
      case PriceListStatus.archived:
        return 'archived';
      case PriceListStatus.draft:
        return 'draft';
    }
  }

  String get label {
    switch (this) {
      case PriceListStatus.active:
        return 'Aktif';
      case PriceListStatus.archived:
        return 'Arşiv';
      case PriceListStatus.draft:
        return 'Taslak';
    }
  }

  static PriceListStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final status in PriceListStatus.values) {
      if (status.value == value) {
        return status;
      }
    }

    return null;
  }
}
