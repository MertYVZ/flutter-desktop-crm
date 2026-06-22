import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/auth_messages.dart';
import 'package:Ok/product/widgets/panel/auth_page_scaffold.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_password_field.dart';
import 'package:Ok/product/widgets/panel/panel_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends BaseState<ChangePasswordPage> {
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().resetPasswordFormState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AuthController>(
      viewModel: Get.find<AuthController>(),
      onPageBuilder: (context, controller) => PopScope(
        canPop: !controller.mustChangePassword,
        child: _ChangePasswordBody(
          controller: controller,
          oldPasswordController: _oldPasswordController,
          newPasswordController: _newPasswordController,
          confirmPasswordController: _confirmPasswordController,
        ),
      ),
    );
  }
}

class _ChangePasswordBody extends StatelessWidget {
  const _ChangePasswordBody({
    required this.controller,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  final AuthController controller;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    final isFirstLogin = controller.mustChangePassword;

    return AuthPageScaffold(
      badge: isFirstLogin ? 'İlk Giriş' : 'Hesap Güvenliği',
      title: isFirstLogin ? 'Şifrenizi belirleyin' : 'Şifre değiştir',
      subtitle: isFirstLogin
          ? 'Devam etmek için güçlü bir şifre oluşturun.'
          : 'Hesabınızı korumak için yeni bir şifre tanımlayın.',
      maxWidth: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => PanelPasswordField(
              controller: oldPasswordController,
              label: 'Mevcut şifre',
              obscureText: controller.obscureOldPassword.value,
              onToggleVisibility: controller.obscureOldPassword.toggle,
            ),
          ),
          const SizedBox(height: AppUiTokens.space24),
          Obx(
            () => PanelPasswordField(
              controller: newPasswordController,
              label: 'Yeni şifre',
              obscureText: controller.obscureNewPassword.value,
              onToggleVisibility: controller.obscureNewPassword.toggle,
            ),
          ),
          const SizedBox(height: AppUiTokens.space24),
          Obx(
            () => PanelPasswordField(
              controller: confirmPasswordController,
              label: 'Yeni şifre tekrar',
              obscureText: controller.obscureConfirmPassword.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(controller),
              onToggleVisibility: controller.obscureConfirmPassword.toggle,
            ),
          ),
          const SizedBox(height: AppUiTokens.space24),
          const PanelMessage(
            message: PasswordValidationMessages.rulesInfo,
            type: PanelMessageType.info,
          ),
          const SizedBox(height: AppUiTokens.space16),
          Obx(() {
            final message = controller.errorMessage.value;
            if (message == null || message.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppUiTokens.space16),
              child: PanelMessage(message: message),
            );
          }),
          Obx(
            () => PanelPrimaryButton(
              label: 'Kaydet ve Devam Et',
              isLoading: controller.isPasswordLoading.value,
              onPressed: () => _submit(controller),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AuthController controller) async {
    await controller.changePassword(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }
}
