import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends BaseState<CustomerDetailPage> {
  String get _customerId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomersController>(
      viewModel: Get.find<CustomersController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..getCustomerById(_customerId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isDetailLoading.value &&
              controller.selectedCustomer.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final customer = controller.selectedCustomer.value;
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

          final type = CustomerTypeX.fromValue(customer.type);
          final status = CustomerStatusX.fromValue(customer.status);
          final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageHeader(
                  title: customer.name,
                  subtitle: 'Müşteri kayıt detayları',
                  onBack: () => Get.offNamed<void>(AppRoutes.customers.value),
                  onEdit: () => Get.toNamed<void>(
                    AppRoutes.customersEdit.pathForId(customer.id),
                  ),
                  onDelete: controller.isDeleting.value
                      ? null
                      : () async {
                          final deleted =
                              await controller.deleteCustomer(customer.id);
                          if (deleted) {
                            Get.offNamed<void>(AppRoutes.customers.value);
                          }
                        },
                  isDeleting: controller.isDeleting.value,
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
                PanelSurface(
                  padding: const EdgeInsets.all(AppUiTokens.space24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 800;

                      final left = [
                        _DetailRow(label: 'Müşteri adı', value: customer.name),
                        _DetailRow(
                          label: 'Müşteri tipi',
                          value: type?.label ?? '-',
                        ),
                        _DetailRow(
                          label: 'Telefon',
                          value: customer.phone ?? '-',
                        ),
                        _DetailRow(
                          label: 'E-posta',
                          value: customer.email ?? '-',
                        ),
                      ];

                      final right = [
                        _DetailRow(label: 'Şehir', value: customer.city ?? '-'),
                        _DetailRow(
                          label: 'Ülke',
                          value: customer.country ?? '-',
                        ),
                        _DetailRow(
                          label: 'Adres',
                          value: customer.address ?? '-',
                        ),
                        _DetailRow(
                          label: 'Durum',
                          value: status?.label ?? '-',
                        ),
                        _DetailRow(
                          label: 'Oluşturulma tarihi',
                          value: dateFormat.format(customer.createdAt),
                        ),
                        _DetailRow(
                          label: 'Güncellenme tarihi',
                          value: dateFormat.format(customer.updatedAt),
                        ),
                      ];

                      if (isCompact) {
                        return Column(
                          children: [
                            ...left,
                            ...right,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Column(children: left)),
                          const SizedBox(width: AppUiTokens.space24),
                          Expanded(child: Column(children: right)),
                        ],
                      );
                    },
                  ),
                ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
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
      ),
    );
  }
}
