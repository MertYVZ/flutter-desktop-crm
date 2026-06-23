import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_detail_sections.dart';
import 'package:Ok/feature/customers/widgets/customer_info_card.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends BaseState<CustomerDetailPage> {
  String get _customerId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerDetailController>(
      viewModel: Get.find<CustomerDetailController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..loadCustomer(_customerId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoadingCustomer.value &&
              controller.customer.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final customer = controller.customer.value;
          if (customer == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? CustomerMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageHeader(
                  title: customer.name,
                  subtitle: 'Müşteri 360° detay görünümü',
                  onBack: () => Get.offNamed<void>(AppRoutes.customers.value),
                  onEdit: () => Get.toNamed<void>(
                    AppRoutes.customersEdit.pathForId(customer.id),
                  ),
                  onDelete: controller.isDeletingCustomer.value
                      ? null
                      : () async {
                          final deleted = await controller.deleteCustomer();
                          if (deleted) {
                            Get.offNamed<void>(AppRoutes.customers.value);
                          }
                        },
                  isDeleting: controller.isDeletingCustomer.value,
                ),
                const SizedBox(height: AppUiTokens.space16),
                Obx(() {
                  final error = controller.errorMessage.value;
                  final success = controller.successMessage.value;

                  if (error == null && success == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      if (success != null)
                        PanelMessage(
                          message: success,
                          type: PanelMessageType.info,
                        ),
                      if (error != null && success != null)
                        const SizedBox(height: AppUiTokens.space12),
                      if (error != null) PanelMessage(message: error),
                      const SizedBox(height: AppUiTokens.space16),
                    ],
                  );
                }),
                CustomerInfoCard(customer: customer),
                const SizedBox(height: AppUiTokens.space24),
                CustomerDetailSections(controller: controller),
              ],
            ),
          );
        });
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppUiTokens.space8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: AppUiTokens.space8,
          runSpacing: AppUiTokens.space8,
          children: [
            _HeaderButton(
              label: 'Geri Dön',
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
            _HeaderButton(
              label: 'Düzenle',
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
            _HeaderButton(
              label: 'Sil',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              isLoading: isDeleting,
              onPressed: onDelete,
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              const SizedBox(height: AppUiTokens.space16),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            actions,
          ],
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isLoading;

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
            side: BorderSide(color: borderColor),
            padding:
                const EdgeInsets.symmetric(horizontal: AppUiTokens.space16),
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
