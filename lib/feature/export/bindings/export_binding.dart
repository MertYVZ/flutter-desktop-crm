import 'package:Ok/feature/export/controllers/export_controller.dart';
import 'package:Ok/feature/export/services/export_service.dart';
import 'package:get/get.dart';

final class ExportBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ExportService>()) {
      Get.put<ExportService>(
        ExportService(Get.find()),
        permanent: true,
      );
    }

    Get.lazyPut<ExportController>(
      () => ExportController(Get.find<ExportService>()),
    );
  }
}
