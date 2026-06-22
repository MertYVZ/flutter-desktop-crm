import 'package:Ok/feature/reminders/controllers/reminders_controller.dart';
import 'package:Ok/feature/reminders/services/reminders_export_service.dart';
import 'package:Ok/feature/reminders/services/reminders_service.dart';
import 'package:get/get.dart';

final class RemindersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RemindersService>()) {
      Get.put<RemindersService>(
        RemindersService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<RemindersExportService>()) {
      Get.put<RemindersExportService>(
        RemindersExportService(),
        permanent: true,
      );
    }

    Get.lazyPut<RemindersController>(
      () => RemindersController(
        Get.find<RemindersService>(),
        Get.find<RemindersExportService>(),
      ),
    );
  }
}
