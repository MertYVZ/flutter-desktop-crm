import 'package:Ok/feature/due_tracking/controllers/due_tracking_controller.dart';
import 'package:Ok/feature/due_tracking/services/due_tracking_export_service.dart';
import 'package:Ok/feature/due_tracking/services/due_tracking_service.dart';
import 'package:get/get.dart';

final class DueTrackingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DueTrackingService>()) {
      Get.put<DueTrackingService>(
        DueTrackingService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<DueTrackingExportService>()) {
      Get.put<DueTrackingExportService>(
        DueTrackingExportService(),
        permanent: true,
      );
    }

    Get.lazyPut<DueTrackingController>(
      () => DueTrackingController(
        Get.find<DueTrackingService>(),
        Get.find<DueTrackingExportService>(),
      ),
    );
  }
}
