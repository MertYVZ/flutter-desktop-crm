import 'package:gen/src/environment/app_configuration.dart';

/// Development Environment Configuration
final class DevEnv implements AppConfiguration {
  @override
  String get baseUrl => 'https://caseapi.servicelabs.tech';
}
