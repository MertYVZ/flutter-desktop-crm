import 'package:Ok/feature/auth/binding/change_password_binding.dart';
import 'package:Ok/feature/auth/login/binding/login_binding.dart';
import 'package:Ok/feature/auth/login/view/change_password_page.dart';
import 'package:Ok/feature/auth/login/view/login_view.dart';
import 'package:Ok/feature/auth/splash/binding/splash_binding.dart';
import 'package:Ok/feature/auth/splash/splash_screen.dart';
import 'package:Ok/feature/shell/binding/shell_binding.dart';
import 'package:Ok/feature/shell/view/shell_view.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/middleware/auth_middleware.dart';
import 'package:get/get.dart';

final class AppScreens {
  AppScreens._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash.value,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login.value,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [LoginRedirectMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.changePassword.value,
      page: () => const ChangePasswordPage(),
      binding: ChangePasswordBinding(),
      middlewares: [ChangePasswordMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.settings.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customersNew.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customersEdit.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customersDetail.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customers.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dueTrackingNew.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dueTrackingEdit.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dueTracking.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.meetingsNew.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.meetingsEdit.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.meetingsDetail.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.meetings.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.scrapQualityNew.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.scrapQualityEdit.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.scrapQuality.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notesNew.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notesEdit.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notesDetail.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notes.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.priceOffersNew.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.priceOffersEdit.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.priceOffersDetail.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.priceOffers.value,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
  ];
}
