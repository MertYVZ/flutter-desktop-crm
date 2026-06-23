import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/services/price_list_export_service.dart';
import 'package:Ok/feature/price_list/services/price_list_service.dart';
import 'package:get/get.dart';

final class PriceListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PriceListService>()) {
      Get.put<PriceListService>(
        PriceListService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<PriceListExportService>()) {
      Get.put<PriceListExportService>(
        PriceListExportService(),
        permanent: true,
      );
    }

    Get.lazyPut<PriceListController>(
      () => PriceListController(
        Get.find<PriceListService>(),
        Get.find<PriceListExportService>(),
      ),
    );
  }
}
