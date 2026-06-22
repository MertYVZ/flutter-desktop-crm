enum DashboardCalendarEventType {
  meeting,
  priceOffer,
  reminder,
}

extension DashboardCalendarEventTypeX on DashboardCalendarEventType {
  String get label {
    switch (this) {
      case DashboardCalendarEventType.meeting:
        return 'Görüşme';
      case DashboardCalendarEventType.priceOffer:
        return 'Teklif';
      case DashboardCalendarEventType.reminder:
        return 'Hatırlatma';
    }
  }

  String get pluralLabel {
    switch (this) {
      case DashboardCalendarEventType.meeting:
        return 'Görüşme';
      case DashboardCalendarEventType.priceOffer:
        return 'Teklif';
      case DashboardCalendarEventType.reminder:
        return 'Hatırlatma';
    }
  }

  String get sourceType {
    switch (this) {
      case DashboardCalendarEventType.meeting:
        return 'meeting';
      case DashboardCalendarEventType.priceOffer:
        return 'price_offer';
      case DashboardCalendarEventType.reminder:
        return 'reminder';
    }
  }
}
