enum AppRoutes {
  splash,
  login,
  changePassword,
  dashboard,
  settings,
  customers,
  customersNew,
  customersDetail,
  customersEdit,
  dueTracking,
  dueTrackingNew,
  dueTrackingEdit,
  meetings,
  meetingsNew,
  meetingsDetail,
  meetingsEdit,
  scrapQuality,
  scrapQualityNew,
  scrapQualityDetail,
  scrapQualityEdit,
  notes,
  notesNew,
  notesDetail,
  notesEdit,
  priceOffers,
  priceOffersNew,
  priceOffersDetail,
  priceOffersEdit,
  reminders,
  remindersNew,
  remindersEdit,
  priceList,
  priceListNew,
  priceListDetail,
  priceListEdit,
}

extension AppRoutesExtension on AppRoutes {
  String _path() {
    switch (this) {
      case AppRoutes.splash:
        return '/';
      case AppRoutes.login:
        return '/login';
      case AppRoutes.changePassword:
        return '/change-password';
      case AppRoutes.dashboard:
        return '/dashboard';
      case AppRoutes.settings:
        return '/settings';
      case AppRoutes.customers:
        return '/customers';
      case AppRoutes.customersNew:
        return '/customers/new';
      case AppRoutes.customersDetail:
        return '/customers/:id';
      case AppRoutes.customersEdit:
        return '/customers/:id/edit';
      case AppRoutes.dueTracking:
        return '/due-tracking';
      case AppRoutes.dueTrackingNew:
        return '/due-tracking/new';
      case AppRoutes.dueTrackingEdit:
        return '/due-tracking/:id/edit';
      case AppRoutes.meetings:
        return '/meetings';
      case AppRoutes.meetingsNew:
        return '/meetings/new';
      case AppRoutes.meetingsDetail:
        return '/meetings/:id';
      case AppRoutes.meetingsEdit:
        return '/meetings/:id/edit';
      case AppRoutes.scrapQuality:
        return '/scrap-quality';
      case AppRoutes.scrapQualityNew:
        return '/scrap-quality/new';
      case AppRoutes.scrapQualityDetail:
        return '/scrap-quality/:id';
      case AppRoutes.scrapQualityEdit:
        return '/scrap-quality/:id/edit';
      case AppRoutes.notes:
        return '/notes';
      case AppRoutes.notesNew:
        return '/notes/new';
      case AppRoutes.notesDetail:
        return '/notes/:id';
      case AppRoutes.notesEdit:
        return '/notes/:id/edit';
      case AppRoutes.priceOffers:
        return '/price-offers';
      case AppRoutes.priceOffersNew:
        return '/price-offers/new';
      case AppRoutes.priceOffersDetail:
        return '/price-offers/:id';
      case AppRoutes.priceOffersEdit:
        return '/price-offers/:id/edit';
      case AppRoutes.reminders:
        return '/reminders';
      case AppRoutes.remindersNew:
        return '/reminders/new';
      case AppRoutes.remindersEdit:
        return '/reminders/:id/edit';
      case AppRoutes.priceList:
        return '/price-list';
      case AppRoutes.priceListNew:
        return '/price-list/new';
      case AppRoutes.priceListDetail:
        return '/price-list/:id';
      case AppRoutes.priceListEdit:
        return '/price-list/:id/edit';
    }
  }

  String get value => _path();

  String pathForId(String id) {
    switch (this) {
      case AppRoutes.customersDetail:
        return '/customers/$id';
      case AppRoutes.customersEdit:
        return '/customers/$id/edit';
      case AppRoutes.dueTrackingEdit:
        return '/due-tracking/$id/edit';
      case AppRoutes.meetingsDetail:
        return '/meetings/$id';
      case AppRoutes.meetingsEdit:
        return '/meetings/$id/edit';
      case AppRoutes.scrapQualityEdit:
        return '/scrap-quality/$id/edit';
      case AppRoutes.scrapQualityDetail:
        return '/scrap-quality/$id';
      case AppRoutes.notesDetail:
        return '/notes/$id';
      case AppRoutes.notesEdit:
        return '/notes/$id/edit';
      case AppRoutes.priceOffersDetail:
        return '/price-offers/$id';
      case AppRoutes.priceOffersEdit:
        return '/price-offers/$id/edit';
      case AppRoutes.remindersEdit:
        return '/reminders/$id/edit';
      case AppRoutes.priceListDetail:
        return '/price-list/$id';
      case AppRoutes.priceListEdit:
        return '/price-list/$id/edit';
      case AppRoutes.splash:
      case AppRoutes.login:
      case AppRoutes.changePassword:
      case AppRoutes.dashboard:
      case AppRoutes.settings:
      case AppRoutes.customers:
      case AppRoutes.customersNew:
      case AppRoutes.dueTracking:
      case AppRoutes.dueTrackingNew:
      case AppRoutes.meetings:
      case AppRoutes.meetingsNew:
      case AppRoutes.scrapQuality:
      case AppRoutes.scrapQualityNew:
      case AppRoutes.scrapQualityDetail:
      case AppRoutes.notes:
      case AppRoutes.notesNew:
      case AppRoutes.priceOffers:
      case AppRoutes.priceOffersNew:
      case AppRoutes.reminders:
      case AppRoutes.remindersNew:
      case AppRoutes.priceList:
      case AppRoutes.priceListNew:
        return value;
    }
  }
}
