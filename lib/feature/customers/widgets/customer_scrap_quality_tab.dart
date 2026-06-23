import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerScrapQualityTab extends StatelessWidget {
  const CustomerScrapQualityTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.scrapQualityRecords;
      final isLoading = controller.isLoadingTabData.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.scrapQualityEmpty,
        emptyActionLabel: 'Hurda Kaydı Ekle',
        onEmptyAction: () => Get.toNamed<void>(AppRoutes.scrapQualityNew.value),
        children: records
            .map(
              (record) => CustomerListRow(
                title: record.quality,
                subtitle: CustomerRowMeta(
                  items: [
                    '${QuantityUtils.formatQuantity(record.quantity)} ${record.unit}',
                    AppDateUtils.formatDate(record.recordDate),
                  ],
                ),
                trailing: [
                  CustomerSectionActionButton(
                    tooltip: 'Düzenle',
                    icon: Icons.edit_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.scrapQualityEdit.pathForId(record.id),
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
