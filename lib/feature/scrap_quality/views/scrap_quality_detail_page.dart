import 'dart:async';

import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_lost_reason.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_sales_status_badge.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class ScrapQualityDetailPage extends StatefulWidget {
  const ScrapQualityDetailPage({super.key});

  @override
  State<ScrapQualityDetailPage> createState() => _ScrapQualityDetailPageState();
}

class _ScrapQualityDetailPageState extends BaseState<ScrapQualityDetailPage> {
  String get _recordId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<ScrapQualityController>(
      viewModel: Get.find<ScrapQualityController>(),
      onModelReady: (controller) {
        controller.loadCustomersForDropdown();
        unawaited(controller.getRecordById(_recordId));
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedRecord.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final record = controller.selectedRecord.value;
          if (record == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ScrapQualityMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          final customerName = _resolveCustomerName(controller, record);
          final salesStatus = ScrapSalesStatusX.fromValue(record.salesStatus);
          final lostReason = _resolveLostReasonLabel(record.lostReason);

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageHeader(
                  title: customerName,
                  subtitle: record.quality,
                  onBack: () => Get.offNamed<void>(AppRoutes.scrapQuality.value),
                  onEdit: () => Get.toNamed<void>(
                    AppRoutes.scrapQualityEdit.pathForId(record.id),
                  ),
                ),
                const SizedBox(height: AppUiTokens.space16),
                PanelSurface(
                  padding: const EdgeInsets.all(AppUiTokens.space24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 760;
                      final fields = [
                        _DetailField(
                          label: 'Müşteri',
                          child: InkWell(
                            onTap: () => Get.toNamed<void>(
                              AppRoutes.customersDetail
                                  .pathForId(record.customerId),
                            ),
                            child: Text(
                              customerName,
                              style: const TextStyle(
                                color: ColorName.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        _DetailField(
                          label: 'Miktar / Birim',
                          value:
                              '${QuantityUtils.formatQuantity(record.quantity)} ${record.unit}',
                        ),
                        _DetailField(
                          label: 'KG Karşılığı',
                          value: QuantityUtils.formatKg(record.quantityKg),
                        ),
                        _DetailField(
                          label: 'Hurda Türü / Kalite',
                          value: record.quality,
                        ),
                        _DetailField(
                          label: 'Tarih',
                          value: AppDateUtils.formatDate(record.recordDate),
                        ),
                        _DetailField(
                          label: 'İl',
                          value: record.city ?? '—',
                        ),
                        _DetailField(
                          label: 'Satış Durumu',
                          child: ScrapSalesStatusBadge(status: salesStatus),
                        ),
                        _DetailField(
                          label: 'Teklif Fiyatı',
                          value: record.offerPrice == null
                              ? '—'
                              : '${MoneyUtils.formatAmountInput(record.offerPrice!)} TL/KG',
                        ),
                        _DetailField(
                          label: 'Hedef Fiyat',
                          value: record.targetPrice == null
                              ? '—'
                              : '${MoneyUtils.formatAmountInput(record.targetPrice!)} TL/KG',
                        ),
                        _DetailField(
                          label: 'Alınmama Nedeni',
                          value: lostReason ?? '—',
                        ),
                        _DetailField(
                          label: 'Takip Tarihi',
                          value: record.followUpDate == null
                              ? '—'
                              : AppDateUtils.formatDate(record.followUpDate!),
                        ),
                        _DetailField(
                          label: 'Notlar',
                          value: record.note ?? '—',
                        ),
                        _DetailField(
                          label: 'Oluşturulma',
                          value: AppDateUtils.formatDateTime(record.createdAt),
                        ),
                        _DetailField(
                          label: 'Güncellenme',
                          value: AppDateUtils.formatDateTime(record.updatedAt),
                        ),
                      ];

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final field in fields) ...[
                              field,
                              if (field != fields.last)
                                const SizedBox(height: AppUiTokens.space16),
                            ],
                          ],
                        );
                      }

                      return Wrap(
                        spacing: AppUiTokens.space24,
                        runSpacing: AppUiTokens.space16,
                        children: fields
                            .map(
                              (field) => SizedBox(
                                width: (constraints.maxWidth -
                                        AppUiTokens.space24) /
                                    2,
                                child: field,
                              ),
                            )
                            .toList(),
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

  String _resolveCustomerName(
    ScrapQualityController controller,
    ScrapQualityRecord record,
  ) {
    for (final customer in controller.customers) {
      if (customer.id == record.customerId) {
        return customer.name;
      }
    }

    return record.customerNameSnapshot ?? 'Müşteri';
  }

  String? _resolveLostReasonLabel(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return ScrapLostReasonX.fromValue(value)?.label ?? value;
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        OutlinedButton(
          onPressed: onBack,
          style: AppInteractiveTheme.outlinedButtonStyle(
            OutlinedButton.styleFrom(
              side: const BorderSide(color: AppUiTokens.border),
            ),
          ),
          child: const Text('Geri'),
        ),
        const SizedBox(width: AppUiTokens.space8),
        FilledButton(
          onPressed: onEdit,
          style: AppInteractiveTheme.filledButtonStyle(
            FilledButton.styleFrom(
              backgroundColor: ColorName.primary,
              foregroundColor: Colors.white,
            ),
          ),
          child: const Text('Düzenle'),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    this.value,
    this.child,
  });

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppUiTokens.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space4),
        child ??
            Text(
              value ?? '—',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
      ],
    );
  }
}
