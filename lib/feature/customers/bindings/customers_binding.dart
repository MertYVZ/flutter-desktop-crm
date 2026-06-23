import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/services/customer_detail_service.dart';
import 'package:Ok/feature/customers/services/customers_service.dart';
import 'package:Ok/feature/reminders/services/reminders_service.dart';
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

    if (!Get.isRegistered<CustomerDetailService>()) {
      Get.put<CustomerDetailService>(
        CustomerDetailService(Get.find()),
        permanent: true,
      );
    }

    Get.lazyPut<CustomersController>(
      () => CustomersController(Get.find<CustomersService>()),
    );

    Get.lazyPut<CustomerDetailController>(
      () => CustomerDetailController(
        Get.find<CustomerDetailService>(),
        Get.find<CustomersService>(),
        Get.find<RemindersService>(),
      ),
    );
  }
}
