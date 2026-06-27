import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:Ok/product/widgets/status_badge_styles.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class CustomerRemindersTab extends StatelessWidget {
  const CustomerRemindersTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.reminders;
      final isLoading = controller.isLoadingTabData.value;
      final isCompleting = controller.isCompletingReminder.value;
      final completingId = controller.completingReminderId.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.remindersEmpty,
        emptyActionLabel: 'Hatırlatıcı Ekle',
        onEmptyAction: () => controller.openCreateForm(AppRoutes.remindersNew),
        children: records
            .map(
              (reminder) {
                final isRowCompleting =
                    isCompleting && completingId == reminder.id;

                return CustomerListRow(
                  title: reminder.title,
                  subtitle: CustomerRowMeta(
                    items: [
                      reminder.reminderPeriod?.label ?? reminder.period,
                      'Sonraki: ${AppDateUtils.formatDate(reminder.nextReminderDate)}',
                    ],
                  ),
                  trailing: [
                    if (reminder.reminderStatus != null)
                      AppStatusBadge(
                        label: reminder.reminderStatus!.label,
                        style: reminder.reminderStatus!.badgeStyle,
                        compact: true,
                      ),
                    CustomerSectionActionButton(
                      tooltip: 'Tamamlandı',
                      icon: Icons.check_circle_outline_rounded,
                      color: ColorName.primary,
                      isLoading: isRowCompleting,
                      onPressed: reminder.isPassive || isCompleting
                          ? null
                          : () async {
                              await controller.completeReminder(reminder.id);
                            },
                    ),
                    CustomerSectionActionButton(
                      tooltip: 'Düzenle',
                      icon: Icons.edit_outlined,
                      onPressed: isCompleting
                          ? null
                          : () => Get.toNamed<void>(
                                AppRoutes.remindersEdit.pathForId(reminder.id),
                              ),
                    ),
                  ],
                );
              },
            )
            .toList(),
      );
    });
  }
}
