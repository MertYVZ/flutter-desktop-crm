import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:Ok/product/widgets/status_badge_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDueRecordsTab extends StatelessWidget {
  const CustomerDueRecordsTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.dueRecords;
      final isLoading = controller.isLoadingTabData.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.dueRecordsEmpty,
        emptyActionLabel: 'Vade Kaydı Ekle',
        onEmptyAction: () => Get.toNamed<void>(AppRoutes.dueTrackingNew.value),
        children: records
            .map(
              (record) {
                final currency = record.currencyType ?? CurrencyType.try_;
                final displayStatus = record.displayStatus;

                return CustomerListRow(
                  title: record.invoiceNo,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MoneyUtils.formatAmountMinor(
                          record.amountMinor,
                          currency,
                        ),
                      ),
                      const SizedBox(height: AppUiTokens.space4),
                      CustomerRowMeta(
                        items: [
                          'Vade: ${AppDateUtils.formatDate(record.dueDate)}',
                        ],
                      ),
                    ],
                  ),
                  trailing: [
                    AppStatusBadge(
                      label: displayStatus.label,
                      style: displayStatus.badgeStyle,
                      compact: true,
                    ),
                    CustomerSectionActionButton(
                      tooltip: 'Düzenle',
                      icon: Icons.edit_outlined,
                      onPressed: () => Get.toNamed<void>(
                        AppRoutes.dueTrackingEdit.pathForId(record.id),
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
