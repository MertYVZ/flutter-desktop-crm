import 'package:get/get.dart';

/// Shared route arguments for pre-filling create forms from customer detail.
abstract final class AppRouteArgs {
  static const customerIdKey = 'customerId';

  static Map<String, String> withCustomerId(String customerId) => {
        customerIdKey: customerId,
      };

  static String? readCustomerId() {
    final args = Get.arguments;
    if (args is! Map) {
      return null;
    }

    final value = args[customerIdKey];
    if (value is! String || value.isEmpty) {
      return null;
    }

    return value;
  }
}
