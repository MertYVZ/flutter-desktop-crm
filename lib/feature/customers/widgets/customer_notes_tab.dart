import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerNotesTab extends StatelessWidget {
  const CustomerNotesTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.notes;
      final isLoading = controller.isLoadingTabData.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.notesEmpty,
        emptyActionLabel: 'Not Ekle',
        onEmptyAction: () => Get.toNamed<void>(AppRoutes.notesNew.value),
        children: records
            .map(
              (note) => CustomerListRow(
                title: note.title,
                subtitle: CustomerRowMeta(
                  items: [
                    truncateText(note.content),
                    AppDateUtils.formatDate(note.createdAt),
                  ],
                ),
                trailing: [
                  CustomerSectionActionButton(
                    tooltip: 'Detay',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.notesDetail.pathForId(note.id),
                    ),
                  ),
                  CustomerSectionActionButton(
                    tooltip: 'Düzenle',
                    icon: Icons.edit_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.notesEdit.pathForId(note.id),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      );
    });
  }
}
