import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Redirects unauthenticated users away from protected routes.
final class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return RouteSettings(name: AppRoutes.login.value);
    }

    final authController = Get.find<AuthController>();
    if (!authController.hasCheckedAuthState.value) {
      return RouteSettings(name: AppRoutes.splash.value);
    }

    if (!authController.isAuthenticated.value) {
      return RouteSettings(name: AppRoutes.login.value);
    }

    if (authController.mustChangePassword &&
        route != AppRoutes.changePassword.value) {
      return RouteSettings(name: AppRoutes.changePassword.value);
    }

    return null;
  }
}

/// Redirects authenticated users away from the login screen.
final class LoginRedirectMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return null;
    }

    final authController = Get.find<AuthController>();
    if (!authController.hasCheckedAuthState.value) {
      return RouteSettings(name: AppRoutes.splash.value);
    }

    if (!authController.isAuthenticated.value) {
      return null;
    }

    if (authController.mustChangePassword) {
      return RouteSettings(name: AppRoutes.changePassword.value);
    }

    return RouteSettings(name: AppRoutes.dashboard.value);
  }
}

/// Ensures only authenticated users can access password change.
final class ChangePasswordMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return RouteSettings(name: AppRoutes.login.value);
    }

    final authController = Get.find<AuthController>();
    if (!authController.hasCheckedAuthState.value) {
      return RouteSettings(name: AppRoutes.splash.value);
    }

    if (!authController.isAuthenticated.value) {
      return RouteSettings(name: AppRoutes.login.value);
    }

    return null;
  }
}
