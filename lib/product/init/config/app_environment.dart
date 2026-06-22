import 'package:gen/gen.dart';
import 'package:logger/logger.dart';

final class AppEnvironment {
  AppEnvironment.setup({required AppConfiguration config}) {
    _config = config;
  }

  static late final AppConfiguration _config;
}

enum AppEnvironmentItems {
  baseUrl;

  String get value {
    try {
      switch (this) {
        case AppEnvironmentItems.baseUrl:
          return AppEnvironment._config.baseUrl;
      }
    } on Exception catch (e) {
      Logger().e(e);
      throw Exception('AppEnvironmentItems.$name not initialized');
    } on Object catch (e) {
      Logger().e(e);
      throw Exception('AppEnvironmentItems.$name not initialized');
    }
  }
}
