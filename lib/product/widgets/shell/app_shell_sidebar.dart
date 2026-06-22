import 'package:Ok/feature/shell/controller/shell_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class AppShellSidebar extends StatelessWidget {
  const AppShellSidebar({
    required this.controller,
    super.key,
  });

  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppUiTokens.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppUiTokens.surface,
        border: Border(
          right: BorderSide(color: AppUiTokens.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppUiTokens.space24,
              AppUiTokens.space24,
              AppUiTokens.space24,
              AppUiTokens.space16,
            ),
            child: Row(
              children: [
                Container(
                  child: Assets.icons.logo.svg(package: 'gen', width: 160),
                ),
                const SizedBox(width: AppUiTokens.space12),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppUiTokens.space12,
                  vertical: AppUiTokens.space12,
                ),
                children: ShellMenuItemX.mainItems
                    .map(
                      (item) => _SidebarTile(
                        item: item,
                        selected: controller.selectedMenu.value == item,
                        onTap: () => controller.selectMenu(item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppUiTokens.space12,
              AppUiTokens.space8,
              AppUiTokens.space12,
              AppUiTokens.space12,
            ),
            child: Obx(
              () => _SidebarTile(
                item: ShellMenuItem.settings,
                selected:
                    controller.selectedMenu.value == ShellMenuItem.settings,
                onTap: () => controller.selectMenu(ShellMenuItem.settings),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ShellMenuItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space4),
      child: Material(
        color: selected ? AppUiTokens.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(
                color: selected
                    ? ColorName.primary.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppUiTokens.space12,
              vertical: AppUiTokens.space12,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color:
                      selected ? ColorName.primary : AppUiTokens.textSecondary,
                ),
                const SizedBox(width: AppUiTokens.space12),
                Text(
                  item.title,
                  style: TextStyle(
                    color: selected
                        ? AppUiTokens.textPrimary
                        : AppUiTokens.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
