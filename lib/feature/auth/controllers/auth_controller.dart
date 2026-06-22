import 'package:Ok/feature/auth/services/auth_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/constants/auth_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:get/get.dart';

/// Global authentication state and UI actions.
final class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final RxBool isAuthChecking = false.obs;
  final RxBool hasCheckedAuthState = false.obs;
  final RxBool isLoginLoading = false.obs;
  final RxBool isLogoutLoading = false.obs;
  final RxBool isPasswordLoading = false.obs;
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isAuthenticated = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString username = ''.obs;
  final RxString password = ''.obs;
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureOldPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  String get displayName =>
      currentUser.value?.displayName ?? currentUser.value?.username ?? '';

  bool get mustChangePassword => currentUser.value?.mustChangePassword ?? false;

  @override
  void onInit() {
    super.onInit();
    ever(currentUser, (_) => _syncAuthState());
  }

  Future<void> checkAuthState() async {
    hasCheckedAuthState.value = false;
    isAuthChecking.value = true;
    try {
      await _authService.seedDefaultAdminIfNeeded();

      final hasSession = await _authService.hasValidSession();
      if (!hasSession) {
        _resetAuthState();
        return;
      }

      final user = await _authService.getCurrentUser();
      if (user == null) {
        await _authService.logout();
        _resetAuthState();
        return;
      }

      currentUser.value = user;
      isAuthenticated.value = true;
    } finally {
      isAuthChecking.value = false;
      hasCheckedAuthState.value = true;
    }
  }

  void resetPasswordFormState() {
    isPasswordLoading.value = false;
    clearError();
  }

  void resetLoginFormState() {
    isLoginLoading.value = false;
    clearError();
  }

  Future<void> login() async {
    clearError();
    isLoginLoading.value = true;
    try {
      final result = await _authService.login(
        username.value.trim(),
        password.value,
      );

      if (!result.success) {
        errorMessage.value = result.errorMessage;
        return;
      }

      currentUser.value = result.user;
      isAuthenticated.value = true;
      password.value = '';
      isLoginLoading.value = false;

      if (result.requiresPasswordChange) {
        await Get.offAllNamed<void>(AppRoutes.changePassword.value);
        return;
      }

      await Get.offAllNamed<void>(AppRoutes.dashboard.value);
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLogoutLoading.value = true;
    try {
      await _authService.logout();
      _resetAuthState();
      username.value = '';
      password.value = '';
      clearError();
      isLoginLoading.value = false;
      isPasswordLoading.value = false;
      isLogoutLoading.value = false;
      await Get.offAllNamed<void>(AppRoutes.login.value);
    } finally {
      isLogoutLoading.value = false;
      isLoginLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    clearError();
    isPasswordLoading.value = true;
    try {
      final validationError = Validators.validatePasswordChange(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (validationError != null) {
        errorMessage.value = validationError;
        return false;
      }

      if (mustChangePassword) {
        final isOldPasswordValid =
            await _authService.verifyCurrentUserPassword(oldPassword);
        if (!isOldPasswordValid) {
          errorMessage.value = AuthMessages.invalidCredentials;
          return false;
        }
        await _authService.forceChangePassword(newPassword);
      } else {
        await _authService.changePassword(oldPassword, newPassword);
      }

      final user = await _authService.getCurrentUser();
      currentUser.value = user;
      isAuthenticated.value = user != null;

      await Get.offAllNamed<void>(AppRoutes.dashboard.value);
      return true;
    } on Exception catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      return false;
    } catch (error) {
      errorMessage.value = error.toString();
      return false;
    } finally {
      isPasswordLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = null;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> navigateFromSplash() async {
    if (!isAuthenticated.value) {
      await Get.offAllNamed<void>(AppRoutes.login.value);
      return;
    }

    if (mustChangePassword) {
      await Get.offAllNamed<void>(AppRoutes.changePassword.value);
      return;
    }

    await Get.offAllNamed<void>(AppRoutes.dashboard.value);
  }

  void _resetAuthState() {
    currentUser.value = null;
    isAuthenticated.value = false;
  }

  void _syncAuthState() {
    isAuthenticated.value = currentUser.value != null;
  }
}
