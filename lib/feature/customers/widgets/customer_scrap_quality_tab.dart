import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_sales_status_badge.dart';
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
        onEmptyAction: () => controller.openCreateForm(AppRoutes.scrapQualityNew),
        children: records
            .map(
              (record) => CustomerListRow(
                title: record.scrapType,
                subtitle: CustomerRowMeta(
                  items: [
                    '${QuantityUtils.formatQuantity(record.quantity)} ${record.unit}',
                    QuantityUtils.formatKg(record.quantityKg),
                    AppDateUtils.formatDate(record.recordDate),
                  ],
                ),
                trailing: [
                  ScrapSalesStatusBadge(status: record.salesStatusEnum),
                  const SizedBox(width: 8),
                  CustomerSectionActionButton(
                    tooltip: 'Görüntüle',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.scrapQualityDetail.pathForId(record.id),
                    ),
                  ),
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
