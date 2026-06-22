import 'package:drift/drift.dart';
import 'package:Ok/feature/auth/models/login_result.dart';
import 'package:Ok/feature/auth/models/user_role.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:Ok/product/service/auth/password_hasher.dart';
import 'package:Ok/product/service/auth/session_service.dart';
import 'package:Ok/product/utility/constants/auth_messages.dart';
import 'package:Ok/product/utility/date_time_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:uuid/uuid.dart';

/// Local authentication service for desktop CRM access control.
final class AuthService {
  AuthService(
    this._databaseService,
    this._passwordHasher,
    this._sessionService,
  );

  static const defaultAdminUsername = 'admin';
  static const defaultAdminPassword = 'OkTeknik2026!';
  static const defaultAdminDisplayName = 'Yönetici';
  static const maxFailedLoginAttempts = 5;
  static const lockDuration = Duration(minutes: 5);

  final DatabaseService _databaseService;
  final PasswordHasher _passwordHasher;
  final SessionService _sessionService;
  final Uuid _uuid = const Uuid();

  Future<User?> getCurrentUser() async {
    final session = await _sessionService.getActiveSession();
    if (session == null) {
      return null;
    }
    return _databaseService.users.getUserById(session.userId);
  }

  Future<bool> hasValidSession() async {
    final session = await _sessionService.getActiveSession();
    return session != null;
  }

  Future<LoginResult> login(String username, String password) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      return LoginResult.failure(AuthMessages.invalidCredentials);
    }

    final user =
        await _databaseService.users.getUserByUsername(normalizedUsername);
    if (user == null || !user.isActive) {
      return LoginResult.failure(AuthMessages.invalidCredentials);
    }

    if (DateTimeUtils.isInFuture(user.lockedUntil)) {
      return LoginResult.failure(AuthMessages.accountLocked);
    }

    final isValid = await _passwordHasher.verifyPassword(
      password: password,
      salt: user.passwordSalt,
      hash: user.passwordHash,
      iterations: user.passwordIterations,
    );

    if (!isValid) {
      await _registerFailedLogin(user);
      return LoginResult.failure(AuthMessages.invalidCredentials);
    }

    final now = DateTime.now();
    final updatedUser = user.copyWith(
      failedLoginCount: 0,
      lockedUntil: const Value(null),
      lastLoginAt: Value(now),
      updatedAt: now,
    );
    await _databaseService.users.updateUser(updatedUser);
    await _sessionService.createSession(user.id);

    final refreshedUser = await _databaseService.users.getUserById(user.id);
    if (refreshedUser == null) {
      return LoginResult.failure(AuthMessages.genericError);
    }

    return LoginResult.success(
      refreshedUser,
      requiresPasswordChange: refreshedUser.mustChangePassword,
    );
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw StateError(AuthMessages.sessionExpired);
    }

    final isValid = await _passwordHasher.verifyPassword(
      password: oldPassword,
      salt: user.passwordSalt,
      hash: user.passwordHash,
      iterations: user.passwordIterations,
    );
    if (!isValid) {
      throw Exception(AuthMessages.invalidCredentials);
    }

    final validationError = Validators.validatePasswordChange(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: newPassword,
    );
    if (validationError != null) {
      throw Exception(validationError);
    }

    await _updateUserPassword(user, newPassword, mustChangePassword: false);
  }

  Future<void> forceChangePassword(String newPassword) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw StateError(AuthMessages.sessionExpired);
    }

    if (!user.mustChangePassword) {
      throw StateError('Zorunlu şifre değişikliği gerekli değil.');
    }

    final validationError = Validators.validateNewPassword(newPassword);
    if (validationError != null) {
      throw Exception(validationError);
    }

    await _updateUserPassword(user, newPassword, mustChangePassword: false);
  }

  Future<void> seedDefaultAdminIfNeeded() async {
    final userCount = await _databaseService.users.countActiveUsers();
    if (userCount > 0) {
      return;
    }

    final salt = _passwordHasher.generateSalt();
    final iterations = _passwordHasher.defaultIterations;
    final passwordHash = await _passwordHasher.hashPassword(
      password: defaultAdminPassword,
      salt: salt,
      iterations: iterations,
    );

    final now = DateTime.now();
    await _databaseService.users.insertUser(
      UsersCompanion.insert(
        id: _uuid.v4(),
        username: defaultAdminUsername,
        displayName: defaultAdminDisplayName,
        passwordHash: passwordHash,
        passwordSalt: salt,
        passwordIterations: iterations,
        role: UserRole.admin.value,
        mustChangePassword: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> revokeAllSessions() async {
    final user = await getCurrentUser();
    if (user == null) {
      return;
    }
    await _databaseService.authSessions.revokeAllForUser(user.id);
    await _sessionService.clearSession();
  }

  Future<bool> verifyCurrentUserPassword(String password) async {
    final user = await getCurrentUser();
    if (user == null) {
      return false;
    }

    return _passwordHasher.verifyPassword(
      password: password,
      salt: user.passwordSalt,
      hash: user.passwordHash,
      iterations: user.passwordIterations,
    );
  }

  Future<void> _registerFailedLogin(User user) async {
    final failedCount = user.failedLoginCount + 1;
    final now = DateTime.now();

    final lockedUntil = failedCount >= maxFailedLoginAttempts
        ? now.add(lockDuration)
        : user.lockedUntil;

    final updatedUser = user.copyWith(
      failedLoginCount: failedCount,
      lockedUntil: Value(lockedUntil),
      updatedAt: now,
    );
    await _databaseService.users.updateUser(updatedUser);
  }

  Future<void> _updateUserPassword(
    User user,
    String newPassword, {
    required bool mustChangePassword,
  }) async {
    final salt = _passwordHasher.generateSalt();
    final iterations = _passwordHasher.defaultIterations;
    final passwordHash = await _passwordHasher.hashPassword(
      password: newPassword,
      salt: salt,
      iterations: iterations,
    );

    final now = DateTime.now();
    final updatedUser = user.copyWith(
      passwordHash: passwordHash,
      passwordSalt: salt,
      passwordIterations: iterations,
      mustChangePassword: mustChangePassword,
      failedLoginCount: 0,
      lockedUntil: const Value(null),
      updatedAt: now,
    );
    await _databaseService.users.updateUser(updatedUser);
  }
}
