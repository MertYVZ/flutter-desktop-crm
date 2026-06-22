import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ScrapQualityForm extends StatelessWidget {
  const ScrapQualityForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.qualityController,
    required this.quantityController,
    required this.selectedUnit,
    required this.customUnitController,
    required this.recordDate,
    required this.noteController,
    required this.onCustomerChanged,
    required this.onUnitChanged,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final TextEditingController qualityController;
  final TextEditingController quantityController;
  final ScrapQualityUnit? selectedUnit;
  final TextEditingController customUnitController;
  final DateTime? recordDate;
  final TextEditingController noteController;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<ScrapQualityUnit?> onUnitChanged;

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
        final isCompact = constraints.maxWidth < 800;

        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerSearchDropdown(
              customers: customers,
              selectedCustomerId: selectedCustomerId,
              onChanged: onCustomerChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            _QualityField(controller: qualityController),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: quantityController,
              label: 'Miktar',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RecordDateField(recordDate: recordDate),
            const SizedBox(height: AppUiTokens.space16),
            _NoteField(controller: noteController),
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

class _QualityField extends StatelessWidget {
  const _QualityField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalite',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: AppUiTokens.textPrimary,
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            hintText: 'Örn: İyi, Süper, Kötü',
            hintStyle: TextStyle(color: AppUiTokens.textMuted),
          ),
        ),
      ],
    );
  }
}

class _RecordDateField extends StatelessWidget {
  const _RecordDateField({required this.recordDate});

  final DateTime? recordDate;

  @override
  Widget build(BuildContext context) {
    final displayText = recordDate != null
        ? AppDateUtils.formatDate(recordDate!)
        : AppDateUtils.formatDate(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kayıt tarihi',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Container(
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space16),
          decoration: BoxDecoration(
            color: AppUiTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            border: Border.all(color: AppUiTokens.border),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            displayText,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Not',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          style: const TextStyle(
            color: AppUiTokens.textPrimary,
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            hintText: 'Not (isteğe bağlı)',
            hintStyle: TextStyle(color: AppUiTokens.textMuted),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class ScrapQualityFormActions extends StatelessWidget {
  const ScrapQualityFormActions({
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
