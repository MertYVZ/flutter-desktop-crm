import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/feature/shell/controller/shell_controller.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/shell/app_shell_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ShellView extends StatefulWidget {
  const ShellView({super.key});

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends BaseState<ShellView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<ShellController>(
      viewModel: Get.find<ShellController>(),
      onPageBuilder: (context, controller) => AppShellLayout(
        controller: controller,
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
