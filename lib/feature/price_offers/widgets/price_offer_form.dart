import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/due_tracking/widgets/customer_search_dropdown.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_items_editor.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/price_offer_messages.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class PriceOfferForm extends StatelessWidget {
  const PriceOfferForm({
    required this.customers,
    required this.selectedCustomerId,
    required this.selectedType,
    required this.offerDate,
    required this.validityDate,
    required this.contacts,
    required this.selectedContact,
    required this.isLoadingContacts,
    required this.authorizedPhoneController,
    required this.mobilePhoneController,
    required this.legalTextController,
    required this.itemRows,
    required this.onCustomerChanged,
    required this.onContactChanged,
    required this.onTypeChanged,
    required this.onDateChanged,
    required this.onValidityDateChanged,
    required this.onLegalTextChanged,
    this.selectedStatus,
    this.onStatusChanged,
    this.showStatus = false,
    super.key,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final OfferType? selectedType;
  final DateTime? offerDate;
  final DateTime? validityDate;
  final List<CustomerContactItem> contacts;
  final CustomerContactItem? selectedContact;
  final bool isLoadingContacts;
  final TextEditingController authorizedPhoneController;
  final TextEditingController mobilePhoneController;
  final TextEditingController legalTextController;
  final List<PriceOfferItemFormRow> itemRows;
  final ValueChanged<String?> onCustomerChanged;
  final ValueChanged<CustomerContactItem?> onContactChanged;
  final ValueChanged<OfferType?> onTypeChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<DateTime?> onValidityDateChanged;
  final ValueChanged<String> onLegalTextChanged;
  final PriceOfferStatus? selectedStatus;
  final ValueChanged<PriceOfferStatus?>? onStatusChanged;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return Text(
        PriceOfferMessages.noCustomersForForm,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppUiTokens.textSecondary,
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
            title: 'Teklif Bilgileri', icon: Icons.description_outlined),
        const SizedBox(height: AppUiTokens.space16),
        _OfferTypeSelector(
          selectedType: selectedType,
          onTypeChanged: onTypeChanged,
        ),
        const SizedBox(height: AppUiTokens.space16),
        LayoutBuilder(
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
                  key: ValueKey(offerDate),
                  label: 'Teklif Tarihi',
                  placeholder: 'Teklif tarihi seçiniz',
                  selectedDate: offerDate,
                  onDateSelected: onDateChanged,
                ),
                const SizedBox(height: AppUiTokens.space16),
                AppDatePickerField(
                  key: ValueKey(validityDate),
                  label: 'Geçerlilik Tarihi',
                  placeholder: 'Geçerlilik tarihi seçiniz',
                  selectedDate: validityDate,
                  onDateSelected: onValidityDateChanged,
                ),
              ],
            );

            final rightColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PanelDropdown<CustomerContactItem>(
                  label: 'Yetkili Kişi',
                  hint: _contactHint(
                    selectedCustomerId: selectedCustomerId,
                    isLoadingContacts: isLoadingContacts,
                    hasContacts: contacts.isNotEmpty,
                  ),
                  value: selectedContact,
                  items: contacts,
                  itemLabel: _contactLabel,
                  enabled: selectedCustomerId != null &&
                      !isLoadingContacts &&
                      contacts.isNotEmpty,
                  onChanged: onContactChanged,
                ),
                const SizedBox(height: AppUiTokens.space16),
                PanelTextField(
                  controller: authorizedPhoneController,
                  label: 'Telefon',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppUiTokens.space16),
                PanelTextField(
                  controller: mobilePhoneController,
                  label: 'Yetkili Telefonu',
                  keyboardType: TextInputType.phone,
                ),
                if (showStatus) ...[
                  const SizedBox(height: AppUiTokens.space16),
                  PanelDropdown<PriceOfferStatus>(
                    label: 'Durum',
                    hint: 'Durum seçiniz',
                    value: selectedStatus,
                    items: PriceOfferStatus.values,
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
        ),
        const SizedBox(height: AppUiTokens.space32),
        _SectionTitle(
          title: 'Ürün Detayları',
          icon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: AppUiTokens.space16),
        PriceOfferItemsEditor(
          rows: itemRows,
        ),
        const SizedBox(height: AppUiTokens.space32),
        _SectionTitle(
          title: 'Teklif Bilgilendirme Metni',
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: AppUiTokens.space16),
        PanelTextField(
          controller: legalTextController,
          label: 'Teklif Bilgilendirme Metni',
          hintText: 'Teklif bilgilendirme metni',
          minLines: 5,
          maxLines: 8,
          onChanged: onLegalTextChanged,
        ),
      ],
    );
  }
}

String _contactLabel(CustomerContactItem contact) {
  final title = contact.title?.trim();
  if (title != null && title.isNotEmpty) {
    return '${contact.fullName} · $title';
  }

  return contact.fullName;
}

String _contactHint({
  required String? selectedCustomerId,
  required bool isLoadingContacts,
  required bool hasContacts,
}) {
  if (selectedCustomerId == null) {
    return PriceOfferMessages.selectCustomerForContact;
  }

  if (isLoadingContacts) {
    return 'Yetkili kişiler yükleniyor...';
  }

  if (!hasContacts) {
    return PriceOfferMessages.noContactsForSelectedCustomer;
  }

  return 'Yetkili kişi seçiniz';
}

class PriceOfferFormActions extends StatelessWidget {
  const PriceOfferFormActions({
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _OfferTypeSelector extends StatelessWidget {
  const _OfferTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  final OfferType? selectedType;
  final ValueChanged<OfferType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tip',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Wrap(
          spacing: AppUiTokens.space8,
          runSpacing: AppUiTokens.space8,
          children: OfferType.values.map((type) {
            final isSelected = selectedType == type;

            return SizedBox(
              height: 38,
              child: OutlinedButton(
                onPressed: () => onTypeChanged(type),
                style: AppInteractiveTheme.outlinedButtonStyle(
                  OutlinedButton.styleFrom(
                    foregroundColor: isSelected
                        ? ColorName.primary
                        : AppUiTokens.textPrimary,
                    backgroundColor: isSelected
                        ? AppUiTokens.accentSoft
                        : AppUiTokens.surface,
                    side: BorderSide(
                      color: isSelected
                          ? ColorName.primary.withValues(alpha: 0.5)
                          : AppUiTokens.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppUiTokens.space16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                    ),
                  ),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
