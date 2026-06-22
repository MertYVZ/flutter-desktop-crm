import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/feature/auth/services/auth_service.dart';
import 'package:Ok/product/cache/simple_cache_manager.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:Ok/product/service/database/database_backup_service.dart';
import 'package:Ok/product/service/auth/password_hasher.dart';
import 'package:Ok/product/service/auth/session_service.dart';
import 'package:Ok/product/service/manager/product_service_manager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers app-wide dependencies before any route is opened.
final class InitialBinding extends Bindings {
  /// Initializes dependencies in order before [runApp].
  static Future<void> init() async {
    if (Get.isRegistered<AuthController>()) {
      return;
    }

    final database = AppDatabase();
    Get.put<AppDatabase>(database, permanent: true);
    Get.put<DatabaseService>(DatabaseService(database), permanent: true);
    Get.put<PasswordHasher>(PasswordHasher(), permanent: true);

    final preferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(preferences, permanent: true);

    Get.put<SessionService>(
      SessionService(Get.find<DatabaseService>(), preferences),
      permanent: true,
    );

    Get.put<AuthService>(
      AuthService(
        Get.find<DatabaseService>(),
        Get.find<PasswordHasher>(),
        Get.find<SessionService>(),
      ),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );

    Get.put<DatabaseBackupService>(
      DatabaseBackupService(Get.find<AppDatabase>()),
      permanent: true,
    );

    if (!Get.isRegistered<SimpleCacheManager>()) {
      Get.put<SimpleCacheManager>(SimpleCacheManager.instance, permanent: true);
    }

    Get.lazyPut<ApiService>(ApiService.new, fenix: true);
  }

  @override
  void dependencies() {
    // All dependencies are registered in [init] before runApp.
  }
}
