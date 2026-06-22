import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class NoteForm extends StatelessWidget {
  const NoteForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.titleController,
    required this.contentController,
    required this.onCustomerChanged,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final ValueChanged<String?> onCustomerChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomerSearchDropdown(
          customers: customers,
          selectedCustomerId: selectedCustomerId,
          allowNullSelection: true,
          placeholder: 'Müşteri seçiniz (opsiyonel)',
          onChanged: onCustomerChanged,
        ),
        const SizedBox(height: AppUiTokens.space16),
        _TitleField(controller: titleController),
        const SizedBox(height: AppUiTokens.space16),
        _ContentField(controller: contentController),
      ],
    );
  }
}

class _TitleField extends StatelessWidget {
  const _TitleField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Başlık',
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
            hintText: 'Başlık',
            hintStyle: TextStyle(color: AppUiTokens.textMuted),
          ),
        ),
      ],
    );
  }
}

class _ContentField extends StatelessWidget {
  const _ContentField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İçerik',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 10,
          style: const TextStyle(
            color: AppUiTokens.textPrimary,
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            hintText: 'İçerik',
            hintStyle: TextStyle(color: AppUiTokens.textMuted),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class NoteFormActions extends StatelessWidget {
  const NoteFormActions({
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
