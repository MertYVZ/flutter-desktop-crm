import 'package:Ok/feature/import/controllers/import_controller.dart';
import 'package:Ok/feature/import/services/import_service.dart';
import 'package:get/get.dart';

final class ImportBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ImportService>()) {
      Get.put<ImportService>(
        ImportService(Get.find()),
        permanent: true,
      );
    }

    Get.lazyPut<ImportController>(
      () => ImportController(Get.find<ImportService>()),
    );
  }
}
