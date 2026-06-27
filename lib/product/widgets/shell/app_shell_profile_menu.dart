import 'package:Ok/feature/auth/controllers/auth_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/shared/widgets/anchored_overlay.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class AppShellProfileMenu extends StatefulWidget {
  const AppShellProfileMenu({required this.authController, super.key});

  final AuthController authController;

  @override
  State<AppShellProfileMenu> createState() => _AppShellProfileMenuState();
}

class _AppShellProfileMenuState extends State<AppShellProfileMenu> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isTriggerHovered = false;
  bool _isLogoutHovered = false;

  AuthController get _authController => widget.authController;

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Yönetici';
      default:
        return role ?? '';
    }
  }

  bool _shouldShowRole(String name, String role) {
    if (role.isEmpty) {
      return false;
    }

    return name.trim().toLowerCase() != role.trim().toLowerCase();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_authController.isLogoutLoading.value) {
      return;
    }

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen || _isLogoutHovered) {
      setState(() {
        _isOpen = false;
        _isLogoutHovered = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    _removeOverlay();
    await _authController.logout();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _triggerKey.currentContext!.findRenderObject()! as RenderBox;
    final anchorSize = renderBox.size;
    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);
    const menuWidth = 260.0;

    final user = _authController.currentUser.value;
    final name = _authController.displayName;
    final username = user?.username ?? '';
    final role = _roleLabel(user?.role);
    final showRole = _shouldShowRole(name, role);
    final menuHeight = showRole ? 156.0 : 132.0;

    return OverlayEntry(
      builder: (overlayContext) {
        final isLoading = _authController.isLogoutLoading.value;

        final menu = Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(color: AppUiTokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppUiTokens.space16,
                      AppUiTokens.space12,
                      AppUiTokens.space16,
                      AppUiTokens.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(overlayContext)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppUiTokens.textPrimary,
                              ),
                        ),
                        if (username.isNotEmpty) ...[
                          const SizedBox(height: AppUiTokens.space4),
                          Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(overlayContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppUiTokens.textMuted,
                                ),
                          ),
                        ],
                        if (showRole) ...[
                          const SizedBox(height: AppUiTokens.space4),
                          Text(
                            role,
                            style: Theme.of(overlayContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppUiTokens.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppUiTokens.border),
                  MouseRegion(
                    onEnter: (_) {
                      _isLogoutHovered = true;
                      _overlayEntry?.markNeedsBuild();
                    },
                    onExit: (_) {
                      _isLogoutHovered = false;
                      _overlayEntry?.markNeedsBuild();
                    },
                    cursor: isLoading
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: isLoading ? null : _handleLogout,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppUiTokens.space16,
                        ),
                        color: _isLogoutHovered
                            ? AppUiTokens.surfaceMuted
                            : AppUiTokens.surface,
                        child: Row(
                          children: [
                            if (isLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                Icons.logout_rounded,
                                size: 18,
                                color: ColorName.error.withValues(alpha: 0.9),
                              ),
                            const SizedBox(width: AppUiTokens.space12),
                            Expanded(
                              child: Text(
                                isLoading
                                    ? 'Çıkış yapılıyor...'
                                    : 'Çıkış Yap',
                                style: TextStyle(
                                  color: isLoading
                                      ? AppUiTokens.textMuted
                                      : AppUiTokens.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return AnchoredOverlayLayout(
          anchorOffset: anchorOffset,
          anchorSize: anchorSize,
          screenSize: screenSize,
          menuWidth: menuWidth,
          menuHeight: menuHeight,
          alignToAnchorEnd: true,
          onDismiss: _removeOverlay,
          child: menu,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = _authController.displayName;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
      final isLoading = _authController.isLogoutLoading.value;

      final borderColor = _isOpen
          ? ColorName.primary
          : _isTriggerHovered
              ? AppUiTokens.border.withValues(alpha: 0.9)
              : AppUiTokens.border;

      return MouseRegion(
        onEnter: (_) => setState(() => _isTriggerHovered = true),
        onExit: (_) => setState(() => _isTriggerHovered = false),
        cursor: isLoading
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          key: _triggerKey,
          onTap: isLoading ? null : _toggleOverlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            padding: const EdgeInsets.symmetric(
              horizontal: AppUiTokens.space8,
            ),
            decoration: BoxDecoration(
              color: _isOpen
                  ? AppUiTokens.accentSoft.withValues(alpha: 0.35)
                  : AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(
                color: borderColor,
                width: _isOpen ? 1.5 : 1,
              ),
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
                          fontSize: 14,
                        ),
                  ),
                ),
                const SizedBox(width: AppUiTokens.space4),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _isOpen ? ColorName.primary : AppUiTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
