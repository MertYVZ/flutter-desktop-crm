import 'package:gen/src/environment/app_configuration.dart';

/// Production Environment Configuration
final class ProdEnv implements AppConfiguration {
  @override
  String get baseUrl => 'https://api.production.com';
}
