import 'package:Ok/feature/export/models/export_detail.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_record_list_item.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/export/services/export_service.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/export_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class ExportController extends GetxController {
  ExportController(this._exportService);

  final ExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxList<ExportRecordListItem> exports = <ExportRecordListItem>[].obs;
  final Rxn<ExportDetail> selectedExport = Rxn<ExportDetail>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString deletingExportId = RxnString();

  bool get hasActiveFilters => searchQuery.value.trim().isNotEmpty;

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _exportService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> searchAndFilterExports() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _exportService.searchExports(
        searchQuery: searchQuery.value,
      );
      exports.assignAll(result);
    } catch (_) {
      errorMessage.value = ExportMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    searchAndFilterExports();
  }

  Future<String?> createExport({
    required String title,
    required String? customerId,
    required String guestCustomerName,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required List<ExportItemValidationInput> itemInputs,
    required String paymentMethod,
    required String bank,
    required DateTime? firstPaymentDate,
    required String firstPaymentAmountText,
    required DateTime? lastPaymentDate,
    required String lastPaymentAmountText,
    required String logisticsName,
    required DateTime? shipmentDate,
    required DateTime? deliveryDate,
    required String logisticsCostText,
    required String customsCostText,
    required String insuranceCostText,
    required String notes,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateExportForm(
          title: title,
          customerId: customerId,
          guestCustomerName: guestCustomerName,
          firstPaymentAmountText: firstPaymentAmountText,
          lastPaymentAmountText: lastPaymentAmountText,
          logisticsCostText: logisticsCostText,
          customsCostText: customsCostText,
          insuranceCostText: insuranceCostText,
        ) ??
        Validators.validateExportItems(items: itemInputs);
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final customer = _resolveCustomer(
        customerId: customerId,
        guestCustomerName: guestCustomerName,
      );
      final totals = ExportTotals.fromCostTexts(
        items: items,
        logisticsCostText: logisticsCostText,
        customsCostText: customsCostText,
        insuranceCostText: insuranceCostText,
      );

      final id = await _exportService.createExport(
        title: title,
        customerId: customer.id,
        customerNameSnapshot: customer.name,
        currency: currency,
        items: items,
        totals: totals,
        paymentMethod: paymentMethod,
        bank: bank,
        firstPaymentDate: firstPaymentDate,
        firstPaymentAmountMinor: _optionalAmount(firstPaymentAmountText),
        lastPaymentDate: lastPaymentDate,
        lastPaymentAmountMinor: _optionalAmount(lastPaymentAmountText),
        logisticsName: logisticsName,
        shipmentDate: shipmentDate,
        deliveryDate: deliveryDate,
        logisticsCostMinor: _optionalAmount(logisticsCostText),
        customsCostMinor: _optionalAmount(customsCostText),
        insuranceCostMinor: _optionalAmount(insuranceCostText),
        notes: notes,
      );
      successMessage.value = ExportMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = ExportMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getExportById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedExport.value = null;
    isLoading.value = true;
    try {
      final detail = await _exportService.getExportById(id);
      if (detail == null) {
        errorMessage.value = ExportMessages.notFound;
        selectedExport.value = null;
        return false;
      }

      selectedExport.value = detail;
      return true;
    } catch (_) {
      errorMessage.value = ExportMessages.notFound;
      selectedExport.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExport({
    required String id,
    required String title,
    required String? customerId,
    required String guestCustomerName,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required List<ExportItemValidationInput> itemInputs,
    required String paymentMethod,
    required String bank,
    required DateTime? firstPaymentDate,
    required String firstPaymentAmountText,
    required DateTime? lastPaymentDate,
    required String lastPaymentAmountText,
    required String logisticsName,
    required DateTime? shipmentDate,
    required DateTime? deliveryDate,
    required String logisticsCostText,
    required String customsCostText,
    required String insuranceCostText,
    required String notes,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateExportForm(
          title: title,
          customerId: customerId,
          guestCustomerName: guestCustomerName,
          firstPaymentAmountText: firstPaymentAmountText,
          lastPaymentAmountText: lastPaymentAmountText,
          logisticsCostText: logisticsCostText,
          customsCostText: customsCostText,
          insuranceCostText: insuranceCostText,
        ) ??
        Validators.validateExportItems(items: itemInputs);
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      final customer = _resolveCustomer(
        customerId: customerId,
        guestCustomerName: guestCustomerName,
      );
      final totals = ExportTotals.fromCostTexts(
        items: items,
        logisticsCostText: logisticsCostText,
        customsCostText: customsCostText,
        insuranceCostText: insuranceCostText,
      );

      await _exportService.updateExport(
        id: id,
        title: title,
        customerId: customer.id,
        customerNameSnapshot: customer.name,
        currency: currency,
        items: items,
        totals: totals,
        paymentMethod: paymentMethod,
        bank: bank,
        firstPaymentDate: firstPaymentDate,
        firstPaymentAmountMinor: _optionalAmount(firstPaymentAmountText),
        lastPaymentDate: lastPaymentDate,
        lastPaymentAmountMinor: _optionalAmount(lastPaymentAmountText),
        logisticsName: logisticsName,
        shipmentDate: shipmentDate,
        deliveryDate: deliveryDate,
        logisticsCostMinor: _optionalAmount(logisticsCostText),
        customsCostMinor: _optionalAmount(customsCostText),
        insuranceCostMinor: _optionalAmount(insuranceCostText),
        notes: notes,
      );
      return true;
    } catch (_) {
      errorMessage.value = ExportMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteExport(String id) async {
    if (isDeleting.value || deletingExportId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingExportId.value = id;
    try {
      await _exportService.deleteExport(id);
      exports.removeWhere((record) => record.id == id);
      successMessage.value = ExportMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ExportMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingExportId.value = null;
    }
  }

  ({String id, String name}) _resolveCustomer({
    required String? customerId,
    required String guestCustomerName,
  }) {
    if (customerId != null && customerId.isNotEmpty) {
      for (final customer in customers) {
        if (customer.id == customerId) {
          return (id: customer.id, name: customer.name);
        }
      }
      return (id: customerId, name: guestCustomerName.trim());
    }

    return (id: '', name: guestCustomerName.trim());
  }

  int? _optionalAmount(String text) =>
      MoneyUtils.parseAmountToMinor(text.trim());

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
              border: Border.all(color: AppUiTokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppUiTokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(
                            AppUiTokens.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: ColorName.error,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ExportMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              ExportMessages.deleteBody,
                              style: TextStyle(
                                color: AppUiTokens.textSecondary,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppUiTokens.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back<bool>(result: false),
                        style: AppInteractiveTheme.textButtonStyle(
                          TextButton.styleFrom(
                            foregroundColor: AppUiTokens.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppUiTokens.space16,
                              vertical: AppUiTokens.space12,
                            ),
                          ),
                        ),
                        child: const Text(
                          ExportMessages.deleteCancel,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space8),
                      FilledButton(
                        onPressed: () => Get.back<bool>(result: true),
                        style: AppInteractiveTheme.filledButtonStyle(
                          FilledButton.styleFrom(
                            backgroundColor: ColorName.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppUiTokens.space24,
                              vertical: AppUiTokens.space12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppUiTokens.radiusSm,
                              ),
                            ),
                          ),
                        ),
                        child: const Text(
                          ExportMessages.deleteConfirm,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
    );

    return result ?? false;
  }
}
