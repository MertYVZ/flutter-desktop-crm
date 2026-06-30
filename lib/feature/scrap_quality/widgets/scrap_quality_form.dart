import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_lost_reason.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_kg_utils.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/formatters/turkish_amount_input_formatter.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ScrapQualityForm extends StatelessWidget {
  const ScrapQualityForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.scrapTypeController,
    required this.qualityController,
    required this.quantityController,
    required this.selectedUnit,
    required this.customUnitController,
    required this.quantityKgController,
    required this.recordDate,
    required this.cityController,
    required this.selectedSalesStatus,
    required this.offerPriceController,
    required this.targetPriceController,
    required this.selectedCurrency,
    required this.selectedLostReason,
    required this.customLostReasonController,
    required this.followUpDate,
    required this.noteController,
    required this.onCustomerChanged,
    required this.onUnitChanged,
    required this.onRecordDateChanged,
    required this.onSalesStatusChanged,
    required this.onCurrencyChanged,
    required this.onLostReasonChanged,
    required this.onFollowUpDateChanged,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final TextEditingController scrapTypeController;
  final TextEditingController qualityController;
  final TextEditingController quantityController;
  final ScrapQualityUnit? selectedUnit;
  final TextEditingController customUnitController;
  final TextEditingController quantityKgController;
  final DateTime? recordDate;
  final TextEditingController cityController;
  final ScrapSalesStatus? selectedSalesStatus;
  final TextEditingController offerPriceController;
  final TextEditingController targetPriceController;
  final CurrencyType? selectedCurrency;
  final ScrapLostReason? selectedLostReason;
  final TextEditingController customLostReasonController;
  final DateTime? followUpDate;
  final TextEditingController noteController;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<ScrapQualityUnit?> onUnitChanged;
  final ValueChanged<DateTime?> onRecordDateChanged;
  final ValueChanged<ScrapSalesStatus?> onSalesStatusChanged;
  final ValueChanged<CurrencyType?> onCurrencyChanged;
  final ValueChanged<ScrapLostReason?> onLostReasonChanged;
  final ValueChanged<DateTime?> onFollowUpDateChanged;

  bool get _requiresManualKg =>
      selectedUnit != null && ScrapKgUtils.requiresManualKg(selectedUnit!);

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return Text(
        ScrapQualityMessages.noCustomersForForm,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppUiTokens.textSecondary,
            ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerSearchDropdown(
              customers: customers,
              selectedCustomerId: selectedCustomerId,
              onChanged: onCustomerChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: scrapTypeController,
              label: 'Hurda Türü',
              hintText: 'Örn. Bakır, Demir, HSS',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: qualityController,
              label: 'Kalite',
              hintText: 'Örn. 1. kalite, temiz',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: quantityController,
              label: 'Miktar',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: const [
                TurkishAmountInputFormatter(maxFractionDigits: 3),
              ],
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelDropdown<ScrapQualityUnit>(
              label: 'Birim',
              hint: 'Birim seçiniz',
              value: selectedUnit,
              items: ScrapQualityUnit.values,
              itemLabel: (value) => value.label,
              onChanged: onUnitChanged,
            ),
            if (selectedUnit == ScrapQualityUnit.other) ...[
              const SizedBox(height: AppUiTokens.space16),
              PanelTextField(
                controller: customUnitController,
                label: 'Özel birim',
              ),
            ],
            if (_requiresManualKg) ...[
              const SizedBox(height: AppUiTokens.space16),
              PanelTextField(
                controller: quantityKgController,
                label: 'KG Karşılığı',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: AppUiTokens.space16),
            AppDatePickerField(
              key: ValueKey('record-$recordDate'),
              label: 'Tarih',
              placeholder: 'Tarih seçiniz',
              selectedDate: recordDate,
              onDateSelected: onRecordDateChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            AppDatePickerField(
              key: ValueKey('followup-$followUpDate'),
              label: 'Takip Tarihi',
              placeholder: 'Opsiyonel',
              selectedDate: followUpDate,
              onDateSelected: onFollowUpDateChanged,
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanelTextField(
              controller: cityController,
              label: 'İl',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelDropdown<ScrapSalesStatus>(
              label: 'Satış Durumu',
              hint: 'Satış durumu seçiniz',
              value: selectedSalesStatus,
              items: ScrapSalesStatus.values,
              itemLabel: (value) => value.label,
              onChanged: onSalesStatusChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelDropdown<CurrencyType>(
              label: 'Para Birimi',
              hint: 'Para birimi seçiniz',
              value: selectedCurrency,
              items: CurrencyType.values,
              itemLabel: (value) => value.label,
              onChanged: onCurrencyChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelAmountField(
              controller: offerPriceController,
              label: 'Teklif Fiyatı (/KG)',
              hintText: '0,00',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelAmountField(
              controller: targetPriceController,
              label: 'Hedef Fiyat (/KG)',
              hintText: '0,00',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelDropdown<ScrapLostReason?>(
              label: 'Alınmama Nedeni',
              hint: 'Seçiniz (opsiyonel)',
              value: selectedLostReason,
              items: const [null, ...ScrapLostReason.values],
              itemLabel: (value) => value?.label ?? 'Seçilmedi',
              onChanged: onLostReasonChanged,
            ),
            if (selectedLostReason == ScrapLostReason.other) ...[
              const SizedBox(height: AppUiTokens.space16),
              PanelTextField(
                controller: customLostReasonController,
                label: 'Diğer neden',
              ),
            ],
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: noteController,
              label: 'Notlar',
              hintText: 'Notlarınızı girin',
              minLines: 4,
              maxLines: 8,
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

class ScrapQualityFormActions extends StatelessWidget {
  const ScrapQualityFormActions({
    required this.isSaving,
    required this.onSave,
    required this.onSaveAndNew,
    required this.onCancel,
    this.showSaveAndNew = true,
    super.key,
  });

  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback? onSaveAndNew;
  final VoidCallback onCancel;
  final bool showSaveAndNew;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppUiTokens.space12,
      runSpacing: AppUiTokens.space12,
      crossAxisAlignment: WrapCrossAlignment.center,
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
        if (showSaveAndNew)
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: isSaving ? null : onSaveAndNew,
              style: AppInteractiveTheme.outlinedButtonStyle(
                OutlinedButton.styleFrom(
                  foregroundColor: AppUiTokens.textPrimary,
                  side: const BorderSide(color: AppUiTokens.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                  ),
                ),
              ),
              child: const Text(
                'Kaydet ve Yeni Ekle',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: AppInteractiveTheme.outlinedButtonStyle(
              OutlinedButton.styleFrom(
                foregroundColor: AppUiTokens.textSecondary,
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
              'İptal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
