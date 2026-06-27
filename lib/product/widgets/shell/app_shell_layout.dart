import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/feature/customers/views/customer_create_page.dart';
import 'package:Ok/feature/dashboard/views/dashboard_page.dart';
import 'package:Ok/feature/customers/views/customer_detail_page.dart';
import 'package:Ok/feature/customers/views/customer_edit_page.dart';
import 'package:Ok/feature/customers/views/customers_list_page.dart';
import 'package:Ok/feature/due_tracking/views/due_tracking_create_page.dart';
import 'package:Ok/feature/due_tracking/views/due_tracking_edit_page.dart';
import 'package:Ok/feature/due_tracking/views/due_tracking_list_page.dart';
import 'package:Ok/feature/meetings/views/meeting_create_page.dart';
import 'package:Ok/feature/meetings/views/meeting_detail_page.dart';
import 'package:Ok/feature/meetings/views/meeting_edit_page.dart';
import 'package:Ok/feature/meetings/views/meetings_list_page.dart';
import 'package:Ok/feature/notes/views/note_create_page.dart';
import 'package:Ok/feature/notes/views/note_detail_page.dart';
import 'package:Ok/feature/notes/views/note_edit_page.dart';
import 'package:Ok/feature/notes/views/notes_list_page.dart';
import 'package:Ok/feature/price_list/views/price_list_create_page.dart';
import 'package:Ok/feature/price_list/views/price_list_detail_page.dart';
import 'package:Ok/feature/price_list/views/price_list_edit_page.dart';
import 'package:Ok/feature/price_list/views/price_list_page.dart';
import 'package:Ok/feature/price_offers/views/price_offer_create_page.dart';
import 'package:Ok/feature/price_offers/views/price_offer_detail_page.dart';
import 'package:Ok/feature/price_offers/views/price_offer_edit_page.dart';
import 'package:Ok/feature/price_offers/views/price_offers_list_page.dart';
import 'package:Ok/feature/reminders/views/reminder_create_page.dart';
import 'package:Ok/feature/reminders/views/reminder_edit_page.dart';
import 'package:Ok/feature/reminders/views/reminders_list_page.dart';
import 'package:Ok/feature/scrap_quality/views/scrap_quality_create_page.dart';
import 'package:Ok/feature/scrap_quality/views/scrap_quality_detail_page.dart';
import 'package:Ok/feature/scrap_quality/views/scrap_quality_edit_page.dart';
import 'package:Ok/feature/scrap_quality/views/scrap_quality_list_page.dart';
import 'package:Ok/feature/settings/view/settings_page.dart';
import 'package:Ok/feature/shell/controller/shell_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/widgets/shell/app_shell_header.dart';
import 'package:Ok/product/widgets/shell/app_shell_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppShellLayout extends StatelessWidget {
  const AppShellLayout({
    required this.controller,
    required this.authController,
    super.key,
  });

  final ShellController controller;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < ShellController.mobileBreakpoint;

        return Obx(
          () {
            final isMobileDrawerOpen = controller.isMobileDrawerOpen.value;
            final showMobileDrawer = isCompact && isMobileDrawerOpen;

            return Scaffold(
              backgroundColor: AppUiTokens.pageBackground,
              body: Stack(
                children: [
                  Row(
                    children: [
                      if (!isCompact) AppShellSidebar(controller: controller),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppShellHeader(
                              controller: controller,
                              authController: authController,
                              isCompact: isCompact,
                            ),
                            Expanded(
                              child: Obx(
                                () {
                                  final route = controller.currentRoute.value.isEmpty
                                      ? Get.currentRoute
                                      : controller.currentRoute.value;

                                  return _ContentPanel(
                                    menu: controller.selectedMenu.value,
                                    route: route,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showMobileDrawer) ...[
                    ModalBarrier(
                      onDismiss: controller.closeMobileDrawer,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    AppShellSidebar(controller: controller),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({
    required this.menu,
    required this.route,
  });

  final ShellMenuItem menu;
  final String route;

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width < ShellController.mobileBreakpoint;
    final padding = EdgeInsets.all(
      isCompact ? AppUiTokens.space16 : AppUiTokens.space32,
    );

    if (menu == ShellMenuItem.dashboard ||
        route == AppRoutes.dashboard.value) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: const DashboardPage(),
        ),
      );
    }

    if (menu == ShellMenuItem.settings) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: const SettingsPage(),
        ),
      );
    }

    if (menu == ShellMenuItem.customers || route.startsWith('/customers')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _CustomersRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.dueDateTracking ||
        route.startsWith('/due-tracking')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _DueTrackingRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.meetings || route.startsWith('/meetings')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _MeetingsRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.scrapQuality ||
        route.startsWith('/scrap-quality')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _ScrapQualityRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.notebook || route.startsWith('/notes')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _NotesRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.priceQuotes ||
        route.startsWith('/price-offers')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _PriceOffersRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.reminders || route.startsWith('/reminders')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _RemindersRouteContent(route: route),
        ),
      );
    }

    if (menu == ShellMenuItem.priceList || route.startsWith('/price-list')) {
      return ColoredBox(
        color: AppUiTokens.surface,
        child: Padding(
          padding: padding,
          child: _PriceListRouteContent(route: route),
        ),
      );
    }

    return ColoredBox(
      color: AppUiTokens.surface,
      child: Padding(
        padding: EdgeInsets.all(
          isCompact ? AppUiTokens.space16 : AppUiTokens.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menu.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppUiTokens.space8),
            Text(
              'Bu modül yakında eklenecek.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    menu.icon,
                    size: 40,
                    color: AppUiTokens.textMuted.withValues(alpha: 0.75),
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  Text(
                    'İçerik alanı hazır',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppUiTokens.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _CustomersRouteContent extends StatelessWidget {
  const _CustomersRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.customersNew.value) {
      return const CustomerCreatePage();
    }

    if (route.endsWith('/edit')) {
      return const CustomerEditPage();
    }

    if (route.startsWith('/customers/') &&
        route != AppRoutes.customersNew.value) {
      return const CustomerDetailPage();
    }

    return const CustomersListPage();
  }
}

class _DueTrackingRouteContent extends StatelessWidget {
  const _DueTrackingRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.dueTrackingNew.value) {
      return const DueTrackingCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/due-tracking/')) {
      return const DueTrackingEditPage();
    }

    return const DueTrackingListPage();
  }
}

class _MeetingsRouteContent extends StatelessWidget {
  const _MeetingsRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.meetingsNew.value) {
      return const MeetingCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/meetings/')) {
      return const MeetingEditPage();
    }

    if (route.startsWith('/meetings/') &&
        route != AppRoutes.meetingsNew.value) {
      return const MeetingDetailPage();
    }

    return const MeetingsListPage();
  }
}

class _ScrapQualityRouteContent extends StatelessWidget {
  const _ScrapQualityRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.scrapQualityNew.value) {
      return const ScrapQualityCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/scrap-quality/')) {
      return const ScrapQualityEditPage();
    }

    if (route.startsWith('/scrap-quality/') &&
        route != AppRoutes.scrapQualityNew.value) {
      return const ScrapQualityDetailPage();
    }

    return const ScrapQualityListPage();
  }
}

