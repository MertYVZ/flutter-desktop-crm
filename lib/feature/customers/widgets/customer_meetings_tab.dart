import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerMeetingsTab extends StatelessWidget {
  const CustomerMeetingsTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.meetings;
      final isLoading = controller.isLoadingTabData.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.meetingsEmpty,
        emptyActionLabel: 'Görüşme Ekle',
        onEmptyAction: () => controller.openCreateForm(AppRoutes.meetingsNew),
        children: records
            .map(
              (meeting) => CustomerListRow(
                title: AppDateUtils.formatDate(meeting.date),
                subtitle: CustomerRowMeta(
                  items: [
                    meeting.meetingMethod?.label ?? meeting.method,
                    meeting.meetingSubject?.label ?? meeting.subject,
                    truncateText(meeting.notes),
                  ],
                ),
                trailing: [
                  CustomerSectionActionButton(
                    tooltip: 'Detay',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.meetingsDetail.pathForId(meeting.id),
                    ),
                  ),
                  CustomerSectionActionButton(
                    tooltip: 'Düzenle',
                    icon: Icons.edit_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.meetingsEdit.pathForId(meeting.id),
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
