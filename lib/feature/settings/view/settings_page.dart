import 'package:Ok/feature/price_offers/models/offer_pdf_settings.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/settings/controller/settings_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/auth_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_password_field.dart';
import 'package:Ok/product/widgets/panel/panel_primary_button.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

const _settingsMaxWidth = 1200.0;
const _twoColumnBreakpoint = 900.0;
const _leftColumnFlex = 62;
const _rightColumnFlex = 38;

bool _isSettingsBusy(SettingsController controller) {
  return controller.isChangingPassword.value ||
      controller.isBackingUp.value ||
      controller.isRestoring.value ||
      controller.isSavingPdfSettings.value ||
      controller.isSavingLegalTemplate.value;
}

final class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends BaseState<SettingsPage>
    with SingleTickerProviderStateMixin {
  static const _tabCount = 4;

  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsController>(
      viewModel: Get.find<SettingsController>(),
      onPageBuilder: (context, controller) => LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth.clamp(0.0, _settingsMaxWidth);

          return Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PageHeader(),
                  const SizedBox(height: AppUiTokens.space24),
                  _FeedbackMessages(controller: controller),
                  const SizedBox(height: AppUiTokens.space24),
                  _SettingsTabBar(tabController: _tabController),
                  const SizedBox(height: AppUiTokens.space16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _HesapTabContent(
                          controller: controller,
                          oldPasswordController: _oldPasswordController,
                          newPasswordController: _newPasswordController,
                          confirmPasswordController:
                              _confirmPasswordController,
                          onSubmitPassword: () =>
                              _submitPasswordChange(controller),
                        ),
                        _VeriTabContent(controller: controller),
                        _OfferPdfSettingsCard(controller: controller),
                        _LegalTextTemplatesCard(controller: controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitPasswordChange(SettingsController controller) async {
    final success = await controller.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      return;
    }

    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ayarlar',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Text(
          'Hesap güvenliği, veritabanı yedekleme, teklif PDF bilgileri ve yasal metin şablonlarını sekmeler halinde yönetin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _SettingsTabBar extends StatelessWidget {
  const _SettingsTabBar({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppUiTokens.border),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppUiTokens.textPrimary,
        unselectedLabelColor: AppUiTokens.textSecondary,
        indicatorColor: ColorName.primary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: AppUiTokens.space16,
        ),
        tabs: const [
          Tab(text: 'Hesap'),
          Tab(text: 'Veri'),
          Tab(text: 'Teklif PDF'),
          Tab(text: 'Yasal Metinler'),
        ],
      ),
    );
  }
}

class _HesapTabContent extends StatelessWidget {
  const _HesapTabContent({
    required this.controller,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onSubmitPassword,
  });

  final SettingsController controller;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmitPassword;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumn = constraints.maxWidth >= _twoColumnBreakpoint;

        final passwordCard = _PasswordChangeCard(
          controller: controller,
          oldPasswordController: oldPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          onSubmit: onSubmitPassword,
        );
        const aboutCard = _AboutCard(compact: true);

        return SingleChildScrollView(
          child: useTwoColumn
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: _leftColumnFlex, child: passwordCard),
                    const SizedBox(width: AppUiTokens.space24),
                    const Expanded(flex: _rightColumnFlex, child: aboutCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    passwordCard,
                    const SizedBox(height: AppUiTokens.space24),
                    aboutCard,
                  ],
                ),
        );
      },
    );
  }
}

class _VeriTabContent extends StatelessWidget {
  const _VeriTabContent({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _DatabaseOperationsCard(controller: controller),
    );
  }
}

