import 'package:Ok/product/navigation/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ShellMenuItem {
  dashboard,
  customers,
  priceQuotes,
  reminders,
  dueDateTracking,
  meetings,
  scrapQuality,
  notebook,
  priceList,
  settings,
}

extension ShellMenuItemX on ShellMenuItem {
  static List<ShellMenuItem> get mainItems => ShellMenuItem.values
      .where((item) => item != ShellMenuItem.settings)
      .toList();

  String get title {
    switch (this) {
      case ShellMenuItem.dashboard:
        return 'Ana Sayfa';
      case ShellMenuItem.customers:
        return 'Müşteriler';
      case ShellMenuItem.priceQuotes:
        return 'Fiyat Teklifleri';
      case ShellMenuItem.reminders:
        return 'Hatırlatmalar';
      case ShellMenuItem.dueDateTracking:
        return 'Vade Takip';
      case ShellMenuItem.meetings:
        return 'Görüşmeler';
      case ShellMenuItem.scrapQuality:
        return 'Hurda Kalite';
      case ShellMenuItem.notebook:
        return 'Not Defteri';
      case ShellMenuItem.priceList:
        return 'Fiyat Listesi';
      case ShellMenuItem.settings:
        return 'Ayarlar';
    }
  }

  IconData get icon {
    switch (this) {
      case ShellMenuItem.dashboard:
        return Icons.dashboard_outlined;
      case ShellMenuItem.customers:
        return Icons.people_outline_rounded;
      case ShellMenuItem.priceQuotes:
        return Icons.request_quote_outlined;
      case ShellMenuItem.reminders:
        return Icons.notifications_outlined;
      case ShellMenuItem.dueDateTracking:
        return Icons.calendar_month_outlined;
      case ShellMenuItem.meetings:
        return Icons.forum_outlined;
      case ShellMenuItem.scrapQuality:
        return Icons.fact_check_outlined;
      case ShellMenuItem.notebook:
        return Icons.book_outlined;
      case ShellMenuItem.priceList:
        return Icons.list_alt_outlined;
      case ShellMenuItem.settings:
        return Icons.settings_outlined;
    }
  }
}

final class ShellController extends GetxController {
  final Rx<ShellMenuItem> selectedMenu = ShellMenuItem.dashboard.obs;
  final RxBool isMobileDrawerOpen = false.obs;
  final RxString currentRoute = ''.obs;

  static const mobileBreakpoint = 1024.0;

  @override
  void onInit() {
    super.onInit();
    currentRoute.value = Get.currentRoute;
    _syncMenuFromRoute();
  }

  void updateCurrentRoute(String route) {
    currentRoute.value = route;
    _syncMenuFromRoute();
  }

  void selectMenu(ShellMenuItem item) {
    selectedMenu.value = item;
    isMobileDrawerOpen.value = false;

    final targetRoute = _routeForMenu(item);
    if (Get.currentRoute != targetRoute) {
      Get.offNamed<void>(targetRoute);
    }
  }

  void toggleMobileDrawer() {
    isMobileDrawerOpen.toggle();
  }

  void closeMobileDrawer() {
    isMobileDrawerOpen.value = false;
  }

  void _syncMenuFromRoute() {
    final route = currentRoute.value.isEmpty ? Get.currentRoute : currentRoute.value;
    if (route == AppRoutes.dashboard.value) {
      selectedMenu.value = ShellMenuItem.dashboard;
      return;
    }

    if (route == AppRoutes.settings.value) {
      selectedMenu.value = ShellMenuItem.settings;
      return;
    }

    if (route.startsWith('/customers')) {
      selectedMenu.value = ShellMenuItem.customers;
      return;
    }

    if (route.startsWith('/due-tracking')) {
      selectedMenu.value = ShellMenuItem.dueDateTracking;
      return;
    }

    if (route.startsWith('/meetings')) {
      selectedMenu.value = ShellMenuItem.meetings;
      return;
    }

    if (route.startsWith('/scrap-quality')) {
      selectedMenu.value = ShellMenuItem.scrapQuality;
      return;
    }

    if (route.startsWith('/notes')) {
      selectedMenu.value = ShellMenuItem.notebook;
      return;
    }

    if (route.startsWith('/price-offers')) {
      selectedMenu.value = ShellMenuItem.priceQuotes;
      return;
    }

    if (route.startsWith('/reminders')) {
      selectedMenu.value = ShellMenuItem.reminders;
      return;
    }

    if (route.startsWith('/price-list')) {
      selectedMenu.value = ShellMenuItem.priceList;
      return;
    }
  }

  String _routeForMenu(ShellMenuItem item) {
    if (item == ShellMenuItem.settings) {
      return AppRoutes.settings.value;
    }
    if (item == ShellMenuItem.customers) {
      return AppRoutes.customers.value;
    }
    if (item == ShellMenuItem.dueDateTracking) {
      return AppRoutes.dueTracking.value;
    }
    if (item == ShellMenuItem.meetings) {
      return AppRoutes.meetings.value;
    }
    if (item == ShellMenuItem.scrapQuality) {
      return AppRoutes.scrapQuality.value;
    }
    if (item == ShellMenuItem.notebook) {
      return AppRoutes.notes.value;
    }
    if (item == ShellMenuItem.priceQuotes) {
      return AppRoutes.priceOffers.value;
    }
    if (item == ShellMenuItem.reminders) {
      return AppRoutes.reminders.value;
    }
    if (item == ShellMenuItem.priceList) {
      return AppRoutes.priceList.value;
    }
    return AppRoutes.dashboard.value;
  }
}
