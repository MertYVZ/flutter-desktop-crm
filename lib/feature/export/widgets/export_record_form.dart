import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/feature/export/models/export_currency.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/export/widgets/export_items_editor.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ExportRecordForm extends StatelessWidget {
  const ExportRecordForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.guestCustomerNameController,
    required this.itemRows,
    required this.currency,
    required this.titleController,
    required this.paymentMethodController,
    required this.bankController,
    required this.firstPaymentDate,
    required this.firstPaymentAmountController,
    required this.lastPaymentDate,
    required this.lastPaymentAmountController,
    required this.logisticsNameController,
    required this.shipmentDate,
    required this.deliveryDate,
    required this.logisticsCostController,
    required this.customsCostController,
    required this.insuranceCostController,
    required this.notesController,
    required this.onCustomerChanged,
    required this.onGuestCustomerNameChanged,
    required this.onCurrencyChanged,
    required this.onItemsChanged,
    required this.onFirstPaymentDateChanged,
    required this.onLastPaymentDateChanged,
    required this.onShipmentDateChanged,
    required this.onDeliveryDateChanged,
    required this.onTotalsChanged,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final TextEditingController guestCustomerNameController;
  final List<ExportItemFormRow> itemRows;
  final PriceOfferCurrencyType currency;
  final TextEditingController titleController;
  final TextEditingController paymentMethodController;
  final TextEditingController bankController;
  final DateTime? firstPaymentDate;
  final TextEditingController firstPaymentAmountController;
  final DateTime? lastPaymentDate;
  final TextEditingController lastPaymentAmountController;
  final TextEditingController logisticsNameController;
  final DateTime? shipmentDate;
  final DateTime? deliveryDate;
  final TextEditingController logisticsCostController;
  final TextEditingController customsCostController;
  final TextEditingController insuranceCostController;
  final TextEditingController notesController;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<String> onGuestCustomerNameChanged;
  final ValueChanged<PriceOfferCurrencyType?> onCurrencyChanged;
  final VoidCallback onItemsChanged;
  final ValueChanged<DateTime?> onFirstPaymentDateChanged;
  final ValueChanged<DateTime?> onLastPaymentDateChanged;
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
        _ExportFormGroup(
          title: 'Genel',
          icon: Icons.info_outline_rounded,
          children: [
            PanelTextField(
              controller: titleController,
              label: 'Başlık',
            ),
            CustomerSearchDropdown(
              customers: customers,
              selectedCustomerId: selectedCustomerId,
              allowCustomEntry: true,
              customName: guestCustomerNameController.text,
              placeholder: 'Müşteri seçin veya yazın',
              onChanged: onCustomerChanged,
              onCustomNameChanged: onGuestCustomerNameChanged,
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
        _ExportFormGroup(
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
        _ExportFormGroup(
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

            final leftColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ExportFormGroup(
                  title: 'Ödeme',
                  icon: Icons.account_balance_outlined,
                  children: [
                    PanelTextField(
                      controller: paymentMethodController,
                      label: 'Ödeme şekli',
                    ),
                    PanelTextField(
                      controller: bankController,
                      label: 'Banka',
                    ),
                    AppDatePickerField(
                      key: ValueKey('first-$firstPaymentDate'),
                      label: 'İlk ödeme tarihi',
                      placeholder: 'İlk ödeme tarihi seçiniz',
                      selectedDate: firstPaymentDate,
                      onDateSelected: onFirstPaymentDateChanged,
                    ),
                    PanelAmountField(
                      controller: firstPaymentAmountController,
                      label: 'İlk ödeme tutarı',
                    ),
                    AppDatePickerField(
                      key: ValueKey('last-$lastPaymentDate'),
                      label: 'Son ödeme tarihi',
                      placeholder: 'Son ödeme tarihi seçiniz',
                      selectedDate: lastPaymentDate,
                      onDateSelected: onLastPaymentDateChanged,
                    ),
                    PanelAmountField(
                      controller: lastPaymentAmountController,
                      label: 'Son ödeme tutarı',
                    ),
                  ],
                ),
                const SizedBox(height: AppUiTokens.space24),
                _ExportFormGroup(
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
                ),
              ],
            );

            final rightColumn = _ExportFormGroup(
              title: 'Lojistik',
              icon: Icons.local_shipping_outlined,
              children: [
                PanelTextField(
                  controller: logisticsNameController,
                  label: 'Lojistik (firma / kişi)',
                ),
                AppDatePickerField(
                  key: ValueKey('ship-$shipmentDate'),
                  label: 'Sevkiyat tarihi',
                  placeholder: 'Sevkiyat tarihi seçiniz',
                  selectedDate: shipmentDate,
                  onDateSelected: onShipmentDateChanged,
                ),
                AppDatePickerField(
                  key: ValueKey('delivery-$deliveryDate'),
                  label: 'Teslim tarihi',
                  placeholder: 'Teslim tarihi seçiniz',
                  selectedDate: deliveryDate,
                  onDateSelected: onDeliveryDateChanged,
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
    );
  }
}

class _ExportFormGroup extends StatelessWidget {
  const _ExportFormGroup({
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

class ExportRecordFormActions extends StatelessWidget {
  const ExportRecordFormActions({
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
