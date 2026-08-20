import 'package:Ok/feature/export/models/export_currency.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/export/widgets/export_items_editor.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ImportRecordForm extends StatelessWidget {
  const ImportRecordForm({
    required this.titleController,
    required this.supplierNameController,
    required this.itemRows,
    required this.currency,
    required this.logisticsNameController,
    required this.shipmentDate,
    required this.deliveryDate,
    required this.logisticsCostController,
    required this.customsCostController,
    required this.insuranceCostController,
    required this.notesController,
    required this.onCurrencyChanged,
    required this.onItemsChanged,
    required this.onShipmentDateChanged,
    required this.onDeliveryDateChanged,
    required this.onTotalsChanged,
    super.key,
  });

  final TextEditingController titleController;
  final TextEditingController supplierNameController;
  final List<ExportItemFormRow> itemRows;
  final PriceOfferCurrencyType currency;
  final TextEditingController logisticsNameController;
  final DateTime? shipmentDate;
  final DateTime? deliveryDate;
  final TextEditingController logisticsCostController;
  final TextEditingController customsCostController;
  final TextEditingController insuranceCostController;
  final TextEditingController notesController;
  final ValueChanged<PriceOfferCurrencyType?> onCurrencyChanged;
  final VoidCallback onItemsChanged;
  final ValueChanged<DateTime?> onShipmentDateChanged;
  final ValueChanged<DateTime?> onDeliveryDateChanged;
  final VoidCallback onTotalsChanged;

  ExportTotals get _totals {
    final items = <ExportItemData>[];
    for (var index = 0; index < itemRows.length; index++) {
      final item = itemRows[index].toItemData(sortOrder: index);
      if (item != null) {
        items.add(item);
      }
    }

    return ExportTotals.fromCostTexts(
      items: items,
      logisticsCostText: logisticsCostController.text,
      customsCostText: customsCostController.text,
      insuranceCostText: insuranceCostController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals;
    final moneyCurrency = mapExportCurrency(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ImportFormGroup(
          title: 'Genel',
          icon: Icons.info_outline_rounded,
          children: [
            PanelTextField(
              controller: titleController,
              label: 'Başlık',
            ),
            PanelTextField(
              controller: supplierNameController,
              label: 'Tedarikçi',
            ),
            PanelDropdown<PriceOfferCurrencyType>(
              label: 'Para birimi',
              hint: 'Para birimi seçiniz',
              value: currency,
              items: PriceOfferCurrencyType.values,
              itemLabel: (value) => value.label,
              onChanged: onCurrencyChanged,
            ),
          ],
        ),
        const SizedBox(height: AppUiTokens.space24),
        _ImportFormGroup(
          title: 'Ürün ve fiyat',
          icon: Icons.inventory_2_outlined,
          children: [
            ExportItemsEditor(
              rows: itemRows,
              currency: currency,
              onChanged: onItemsChanged,
            ),
          ],
        ),
        const SizedBox(height: AppUiTokens.space24),
        _ImportFormGroup(
          title: 'Tutar özeti',
          icon: Icons.payments_outlined,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 800;
                final fields = [
                  _ReadOnlyAmountField(
                    label: 'Gönderilen toplam',
                    helper: 'Gönderilen ürünlerin toplam tutarı',
                    value: MoneyUtils.formatAmountMinor(
                      totals.sentTotalMinor,
                      moneyCurrency,
                    ),
                  ),
                  _ReadOnlyAmountField(
                    label: 'Firesiz toplam',
                    helper: 'Gönderilen − Fire',
                    value: MoneyUtils.formatAmountMinor(
                      totals.afterWasteMinor,
                      moneyCurrency,
                    ),
                  ),
                  _ReadOnlyAmountField(
                    label: 'Net toplam',
                    helper: 'Gönderilen − Fire − Lojistik − Gümrük − Sigorta',
                    value: MoneyUtils.formatAmountMinor(
                      totals.netTotalMinor,
                      moneyCurrency,
                    ),
                  ),
                ];

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppUiTokens.space16),
                        fields[i],
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppUiTokens.space16),
                      Expanded(child: fields[i]),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppUiTokens.space24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 800;
            final notesGroup = _ImportFormGroup(
              title: 'Notlar',
              icon: Icons.notes_outlined,
              children: [
                PanelTextField(
                  controller: notesController,
                  label: 'Notlar',
                  minLines: 4,
                  maxLines: 6,
                ),
              ],
            );
            final logisticsGroup = _ImportFormGroup(
              title: 'Lojistik',
              icon: Icons.local_shipping_outlined,
              children: [
                AppDatePickerField(
                  key: ValueKey('ship-$shipmentDate'),
                  label: 'Sevkiyat tarihi',
                  placeholder: 'Sevkiyat tarihi seçiniz',
                  selectedDate: shipmentDate,
                  onDateSelected: onShipmentDateChanged,
                ),
                AppDatePickerField(
                  key: ValueKey('delivery-$deliveryDate'),
                  label: 'Teslimat tarihi',
                  placeholder: 'Teslimat tarihi seçiniz',
                  selectedDate: deliveryDate,
                  onDateSelected: onDeliveryDateChanged,
                ),
                PanelTextField(
                  controller: logisticsNameController,
                  label: 'Lojistik (firma / kişi)',
                ),
                PanelAmountField(
                  controller: logisticsCostController,
                  label: 'Lojistik masrafı',
                  onChanged: (_) => onTotalsChanged(),
                ),
                PanelAmountField(
                  controller: customsCostController,
                  label: 'Gümrük masrafı',
                  onChanged: (_) => onTotalsChanged(),
                ),
                PanelAmountField(
                  controller: insuranceCostController,
                  label: 'Sigorta masrafı',
                  onChanged: (_) => onTotalsChanged(),
                ),
              ],
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  notesGroup,
                  const SizedBox(height: AppUiTokens.space16),
                  logisticsGroup,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: notesGroup),
                const SizedBox(width: AppUiTokens.space24),
                Expanded(child: logisticsGroup),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ImportFormGroup extends StatelessWidget {
  const _ImportFormGroup({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: AppUiTokens.space12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppUiTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
            border: Border.all(color: AppUiTokens.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppUiTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  if (index > 0) const SizedBox(height: AppUiTokens.space16),
                  children[index],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImportRecordFormActions extends StatelessWidget {
  const ImportRecordFormActions({
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 44,
          width: 140,
          child: FilledButton(
            onPressed: isSaving ? null : onSave,
            style: AppInteractiveTheme.filledButtonStyle(
              FilledButton.styleFrom(
                backgroundColor: ColorName.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                ),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Kaydet',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(width: AppUiTokens.space12),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: AppInteractiveTheme.outlinedButtonStyle(
              OutlinedButton.styleFrom(
                foregroundColor: AppUiTokens.textPrimary,
                side: const BorderSide(color: AppUiTokens.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppUiTokens.space24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                ),
              ),
            ),
            child: const Text(
              'Vazgeç',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyAmountField extends StatelessWidget {
  const _ReadOnlyAmountField({
    required this.label,
    required this.value,
    this.helper,
  });

  final String label;
  final String value;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppUiTokens.textMuted,
                ),
          ),
        ],
        const SizedBox(height: AppUiTokens.space8),
        InputDecorator(
          decoration: PanelInputDecoration.build(hintText: '0,00'),
          child: Text(
            value,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
