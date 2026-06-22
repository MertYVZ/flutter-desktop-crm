import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_quality_export_service.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_quality_service.dart';
import 'package:get/get.dart';

final class ScrapQualityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ScrapQualityService>()) {
      Get.put<ScrapQualityService>(
        ScrapQualityService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ScrapQualityExportService>()) {
      Get.put<ScrapQualityExportService>(
        ScrapQualityExportService(),
        permanent: true,
      );
    }

    Get.lazyPut<ScrapQualityController>(
      () => ScrapQualityController(
        Get.find<ScrapQualityService>(),
        Get.find<ScrapQualityExportService>(),
      ),
    );
  }
}
