import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/customers/widgets/customer_contact_form_dialog.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class CustomerContactsTab extends StatelessWidget {
  const CustomerContactsTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.contacts;
      final isLoading = controller.isLoadingTabData.value;
      final isDeleting = controller.isDeletingContact.value;
      final deletingId = controller.deletingContactId.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.contactsEmpty,
        emptyActionLabel: 'Yeni Yetkili Ekle',
        onEmptyAction: () => showCustomerContactFormDialog(
          controller: controller,
        ),
        children: records
            .map(
              (contact) => _buildRow(
                contact,
                isDeleting: isDeleting && deletingId == contact.id,
              ),
            )
            .toList(),
      );
    });
  }

  Widget _buildRow(
    CustomerContactItem contact, {
    required bool isDeleting,
  }) {
    return CustomerListRow(
      title: contact.fullName,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.displayTitle.isNotEmpty)
            Text(contact.displayTitle),
          CustomerRowMeta(
            items: [
              contact.displayEmail,
              contact.displayPhone,
            ],
          ),
          if (contact.isPrimary) ...[
            const SizedBox(height: AppUiTokens.space4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: ColorName.primary,
                  size: 14,
                ),
                const SizedBox(width: AppUiTokens.space4),
                Text(
                  'Ana Yetkili',
                  style: TextStyle(
                    color: ColorName.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: [
        CustomerSectionActionButton(
          tooltip: 'Düzenle',
          icon: Icons.edit_outlined,
          onPressed: isDeleting
              ? null
              : () => showCustomerContactFormDialog(
                    controller: controller,
                    existingContact: contact,
                  ),
        ),
        CustomerSectionActionButton(
          tooltip: 'Sil',
          icon: Icons.delete_outline_rounded,
          color: ColorName.error,
          isLoading: isDeleting,
          onPressed: isDeleting
              ? null
              : () => controller.deleteContact(contact.id),
        ),
      ],
    );
  }
}
