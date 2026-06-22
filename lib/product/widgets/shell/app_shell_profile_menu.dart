import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

enum _ProfileAction { logout }

class AppShellProfileMenu extends StatelessWidget {
  const AppShellProfileMenu({required this.authController, super.key});

  final AuthController authController;

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Yönetici';
      default:
        return role ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.currentUser.value;
      final name = authController.displayName;
      final username = user?.username ?? '';
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
      final isLoading = authController.isLogoutLoading.value;

      return PopupMenuButton<_ProfileAction>(
        tooltip: 'Hesap menüsü',
        offset: const Offset(0, 8),
        enabled: !isLoading,
        onSelected: (action) {
          if (action == _ProfileAction.logout) {
            authController.logout();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<_ProfileAction>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppUiTokens.textPrimary,
                      ),
                ),
                if (username.isNotEmpty) ...[
                  const SizedBox(height: AppUiTokens.space4),
                  Text(
                    username,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppUiTokens.textMuted,
                        ),
                  ),
                ],
                const SizedBox(height: AppUiTokens.space4),
                Text(
                  _roleLabel(user?.role),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppUiTokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<_ProfileAction>(
            value: _ProfileAction.logout,
            child: Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppUiTokens.textSecondary,
                  ),
                const SizedBox(width: AppUiTokens.space12),
                Text(
                  isLoading ? 'Çıkış yapılıyor...' : 'Çıkış Yap',
                  style: TextStyle(
                    color: isLoading
                        ? AppUiTokens.textMuted
                        : AppUiTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: MouseRegion(
          cursor: isLoading
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppUiTokens.space8,
              vertical: AppUiTokens.space4,
            ),
            decoration: BoxDecoration(
              color: AppUiTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(color: AppUiTokens.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppUiTokens.accentSoft,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorName.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: AppUiTokens.space8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppUiTokens.textPrimary,
                        ),
                  ),
                ),
                const SizedBox(width: AppUiTokens.space4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppUiTokens.textMuted,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