class _SettingsSubHeader extends StatelessWidget {
  const _SettingsSubHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppUiTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsCardHeader extends StatelessWidget {
  const _SettingsCardHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _PasswordChangeCard extends StatelessWidget {
  const _PasswordChangeCard({
    required this.controller,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  final SettingsController controller;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SettingsCardHeader(
            title: 'Şifre Değiştir',
            description: 'Hesap güvenliğiniz için yeni bir şifre belirleyin.',
          ),
          const SizedBox(height: AppUiTokens.space24),
          Obx(
            () {
              final obscureOld = controller.obscureOldPassword.value;
              final obscureNew = controller.obscureNewPassword.value;
              final obscureConfirm = controller.obscureConfirmPassword.value;
              final isBusy = _isSettingsBusy(controller);
              final isChangingPassword = controller.isChangingPassword.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PanelPasswordField(
                    controller: oldPasswordController,
                    label: 'Mevcut şifre',
                    obscureText: obscureOld,
                    onToggleVisibility: controller.obscureOldPassword.toggle,
                  ),
                  const SizedBox(height: AppUiTokens.space16),
                  PanelPasswordField(
                    controller: newPasswordController,
                    label: 'Yeni şifre',
                    obscureText: obscureNew,
                    onToggleVisibility: controller.obscureNewPassword.toggle,
                  ),
                  const SizedBox(height: AppUiTokens.space16),
                  PanelPasswordField(
                    controller: confirmPasswordController,
                    label: 'Yeni şifre tekrar',
                    obscureText: obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSubmit(),
                    onToggleVisibility:
                        controller.obscureConfirmPassword.toggle,
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  Text(
                    PasswordValidationMessages.rulesInfo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppUiTokens.textMuted,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: AppUiTokens.space24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 200,
                      child: PanelPrimaryButton(
                        label: 'Şifreyi Değiştir',
                        isLoading: isChangingPassword,
                        onPressed: isBusy ? null : onSubmit,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DatabaseOperationsCard extends StatelessWidget {
  const _DatabaseOperationsCard({required this.controller});

  final SettingsController controller;

  static const _compactActionsMaxWidth = 360.0;
  static const _inlineActionsBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsCardHeader(
            title: 'Veritabanı İşlemleri',
            description:
                'Verilerinizi yedekleyebilir veya daha önce alınmış bir yedeği geri yükleyebilirsiniz.',
          ),
          const SizedBox(height: AppUiTokens.space24),
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(
              () {
                final isBusy = _isSettingsBusy(controller);
                final isBackingUp = controller.isBackingUp.value;
                final isRestoring = controller.isRestoring.value;

                final backupButton = _SettingsActionButton(
                  label: 'Yedek Al',
                  icon: Icons.save_outlined,
                  isLoading: isBackingUp,
                  onPressed: isBusy ? null : controller.backupDatabase,
                );
                final restoreButton = _SettingsActionButton(
                  label: 'Yedekten Geri Yükle',
                  icon: Icons.restore_outlined,
                  isLoading: isRestoring,
                  isDestructive: true,
                  onPressed: isBusy ? null : controller.restoreDatabase,
                );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final useInlineActions =
                        constraints.maxWidth >= _inlineActionsBreakpoint;

                    if (useInlineActions) {
                      return Wrap(
                        spacing: AppUiTokens.space12,
                        runSpacing: AppUiTokens.space12,
                        children: [
                          backupButton,
                          restoreButton,
                        ],
                      );
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _compactActionsMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          backupButton,
                          const SizedBox(height: AppUiTokens.space12),
                          restoreButton,
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionButton extends StatelessWidget {
  const _SettingsActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isDestructive ? ColorName.error : AppUiTokens.textPrimary;
    final borderColor =
        isDestructive ? const Color(0xFFFECACA) : AppUiTokens.border;
    final backgroundColor =
        isDestructive ? const Color(0xFFFEF2F2) : AppUiTokens.surface;

    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: AppInteractiveTheme.outlinedButtonStyle(
          OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            padding:
                const EdgeInsets.symmetric(horizontal: AppUiTokens.space16),
            minimumSize: const Size(0, 44),
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            ),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SettingsCardHeader(
            title: 'Hakkında',
            description: 'Uygulama ve veri saklama bilgileri.',
          ),
          SizedBox(height: compact ? AppUiTokens.space16 : AppUiTokens.space24),
          _AboutRow(
            label: 'Uygulama adı',
            value: 'Ok Teknik Metal CRM',
            compact: compact,
          ),
          _AboutDivider(compact: compact),
          _AboutRow(label: 'Versiyon', value: '1.0.0', compact: compact),
          _AboutDivider(compact: compact),
          _AboutRow(
            label: 'Sistem tipi',
            value: 'Local Desktop CRM',
            compact: compact,
          ),
          _AboutDivider(compact: compact),
          _AboutRow(
            label: 'Veri saklama',
            value: 'Veriler bu bilgisayarda saklanır.',
            compact: compact,
          ),
          _AboutDivider(compact: compact),
          _AboutDeveloperRow(compact: compact),
        ],
      ),
    );
  }
}

class _AboutDivider extends StatelessWidget {
  const _AboutDivider({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppUiTokens.space8 : AppUiTokens.space12,
      ),
      child: const Divider(height: 1, color: AppUiTokens.border),
    );
  }
}

class _AboutDeveloperRow extends StatelessWidget {
  const _AboutDeveloperRow({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final developer = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.icons.meonsLogo.svg(
          width: 28,
          height: 28,
          package: 'gen',
        ),
        const SizedBox(width: AppUiTokens.space8),
        Text(
          'Meons',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geliştirici',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppUiTokens.textMuted,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppUiTokens.space4),
          developer,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            'Geliştirici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppUiTokens.textSecondary,
                ),
          ),
        ),
        Expanded(child: developer),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppUiTokens.textMuted,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppUiTokens.space4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppUiTokens.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppUiTokens.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppUiTokens.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackMessages extends StatelessWidget {
  const _FeedbackMessages({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.errorMessage.value;
      final success = controller.successMessage.value;

      if (error == null && success == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (success != null)
            PanelMessage(message: success, type: PanelMessageType.info),
          if (error != null && success != null)
            const SizedBox(height: AppUiTokens.space12),
          if (error != null) PanelMessage(message: error),
        ],
      );
    });
  }
}

class _OfferPdfSettingsCard extends StatefulWidget {
  const _OfferPdfSettingsCard({required this.controller});

  final SettingsController controller;

  @override
  State<_OfferPdfSettingsCard> createState() => _OfferPdfSettingsCardState();
}

class _OfferPdfSettingsCardState extends State<_OfferPdfSettingsCard> {
  late final TextEditingController _supplierCompanyNameController;
  late final TextEditingController _supplierContactPersonController;
  late final TextEditingController _supplierPhoneController;
  late final TextEditingController _supplierMobilePhoneController;
  late final TextEditingController _companyLegalNameController;
  late final TextEditingController _companyAddressController;
  late final TextEditingController _companyTaxInfoController;
  late final TextEditingController _companyTradeRegistryController;
  late final TextEditingController _companyEmail1Controller;
  late final TextEditingController _companyEmail2Controller;
  late final TextEditingController _companyTelController;
  late final TextEditingController _companyFaxController;
  Worker? _settingsWorker;

  @override
  void initState() {
    super.initState();
    _supplierCompanyNameController = TextEditingController();
    _supplierContactPersonController = TextEditingController();
    _supplierPhoneController = TextEditingController();
    _supplierMobilePhoneController = TextEditingController();
    _companyLegalNameController = TextEditingController();
    _companyAddressController = TextEditingController();
    _companyTaxInfoController = TextEditingController();
    _companyTradeRegistryController = TextEditingController();
    _companyEmail1Controller = TextEditingController();
    _companyEmail2Controller = TextEditingController();
    _companyTelController = TextEditingController();
    _companyFaxController = TextEditingController();

    _settingsWorker = ever<OfferPdfSettings?>(
      widget.controller.pdfSettings,
      (settings) {
        if (settings != null) {
          _applySettingsToControllers(settings);
        }
      },
    );

    final current = widget.controller.pdfSettings.value;
    if (current != null) {
      _applySettingsToControllers(current);
    }
  }

  void _applySettingsToControllers(OfferPdfSettings settings) {
    _supplierCompanyNameController.text = settings.supplierCompanyName;
    _supplierContactPersonController.text = settings.supplierContactPerson;
    _supplierPhoneController.text = settings.supplierPhone;
    _supplierMobilePhoneController.text = settings.supplierMobilePhone;
    _companyLegalNameController.text = settings.companyLegalName;
    _companyAddressController.text = settings.companyAddress;
    _companyTaxInfoController.text = settings.companyTaxInfo;
    _companyTradeRegistryController.text = settings.companyTradeRegistry;
    _companyEmail1Controller.text = settings.companyEmail1;
    _companyEmail2Controller.text = settings.companyEmail2;
    _companyTelController.text = settings.companyTel;
    _companyFaxController.text = settings.companyFax;
  }

  @override
  void dispose() {
    _settingsWorker?.dispose();
    _supplierCompanyNameController.dispose();
    _supplierContactPersonController.dispose();
    _supplierPhoneController.dispose();
    _supplierMobilePhoneController.dispose();
    _companyLegalNameController.dispose();
    _companyAddressController.dispose();
    _companyTaxInfoController.dispose();
    _companyTradeRegistryController.dispose();
    _companyEmail1Controller.dispose();
    _companyEmail2Controller.dispose();
    _companyTelController.dispose();
    _companyFaxController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.controller.savePdfSettings(
      OfferPdfSettings(
        supplierCompanyName: _supplierCompanyNameController.text.trim(),
        supplierContactPerson: _supplierContactPersonController.text.trim(),
        supplierPhone: _supplierPhoneController.text.trim(),
        supplierMobilePhone: _supplierMobilePhoneController.text.trim(),
        companyLegalName: _companyLegalNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        companyTaxInfo: _companyTaxInfoController.text.trim(),
        companyTradeRegistry: _companyTradeRegistryController.text.trim(),
        companyEmail1: _companyEmail1Controller.text.trim(),
        companyEmail2: _companyEmail2Controller.text.trim(),
        companyTel: _companyTelController.text.trim(),
        companyFax: _companyFaxController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PanelSurface(
        padding: const EdgeInsets.all(AppUiTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SettingsCardHeader(
              title: 'Teklif PDF Bilgileri',
              description:
                  'PDF teklif formunda görünen tedarikçi ve şirket alt bilgilerini düzenleyin.',
            ),
            const SizedBox(height: AppUiTokens.space24),
            Obx(() {
              if (widget.controller.isLoadingPdfSettings.value &&
                  widget.controller.pdfSettings.value == null) {
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final isBusy = _isSettingsBusy(widget.controller);
              final isSaving = widget.controller.isSavingPdfSettings.value;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumn = constraints.maxWidth >= 720;

                  Widget buildFieldGroup({
                    required String title,
                    required List<Widget> fields,
                  }) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SettingsSubHeader(title: title),
                        ...fields,
                      ],
                    );
                  }

                  Widget spacedField(PanelTextField field) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppUiTokens.space16,
                      ),
                      child: field,
                    );
                  }

                  final supplierGroup = buildFieldGroup(
                    title: 'Tedarikçi bilgileri',
                    fields: [
                      spacedField(
                        PanelTextField(
                          controller: _supplierCompanyNameController,
                          label: 'Tedarikçi firma adı',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _supplierContactPersonController,
                          label: 'Tedarikçi ilgili kişi',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _supplierPhoneController,
                          label: 'Tedarikçi telefon',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _supplierMobilePhoneController,
                          label: 'Tedarikçi cep telefonu',
                        ),
                      ),
                    ],
                  );

                  final companyGroup = buildFieldGroup(
                    title: 'Firma bilgileri',
                    fields: [
                      spacedField(
                        PanelTextField(
                          controller: _companyLegalNameController,
                          label: 'Şirket unvanı',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _companyAddressController,
                          label: 'Adres',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _companyTaxInfoController,
                          label: 'Vergi dairesi / vergi no',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _companyTradeRegistryController,
                          label: 'Ticaret sicil no',
                        ),
                      ),
                    ],
                  );

                  final contactGroup = buildFieldGroup(
                    title: 'İletişim',
                    fields: [
                      spacedField(
                        PanelTextField(
                          controller: _companyEmail1Controller,
                          label: 'E-posta 1',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _companyEmail2Controller,
                          label: 'E-posta 2',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _companyTelController,
                          label: 'Telefon',
                        ),
                      ),
                      spacedField(
                        PanelTextField(
                          controller: _companyFaxController,
                          label: 'Faks',
                        ),
                      ),
                    ],
                  );

                  final fields = useTwoColumn
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  supplierGroup,
                                  const SizedBox(height: AppUiTokens.space8),
                                  companyGroup,
                                ],
                              ),
                            ),
                            const SizedBox(width: AppUiTokens.space24),
                            Expanded(child: contactGroup),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            supplierGroup,
                            const SizedBox(height: AppUiTokens.space8),
                            companyGroup,
                            const SizedBox(height: AppUiTokens.space8),
                            contactGroup,
                          ],
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      fields,
                      const SizedBox(height: AppUiTokens.space8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 200,
                          child: PanelPrimaryButton(
                            label: 'Kaydet',
                            isLoading: isSaving,
                            onPressed: isBusy ? null : _save,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LegalTextTemplatesCard extends StatefulWidget {
  const _LegalTextTemplatesCard({required this.controller});

  final SettingsController controller;

  @override
  State<_LegalTextTemplatesCard> createState() =>
      _LegalTextTemplatesCardState();
}

class _LegalTextTemplatesCardState extends State<_LegalTextTemplatesCard> {
  late final TextEditingController _contentController;
  Worker? _typeWorker;
  Worker? _templatesWorker;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();

    _typeWorker = ever<OfferType>(
      widget.controller.selectedLegalTemplateType,
      (_) => _syncContentFromSelectedType(),
    );
    _templatesWorker = ever(
      widget.controller.legalTemplates,
      (_) => _syncContentFromSelectedType(),
    );

    _syncContentFromSelectedType();
  }

  void _syncContentFromSelectedType() {
    final type = widget.controller.selectedLegalTemplateType.value;
    final content = widget.controller.legalTemplates[type] ?? '';
    _contentController.text = content;
  }

  @override
  void dispose() {
    _typeWorker?.dispose();
    _templatesWorker?.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.controller.saveLegalTemplate(
      type: widget.controller.selectedLegalTemplateType.value,
      content: _contentController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PanelSurface(
        padding: const EdgeInsets.all(AppUiTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SettingsCardHeader(
              title: 'Yasal Metin Şablonları',
              description:
                  'Yeni tekliflerde otomatik doldurulacak yasal metin şablonlarını düzenleyin. Mevcut tekliflerdeki kayıtlı metinler değişmez.',
            ),
            const SizedBox(height: AppUiTokens.space24),
            Obx(() {
              if (widget.controller.isLoadingLegalTemplates.value &&
                  widget.controller.legalTemplates.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final isBusy = _isSettingsBusy(widget.controller);
              final isSaving = widget.controller.isSavingLegalTemplate.value;
              final selectedType =
                  widget.controller.selectedLegalTemplateType.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: AppUiTokens.space8,
                    runSpacing: AppUiTokens.space8,
                    children: [
                      for (final type in OfferType.values)
                        ChoiceChip(
                          label: Text(type.label),
                          selected: selectedType == type,
                          showCheckmark: false,
                          side: BorderSide(
                            color: selectedType == type
                                ? ColorName.primary
                                : AppUiTokens.border,
                          ),
                          backgroundColor: AppUiTokens.surface,
                          selectedColor: AppUiTokens.accentSoft,
                          labelStyle: TextStyle(
                            color: selectedType == type
                                ? AppUiTokens.textPrimary
                                : AppUiTokens.textSecondary,
                            fontWeight: selectedType == type
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                          onSelected: isBusy
                              ? null
                              : (_) {
                                  widget.controller
                                      .selectLegalTemplateType(type);
                                },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppUiTokens.space16),
                  PanelTextField(
                    controller: _contentController,
                    label: 'Yasal metin',
                    minLines: 6,
                    maxLines: 12,
                  ),
                  const SizedBox(height: AppUiTokens.space24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 200,
                      child: PanelPrimaryButton(
                        label: 'Kaydet',
                        isLoading: isSaving,
                        onPressed: isBusy ? null : _save,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
