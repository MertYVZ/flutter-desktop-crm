import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/feature/export/widgets/export_products_field.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/formatters/turkish_amount_input_formatter.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ExportRecordForm extends StatelessWidget {
  const ExportRecordForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.guestCustomerNameController,
    required this.productControllers,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.titleController,
    required this.quantityTonController,
    required this.unitPriceController,
    required this.totalPriceText,
    required this.paymentMethodController,
    required this.bankController,
    required this.firstPaymentDate,
    required this.firstPaymentAmountController,
    required this.lastPaymentDate,
    required this.lastPaymentAmountController,
    required this.wasteKgController,
    required this.netTotalAmountController,
    required this.logisticsNameController,
    required this.shipmentDate,
    required this.deliveryDate,
    required this.logisticsCostController,
    required this.customsCostController,
    required this.insuranceCostController,
    required this.notesController,
    required this.onCustomerChanged,
    required this.onGuestCustomerNameChanged,
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
  final List<TextEditingController> productControllers;
  final VoidCallback onAddProduct;
  final ValueChanged<int> onRemoveProduct;
  final TextEditingController titleController;
  final TextEditingController quantityTonController;
  final TextEditingController unitPriceController;
  final String totalPriceText;
  final TextEditingController paymentMethodController;
  final TextEditingController bankController;
  final DateTime? firstPaymentDate;
  final TextEditingController firstPaymentAmountController;
  final DateTime? lastPaymentDate;
  final TextEditingController lastPaymentAmountController;
  final TextEditingController wasteKgController;
  final TextEditingController netTotalAmountController;
  final TextEditingController logisticsNameController;
  final DateTime? shipmentDate;
  final DateTime? deliveryDate;
  final TextEditingController logisticsCostController;
  final TextEditingController customsCostController;
  final TextEditingController insuranceCostController;
  final TextEditingController notesController;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<String> onGuestCustomerNameChanged;
  final ValueChanged<DateTime?> onFirstPaymentDateChanged;
  final ValueChanged<DateTime?> onLastPaymentDateChanged;
  final ValueChanged<DateTime?> onShipmentDateChanged;
  final ValueChanged<DateTime?> onDeliveryDateChanged;
  final VoidCallback onTotalsChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        final leftColumn = Column(
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
              ],
            ),
            const SizedBox(height: AppUiTokens.space24),
            _ExportFormGroup(
              title: 'Ürün ve miktar',
              icon: Icons.inventory_2_outlined,
              children: [
                ExportProductsField(
                  controllers: productControllers,
                  onAdd: onAddProduct,
                  onRemove: onRemoveProduct,
                ),
                PanelTextField(
                  controller: quantityTonController,
                  label: 'Gönderilen miktar (ton)',
                  hintText: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [
                    TurkishAmountInputFormatter(maxFractionDigits: 3),
                  ],
                  onChanged: (_) => onTotalsChanged(),
                ),
                PanelTextField(
                  controller: wasteKgController,
                  label: 'Fire miktarı (kg)',
                  hintText: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [
                    TurkishAmountInputFormatter(maxFractionDigits: 3),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppUiTokens.space24),
            _ExportFormGroup(
              title: 'Fiyat',
              icon: Icons.payments_outlined,
              children: [
                PanelAmountField(
                  controller: unitPriceController,
                  label: 'Anlaşılan birim fiyat',
                  onChanged: (_) => onTotalsChanged(),
                ),
                _ReadOnlyAmountField(
                  label: 'Toplam fiyat',
                  value: totalPriceText,
                ),
                PanelAmountField(
                  controller: netTotalAmountController,
                  label: 'Net toplam tutar',
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

        final rightColumn = Column(
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
                ),
                PanelAmountField(
                  controller: customsCostController,
                  label: 'Gümrük masrafı',
                ),
                PanelAmountField(
                  controller: insuranceCostController,
                  label: 'Sigorta masrafı',
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
  });

  final String label;
  final String value;

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
        const SizedBox(height: AppUiTokens.space8),
        InputDecorator(
          decoration: PanelInputDecoration.build(hintText: '0,00'),
          child: Text(
            value.isEmpty ? '0,00' : value,
            style: TextStyle(
              color: value.isEmpty
                  ? AppUiTokens.textMuted
                  : AppUiTokens.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
