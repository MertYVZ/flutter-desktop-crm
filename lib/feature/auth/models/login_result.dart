import 'package:Ok/product/database/app_database.dart';

/// Result of a login attempt.
final class LoginResult {
  const LoginResult._({
    required this.success,
    this.user,
    this.errorMessage,
    this.requiresPasswordChange = false,
  });

  final bool success;
  final User? user;
  final String? errorMessage;
  final bool requiresPasswordChange;

  factory LoginResult.success(
    User user, {
    bool requiresPasswordChange = false,
  }) {
    return LoginResult._(
      success: true,
      user: user,
      requiresPasswordChange: requiresPasswordChange,
    );
  }

  factory LoginResult.failure(String message) {
    return LoginResult._(
      success: false,
      errorMessage: message,
    );
  }
}
