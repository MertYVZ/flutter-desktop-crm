enum MeetingSubject {
  reminder,
  scrapOffer,
  scrapPurchase,
  scrapCargo,
  productOffer,
  productSale,
  productReminder,
  sample,
  sampleFollowUp,
  communication,
  other,
}

extension MeetingSubjectX on MeetingSubject {
  String get value {
    switch (this) {
      case MeetingSubject.reminder:
        return 'reminder';
      case MeetingSubject.scrapOffer:
        return 'scrapOffer';
      case MeetingSubject.scrapPurchase:
        return 'scrapPurchase';
      case MeetingSubject.scrapCargo:
        return 'scrapCargo';
      case MeetingSubject.productOffer:
        return 'productOffer';
      case MeetingSubject.productSale:
        return 'productSale';
      case MeetingSubject.productReminder:
        return 'productReminder';
      case MeetingSubject.sample:
        return 'sample';
      case MeetingSubject.sampleFollowUp:
        return 'sampleFollowUp';
      case MeetingSubject.communication:
        return 'communication';
      case MeetingSubject.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case MeetingSubject.reminder:
        return 'Hatırlatma';
      case MeetingSubject.scrapOffer:
        return 'Hurda Teklif';
      case MeetingSubject.scrapPurchase:
        return 'Hurda Alım';
      case MeetingSubject.scrapCargo:
        return 'Hurda Kargo';
      case MeetingSubject.productOffer:
        return 'Ürün Teklif';
      case MeetingSubject.productSale:
        return 'Ürün Satış';
      case MeetingSubject.productReminder:
        return 'Ürün Hatırlatma';
      case MeetingSubject.sample:
        return 'Numune';
      case MeetingSubject.sampleFollowUp:
        return 'Numune Takip';
      case MeetingSubject.communication:
        return 'İletişim';
      case MeetingSubject.other:
        return 'Diğer';
    }
  }

  static MeetingSubject? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final subject in MeetingSubject.values) {
      if (subject.value == value) {
        return subject;
      }
    }

    return null;
  }
}
