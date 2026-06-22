import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gen/gen.dart';

class CustomerForm extends StatelessWidget {
  const CustomerForm({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.cityController,
    required this.countryController,
    required this.addressController,
    required this.selectedType,
    required this.selectedStatus,
    required this.showStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController addressController;
  final CustomerType? selectedType;
  final CustomerStatus selectedStatus;
  final bool showStatus;
  final ValueChanged<CustomerType?> onTypeChanged;
  final ValueChanged<CustomerStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanelTextField(
              controller: nameController,
              label: 'Müşteri adı',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelDropdown<CustomerType>(
              label: 'Müşteri tipi',
              value: selectedType,
              hint: 'Müşteri tipi seçiniz',
              items: CustomerType.values,
              itemLabel: (value) => value.label,
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: phoneController,
              label: 'Telefon',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
              ],
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: emailController,
              label: 'E-posta',
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanelTextField(
              controller: cityController,
              label: 'Şehir',
            ),
            const SizedBox(height: AppUiTokens.space16),
            PanelTextField(
              controller: countryController,
              label: 'Ülke',
            ),
            if (showStatus) ...[
              const SizedBox(height: AppUiTokens.space16),
              PanelDropdown<CustomerStatus>(
                label: 'Durum',
                value: selectedStatus,
                items: CustomerStatus.values,
                itemLabel: (value) => value.label,
                onChanged: onStatusChanged,
              ),
            ],
            const SizedBox(height: AppUiTokens.space16),
            _MultilineField(
              controller: addressController,
              label: 'Adres',
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

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

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
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          style: const TextStyle(
            color: AppUiTokens.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: AppUiTokens.textMuted),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class CustomerFormActions extends StatelessWidget {
  const CustomerFormActions({
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
