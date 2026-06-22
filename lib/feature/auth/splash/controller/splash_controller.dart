import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/product/bindings/initial_binding.dart';
import 'package:Ok/product/init/application_initialize.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:get/get.dart';

final class SplashController extends GetxController {
  SplashController();

  final RxBool isPreparing = true.obs;

  static const _minimumSplashDuration = Duration(milliseconds: 900);

  @override
  void onReady() {
    super.onReady();
    _initialize();
  }

  Future<void> _initialize() async {
    final startedAt = DateTime.now();
    isPreparing.value = true;

    await ApplicationInitialize().makeInitialize();
    await InitialBinding.init();

    final authController = Get.find<AuthController>();
    await authController.checkAuthState();
    await _waitForMinimumSplashTime(startedAt);
    await _navigateToResolvedRoute(authController);
  }

  Future<void> _waitForMinimumSplashTime(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumSplashDuration - elapsed;
    if (remaining <= Duration.zero) {
      return;
    }

    await Future<void>.delayed(remaining);
  }

  Future<void> _navigateToResolvedRoute(AuthController authController) async {
    isPreparing.value = false;

    if (!authController.isAuthenticated.value) {
      await Get.offAllNamed<void>(AppRoutes.login.value);
      return;
    }

    if (authController.mustChangePassword) {
      await Get.offAllNamed<void>(AppRoutes.changePassword.value);
      return;
    }

    await Get.offAllNamed<void>(AppRoutes.dashboard.value);
  }
}
