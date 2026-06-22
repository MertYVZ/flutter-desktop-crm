import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/reminder_messages.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ReminderForm extends StatelessWidget {
  const ReminderForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.titleController,
    required this.selectedPeriod,
    required this.startDate,
    required this.noteController,
    required this.onCustomerChanged,
    required this.onPeriodChanged,
    required this.onStartDateChanged,
    this.nextReminderDate,
    this.selectedStatus,
    this.onNextReminderDateChanged,
    this.onStatusChanged,
    this.showEditFields = false,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final TextEditingController titleController;
  final ReminderPeriod? selectedPeriod;
  final DateTime? startDate;
  final DateTime? nextReminderDate;
  final ReminderStatus? selectedStatus;
  final TextEditingController noteController;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<ReminderPeriod?> onPeriodChanged;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?>? onNextReminderDateChanged;
  final ValueChanged<ReminderStatus?>? onStatusChanged;
  final bool showEditFields;

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return Text(
        ReminderMessages.noCustomersForForm,
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
            PanelTextField(
              controller: titleController,
              label: 'Başlık',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelDropdown<ReminderPeriod>(
              label: 'Periyot',
              hint: 'Periyot seçiniz',
              value: selectedPeriod,
              items: ReminderPeriod.values,
              itemLabel: (value) => value.label,
              onChanged: onPeriodChanged,
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDatePickerField(
              key: ValueKey(
                  'reminder-start-date-${startDate?.toIso8601String()}'),
              label: 'İlk Hatırlatma Tarihi',
              placeholder: 'Tarih seçiniz',
              selectedDate: startDate,
              onDateSelected: onStartDateChanged,
            ),
            if (showEditFields) ...[
              const SizedBox(height: AppUiTokens.space16),
              AppDatePickerField(
                key: ValueKey(
                  'reminder-next-date-${nextReminderDate?.toIso8601String()}',
                ),
                label: 'Bir Sonraki Hatırlatma Tarihi',
                placeholder: 'Tarih seçiniz',
                selectedDate: nextReminderDate,
                onDateSelected: onNextReminderDateChanged ?? (_) {},
              ),
              const SizedBox(height: AppUiTokens.space16),
              PanelDropdown<ReminderStatus>(
                label: 'Durum',
                hint: 'Durum seçiniz',
                value: selectedStatus,
                items: ReminderStatus.values,
                itemLabel: (value) => value.label,
                onChanged: onStatusChanged,
              ),
            ],
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
            hintText: 'Not',
            hintStyle: TextStyle(color: AppUiTokens.textMuted),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class ReminderFormActions extends StatelessWidget {
  const ReminderFormActions({
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
