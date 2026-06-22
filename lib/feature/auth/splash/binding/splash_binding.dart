import 'package:Ok/feature/auth/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

final class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      SplashController.new,
    );
  }
}
