import 'package:Ok/feature/meetings/controllers/meetings_controller.dart';
import 'package:Ok/feature/meetings/services/meetings_export_service.dart';
import 'package:Ok/feature/meetings/services/meetings_service.dart';
import 'package:get/get.dart';

final class MeetingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MeetingsService>()) {
      Get.put<MeetingsService>(
        MeetingsService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<MeetingsExportService>()) {
      Get.put<MeetingsExportService>(
        MeetingsExportService(),
        permanent: true,
      );
    }

    Get.lazyPut<MeetingsController>(
      () => MeetingsController(
        Get.find<MeetingsService>(),
        Get.find<MeetingsExportService>(),
      ),
    );
  }
}
