import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/auth_page_scaffold.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_password_field.dart';
import 'package:Ok/product/widgets/panel/panel_primary_button.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends BaseState<LoginView> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().resetLoginFormState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AuthController>(
      viewModel: Get.find<AuthController>(),
      onPageBuilder: (context, controller) => _LoginBody(
        controller: controller,
        usernameController: _usernameController,
        passwordController: _passwordController,
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody({
    required this.controller,
    required this.usernameController,
    required this.passwordController,
  });

  final AuthController controller;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      badge: 'Güvenli Giriş',
      title: 'Hoş geldiniz',
      subtitle: 'Devam etmek için hesap bilgilerinizi girin.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelTextField(
            controller: usernameController,
            label: 'Kullanıcı adı',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            onChanged: controller.username.call,
          ),
          const SizedBox(height: AppUiTokens.space24),
          Obx(
            () => PanelPasswordField(
              controller: passwordController,
              label: 'Şifre',
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.login(),
              onToggleVisibility: controller.togglePasswordVisibility,
              onChanged: controller.password.call,
            ),
          ),
          const SizedBox(height: AppUiTokens.space24),
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
              label: 'Giriş Yap',
              isLoading: controller.isLoginLoading.value,
              onPressed: controller.login,
            ),
          ),
        ],
      ),
    );
  }
}
