import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/feature/shell/controller/shell_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/shell/app_shell_profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppShellHeader extends StatelessWidget {
  const AppShellHeader({
    required this.controller,
    required this.authController,
    required this.isCompact,
    super.key,
  });

  final ShellController controller;
  final AuthController authController;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppUiTokens.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space16),
      decoration: const BoxDecoration(
        color: AppUiTokens.surface,
        border: Border(
          bottom: BorderSide(color: AppUiTokens.border),
        ),
      ),
      child: Row(
        children: [
          if (isCompact)
            IconButton(
              tooltip: 'Menü',
              onPressed: controller.toggleMobileDrawer,
              icon: const Icon(Icons.menu_rounded, size: 20),
            ),
          const SizedBox(width: AppUiTokens.space8),
          Expanded(
            child: Obx(
              () => _Breadcrumbs(menu: controller.selectedMenu.value),
            ),
          ),
          AppShellProfileMenu(authController: authController),
        ],
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.menu});

  final ShellMenuItem menu;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          'CRM',
          style: textTheme.bodyMedium?.copyWith(
            color: AppUiTokens.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space8),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppUiTokens.textMuted.withValues(alpha: 0.8),
          ),
        ),
        Text(
          menu.title,
          style: textTheme.bodyMedium?.copyWith(
            color: AppUiTokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
