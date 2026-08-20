import 'package:Ok/feature/export/widgets/export_products_field.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ImportRecordForm extends StatelessWidget {
  const ImportRecordForm({
    required this.titleController,
    required this.supplierNameController,
    required this.productControllers,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.totalAmountController,
    required this.logisticsNameController,
    required this.shipmentDate,
    required this.deliveryDate,
    required this.logisticsCostController,
    required this.customsCostController,
    required this.insuranceCostController,
    required this.notesController,
    required this.onShipmentDateChanged,
    required this.onDeliveryDateChanged,
    super.key,
  });

  final TextEditingController titleController;
  final TextEditingController supplierNameController;
  final List<TextEditingController> productControllers;
  final VoidCallback onAddProduct;
  final ValueChanged<int> onRemoveProduct;
  final TextEditingController totalAmountController;
  final TextEditingController logisticsNameController;
  final DateTime? shipmentDate;
  final DateTime? deliveryDate;
  final TextEditingController logisticsCostController;
  final TextEditingController customsCostController;
  final TextEditingController insuranceCostController;
  final TextEditingController notesController;
  final ValueChanged<DateTime?> onShipmentDateChanged;
  final ValueChanged<DateTime?> onDeliveryDateChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        final leftColumn = Column(
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
              ],
            ),
            const SizedBox(height: AppUiTokens.space24),
            _ImportFormGroup(
              title: 'Ürün',
              icon: Icons.inventory_2_outlined,
              children: [
                ExportProductsField(
                  controllers: productControllers,
                  onAdd: onAddProduct,
                  onRemove: onRemoveProduct,
                ),
              ],
            ),
            const SizedBox(height: AppUiTokens.space24),
            _ImportFormGroup(
              title: 'Tutar',
              icon: Icons.payments_outlined,
              children: [
                PanelAmountField(
                  controller: totalAmountController,
                  label: 'Toplam tutar',
                ),
              ],
            ),
            const SizedBox(height: AppUiTokens.space24),
            _ImportFormGroup(
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
            _ImportFormGroup(
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
