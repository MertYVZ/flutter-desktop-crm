import 'package:Ok/feature/notes/controllers/notes_controller.dart';
import 'package:Ok/feature/notes/services/notes_export_service.dart';
import 'package:Ok/feature/notes/services/notes_service.dart';
import 'package:get/get.dart';

final class NotesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotesService>()) {
      Get.put<NotesService>(
        NotesService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotesExportService>()) {
      Get.put<NotesExportService>(
        NotesExportService(),
        permanent: true,
      );
    }

    Get.lazyPut<NotesController>(
      () => NotesController(
        Get.find<NotesService>(),
        Get.find<NotesExportService>(),
      ),
    );
  }
}
