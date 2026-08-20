import 'package:Ok/feature/export/models/export_currency.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/import/controllers/import_controller.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/import_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _twoColumnBreakpoint = 800.0;

final class ImportDetailPage extends StatefulWidget {
  const ImportDetailPage({super.key});

  @override
  State<ImportDetailPage> createState() => _ImportDetailPageState();
}

class _ImportDetailPageState extends BaseState<ImportDetailPage> {
  String get _recordId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<ImportController>(
      viewModel: Get.find<ImportController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..getImportById(_recordId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedImport.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final detail = controller.selectedImport.value;
          if (detail == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ImportMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          final record = detail.record;
          final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');
          final currency = detail.currency;
          final totals = ExportTotals.fromItems(
            items: detail.items,
            logisticsCostMinor: record.logisticsCostMinor ?? 0,
            customsCostMinor: record.customsCostMinor ?? 0,
            insuranceCostMinor: record.insuranceCostMinor ?? 0,
          );

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageHeader(
                  title: record.title,
                  subtitle: 'İthalat kayıt detayları',
                  onBack: () => Get.offNamed<void>(AppRoutes.imports.value),
                  onEdit: () => Get.toNamed<void>(
                    AppRoutes.importsEdit.pathForId(record.id),
                  ),
                  onDelete: controller.isDeleting.value
                      ? null
                      : () async {
                          final deleted =
                              await controller.deleteImport(record.id);
                          if (deleted) {
                            await Get.offNamed<void>(
                              AppRoutes.imports.value,
                            );
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
                _DetailGroup(
                  title: 'Genel',
                  icon: Icons.info_outline_rounded,
                  children: [
                    _InfoField(label: 'Başlık', value: record.title),
                    _InfoField(
                      label: 'Tedarikçi',
                      value: _text(record.supplierName),
                    ),
                    _InfoField(
                      label: 'Para birimi',
                      value: currency.label,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppUiTokens.space16),
                _DetailGroup(
                  title: 'Ürün ve fiyat',
                  icon: Icons.inventory_2_outlined,
                  children: [
                    _ImportItemsTable(
                      items: detail.items,
                      currency: currency,
                    ),
                  ],
                ),
                const SizedBox(height: AppUiTokens.space16),
                _DetailGroup(
                  title: 'Tutar özeti',
                  icon: Icons.payments_outlined,
                  children: [
                    _InfoField(
                      label: 'Gönderilen toplam',
                      value: _amount(totals.sentTotalMinor, currency),
                    ),
                    _InfoField(
                      label: 'Firesiz toplam',
                      value: _amount(totals.afterWasteMinor, currency),
                    ),
                    _InfoField(
                      label: 'Net toplam',
                      value: _amount(totals.netTotalMinor, currency),
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppUiTokens.space16),
                LayoutBuilder(
                  builder: (context, bodyConstraints) {
                    final isCompact =
                        bodyConstraints.maxWidth < _twoColumnBreakpoint;

                    final leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NotesGroup(notes: record.notes),
                      ],
                    );

                    final rightColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DetailGroup(
                          title: 'Lojistik',
                          icon: Icons.local_shipping_outlined,
                          children: [
                            _InfoField(
                              label: 'Sevkiyat tarihi',
                              value: _date(record.shipmentDate),
                            ),
                            _InfoField(
                              label: 'Teslimat tarihi',
                              value: _date(record.deliveryDate),
                            ),
                            _InfoField(
                              label: 'Lojistik (firma / kişi)',
                              value: _text(record.logisticsName),
                            ),
                            _InfoField(
                              label: 'Lojistik masrafı',
                              value: _amount(
                                record.logisticsCostMinor,
                                currency,
                              ),
                            ),
                            _InfoField(
                              label: 'Gümrük masrafı',
                              value: _amount(record.customsCostMinor, currency),
                            ),
                            _InfoField(
                              label: 'Sigorta masrafı',
                              value: _amount(
                                record.insuranceCostMinor,
                                currency,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppUiTokens.space16),
                        _DetailGroup(
                          title: 'Kayıt bilgileri',
                          icon: Icons.schedule_outlined,
                          children: [
                            _InfoField(
                              label: 'Oluşturulma tarihi',
                              value: dateTimeFormat.format(record.createdAt),
                            ),
                            _InfoField(
                              label: 'Güncellenme tarihi',
                              value: dateTimeFormat.format(record.updatedAt),
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          leftColumn,
                          const SizedBox(height: AppUiTokens.space16),
                          rightColumn,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leftColumn),
                        const SizedBox(width: AppUiTokens.space24),
                        Expanded(child: rightColumn),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  String _text(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '—' : trimmed;
  }

  String _date(DateTime? value) =>
      value == null ? '—' : AppDateUtils.formatDate(value);

  String _amount(int? value, PriceOfferCurrencyType currency) => value == null
      ? '—'
      : MoneyUtils.formatAmountMinor(value, mapExportCurrency(currency));
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

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppUiTokens.textSecondary),
              const SizedBox(width: AppUiTokens.space8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppUiTokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppUiTokens.space24),
          ...children,
        ],
      ),
    );
  }
}

class _NotesGroup extends StatelessWidget {
  const _NotesGroup({required this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    final hasNotes = notes != null && notes!.trim().isNotEmpty;

    return _DetailGroup(
      title: 'Notlar',
      icon: Icons.notes_outlined,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppUiTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
            border: Border.all(color: AppUiTokens.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppUiTokens.space16),
            child: hasNotes
                ? SelectableText(
                    notes!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppUiTokens.textPrimary,
                          height: 1.6,
                        ),
                  )
                : Text(
                    'Not eklenmemiş.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppUiTokens.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ImportItemsTable extends StatelessWidget {
  const _ImportItemsTable({
    required this.items,
    required this.currency,
  });

  final List<ExportItemData> items;
  final PriceOfferCurrencyType currency;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        '—',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppUiTokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(
          color: AppUiTokens.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(
          color: AppUiTokens.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        columns: const [
          DataColumn(label: Text('Ürün')),
          DataColumn(label: Text('Birim')),
          DataColumn(label: Text('Gönderilen')),
          DataColumn(label: Text('Birim fiyat')),
          DataColumn(label: Text('Satır toplamı')),
          DataColumn(label: Text('Fire')),
          DataColumn(label: Text('Fire tutarı')),
        ],
        rows: items
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.productName)),
                  DataCell(Text(item.unitType)),
                  DataCell(Text(QuantityUtils.formatQuantity(item.quantity))),
                  DataCell(
                    Text(
                      MoneyUtils.formatAmountMinor(
                        item.priceMinor,
                        mapExportCurrency(currency),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      MoneyUtils.formatAmountMinor(
                        item.sentTotalMinor,
                        mapExportCurrency(currency),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.wasteQuantity <= 0
                          ? '—'
                          : '${QuantityUtils.formatQuantity(item.wasteQuantity)} ${item.wasteUnitType ?? item.unitType}',
                    ),
                  ),
                  DataCell(
                    Text(
                      item.wasteQuantity <= 0
                          ? '—'
                          : MoneyUtils.formatAmountMinor(
                              item.wasteTotalMinor,
                              mapExportCurrency(currency),
                            ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    this.value,
    this.child,
    this.isLast = false,
  }) : assert(
          value != null || child != null,
          'Either value or child must be provided',
        );

  final String label;
  final String? value;
  final Widget? child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppUiTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: AppUiTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppUiTokens.space4),
          if (child != null)
            child!
          else
            Text(
              value!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
