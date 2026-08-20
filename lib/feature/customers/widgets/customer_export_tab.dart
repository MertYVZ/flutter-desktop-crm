import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/feature/export/models/export_currency.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerExportTab extends StatelessWidget {
  const CustomerExportTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.exportRecords;
      final isLoading = controller.isLoadingTabData.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: records.isEmpty,
        emptyMessage: CustomerDetailMessages.exportsEmpty,
        emptyActionLabel: 'İhracat Ekle',
        onEmptyAction: () => controller.openCreateForm(AppRoutes.exportsNew),
        children: records
            .map(
              (record) => CustomerListRow(
                title: record.title,
                subtitle: CustomerRowMeta(
                  items: [
                    record.productName,
                    MoneyUtils.formatAmountMinor(
                      record.totalPriceMinor,
                      mapExportCurrency(
                        PriceOfferCurrencyTypeX.fromValue(record.currency),
                      ),
                    ),
                    if (record.shipmentDate != null)
                      'Sevkiyat: ${AppDateUtils.formatDate(record.shipmentDate!)}',
                  ],
                ),
                trailing: [
                  CustomerSectionActionButton(
                    tooltip: 'Detay',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.exportsDetail.pathForId(record.id),
                    ),
                  ),
                  CustomerSectionActionButton(
                    tooltip: 'Düzenle',
                    icon: Icons.edit_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.exportsEdit.pathForId(record.id),
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
