import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/services/customers_service.dart';
import 'package:get/get.dart';

final class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomersService>()) {
      Get.put<CustomersService>(
        CustomersService(Get.find()),
        permanent: true,
      );
    }

    Get.lazyPut<CustomersController>(
      () => CustomersController(Get.find<CustomersService>()),
    );
  }
}
