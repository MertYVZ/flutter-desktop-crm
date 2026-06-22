import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/feature/dashboard/services/dashboard_service.dart';
import 'package:Ok/feature/reminders/services/reminders_service.dart';
import 'package:get/get.dart';

final class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DashboardService>()) {
      Get.put<DashboardService>(
        DashboardService(
          Get.find(),
          Get.find<RemindersService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<DashboardService>()),
    );
  }
}
