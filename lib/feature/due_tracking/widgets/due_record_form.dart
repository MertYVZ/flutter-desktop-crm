import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/due_record_messages.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class DueRecordForm extends StatelessWidget {
  const DueRecordForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.dueDate,
    required this.amountController,
    required this.invoiceNoController,
    required this.selectedCurrency,
    required this.showStatus,
    required this.selectedStatus,
    required this.onCustomerChanged,
    required this.onDueDateChanged,
    required this.onCurrencyChanged,
    required this.onStatusChanged,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final DateTime? dueDate;
  final TextEditingController amountController;
  final TextEditingController invoiceNoController;
  final CurrencyType? selectedCurrency;
  final bool showStatus;
  final DueRecordStatus? selectedStatus;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<DateTime?> onDueDateChanged;
  final ValueChanged<CurrencyType?> onCurrencyChanged;
  final ValueChanged<DueRecordStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return Text(
        DueRecordMessages.noCustomersForForm,
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
            AppDatePickerField(
              key: ValueKey(dueDate),
              label: 'Vade tarihi',
              placeholder: 'Vade tarihi seçiniz',
              selectedDate: dueDate,
              onDateSelected: onDueDateChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelAmountField(
              controller: amountController,
              label: 'Tutar',
              hintText: '0,00',
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanelDropdown<CurrencyType>(
              label: 'Para birimi',
              hint: 'Para birimi seçiniz',
              value: selectedCurrency,
              items: CurrencyType.values,
              itemLabel: (value) => value.label,
              onChanged: onCurrencyChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: invoiceNoController,
              label: 'Fatura no',
            ),
            if (showStatus) ...[
              const SizedBox(height: AppUiTokens.space16),
              PanelDropdown<DueRecordStatus>(
                label: 'Durum',
                hint: 'Durum seçiniz',
                value: selectedStatus,
                items: DueRecordStatus.values,
                itemLabel: (value) => value.label,
                onChanged: onStatusChanged,
              ),
            ],
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

class DueRecordFormActions extends StatelessWidget {
  const DueRecordFormActions({
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
