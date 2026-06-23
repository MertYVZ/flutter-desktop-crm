import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/feature/price_list/widgets/price_list_products_table.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/price_list_messages.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:Ok/product/widgets/status_badge_styles.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

const _detailMaxWidth = 1200.0;

final class PriceListDetailPage extends StatefulWidget {
  const PriceListDetailPage({super.key});

  @override
  State<PriceListDetailPage> createState() => _PriceListDetailPageState();
}

class _PriceListDetailPageState extends BaseState<PriceListDetailPage> {
  String get _priceListId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceListController>(
      viewModel: Get.find<PriceListController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..getPriceListById(_priceListId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedPriceList.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final list = controller.selectedPriceList.value;
          if (list == null) {
            return Center(
              child: AppEmptyState(
                message: controller.errorMessage.value ?? PriceListMessages.notFound,
                icon: Icons.search_off_outlined,
              ),
            );
          }

          final isActive = list.status == PriceListStatus.active.value;
          final priceListStatus = PriceListStatusX.fromValue(list.status);

          return Align(
            alignment: Alignment.topLeft,
            child: PanelFormScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _detailMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PageHeader(
                      title: list.title,
                      subtitle: 'Fiyat listesi detayları',
                      onBack: () => Get.offNamed<void>(AppRoutes.priceList.value),
                      onEdit: isActive
                          ? () => Get.toNamed<void>(
                                AppRoutes.priceListEdit.pathForId(list.id),
                              )
                          : null,
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    Obx(() {
                      final error = controller.errorMessage.value;
                      final success = controller.successMessage.value;

                      if (error == null && success == null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Geçerlilik Tarihi',
                            value: AppDateUtils.formatDate(list.effectiveDate),
                          ),
                          const SizedBox(height: AppUiTokens.space12),
                          _InfoRow(
                            label: 'Durum',
                            value: priceListStatus?.label ?? list.status,
                            valueWidget: priceListStatus == null
                                ? null
                                : AppStatusBadge(
                                    label: priceListStatus.label,
                                    style: priceListStatus.badgeStyle,
                                    compact: true,
                                  ),
                          ),
                          if (list.archivedAt != null) ...[
                            const SizedBox(height: AppUiTokens.space12),
                            _InfoRow(
                              label: 'Arşiv Tarihi',
                              value: AppDateUtils.formatDate(list.archivedAt!),
                            ),
                          ],
                          if (list.description != null &&
                              list.description!.isNotEmpty) ...[
                            const SizedBox(height: AppUiTokens.space12),
                            _InfoRow(
                              label: 'Açıklama',
                              value: list.description!,
                            ),
                          ],
                          const SizedBox(height: AppUiTokens.space12),
                          _InfoRow(
                            label: 'Oluşturulma',
                            value: AppDateUtils.formatDateTime(list.createdAt),
                          ),
                          const SizedBox(height: AppUiTokens.space12),
                          _InfoRow(
                            label: 'Güncellenme',
                            value: AppDateUtils.formatDateTime(list.updatedAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    Text(
                      'Ürünler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppUiTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppUiTokens.space12),
                    PanelSurface(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                      child: PriceListProductsTable(
                        controller: controller,
                        items: controller.selectedItems.toList(),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
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
    this.onEdit,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          style: AppInteractiveTheme.iconButtonStyle(
            IconButton.styleFrom(foregroundColor: AppUiTokens.textSecondary),
          ),
        ),
        const SizedBox(width: AppUiTokens.space8),
        Expanded(
          child: Column(
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
          ),
        ),
        if (onEdit != null)
          FilledButton.icon(
            onPressed: onEdit,
            style: AppInteractiveTheme.filledButtonStyle(
              FilledButton.styleFrom(
                backgroundColor: ColorName.primary,
                foregroundColor: Colors.white,
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Düzenle'),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppUiTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textPrimary,
                  ),
            ),
          ),
      ],
    );
  }
}