class _NotesRouteContent extends StatelessWidget {
  const _NotesRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.notesNew.value) {
      return const NoteCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/notes/')) {
      return const NoteEditPage();
    }

    if (route.startsWith('/notes/') && route != AppRoutes.notesNew.value) {
      return const NoteDetailPage();
    }

    return const NotesListPage();
  }
}

class _PriceOffersRouteContent extends StatelessWidget {
  const _PriceOffersRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.priceOffersNew.value) {
      return const PriceOfferCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/price-offers/')) {
      return const PriceOfferEditPage();
    }

    if (route.startsWith('/price-offers/') &&
        route != AppRoutes.priceOffersNew.value) {
      return const PriceOfferDetailPage();
    }

    return const PriceOffersListPage();
  }
}

class _RemindersRouteContent extends StatelessWidget {
  const _RemindersRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.remindersNew.value) {
      return const ReminderCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/reminders/')) {
      return const ReminderEditPage();
    }

    return const RemindersListPage();
  }
}

class _PriceListRouteContent extends StatelessWidget {
  const _PriceListRouteContent({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.priceListNew.value) {
      return const PriceListCreatePage();
    }

    if (route.endsWith('/edit') && route.startsWith('/price-list/')) {
      return const PriceListEditPage();
    }

    if (route.startsWith('/price-list/') &&
        route != AppRoutes.priceListNew.value) {
      return const PriceListDetailPage();
    }

    return const PriceListPage();
  }
}
