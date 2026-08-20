import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/models/export_totals.dart';
import 'package:Ok/feature/import/models/import_detail.dart';
import 'package:Ok/feature/import/models/import_record_list_item.dart';
import 'package:Ok/feature/import/services/import_service.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/import_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class ImportController extends GetxController {
  ImportController(this._importService);

  final ImportService _importService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxList<ImportRecordListItem> imports = <ImportRecordListItem>[].obs;
  final Rxn<ImportDetail> selectedImport = Rxn<ImportDetail>();
  final RxString searchQuery = ''.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString deletingImportId = RxnString();

  bool get hasActiveFilters => searchQuery.value.trim().isNotEmpty;

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<void> searchAndFilterImports() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _importService.searchImports(
        searchQuery: searchQuery.value,
      );
      imports.assignAll(result);
    } catch (_) {
      errorMessage.value = ImportMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    searchAndFilterImports();
  }

  Future<String?> createImport({
    required String title,
    required String supplierName,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required List<ExportItemValidationInput> itemInputs,
    required DateTime? shipmentDate,
    required DateTime? deliveryDate,
    required String logisticsName,
    required String logisticsCostText,
    required String customsCostText,
    required String insuranceCostText,
    required String notes,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateImportForm(
          title: title,
          supplierName: supplierName,
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
      final totals = ExportTotals.fromCostTexts(
        items: items,
        logisticsCostText: logisticsCostText,
        customsCostText: customsCostText,
        insuranceCostText: insuranceCostText,
      );
      final id = await _importService.createImport(
        title: title,
        supplierName: supplierName,
        currency: currency,
        items: items,
        totals: totals,
        shipmentDate: shipmentDate,
        deliveryDate: deliveryDate,
        logisticsName: logisticsName,
        logisticsCostMinor: _optionalAmount(logisticsCostText),
        customsCostMinor: _optionalAmount(customsCostText),
        insuranceCostMinor: _optionalAmount(insuranceCostText),
        notes: notes,
      );
      successMessage.value = ImportMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = ImportMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getImportById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedImport.value = null;
    isLoading.value = true;
    try {
      final detail = await _importService.getImportById(id);
      if (detail == null) {
        errorMessage.value = ImportMessages.notFound;
        selectedImport.value = null;
        return false;
      }

      selectedImport.value = detail;
      return true;
    } catch (_) {
      errorMessage.value = ImportMessages.notFound;
      selectedImport.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateImport({
    required String id,
    required String title,
    required String supplierName,
    required PriceOfferCurrencyType currency,
    required List<ExportItemData> items,
    required List<ExportItemValidationInput> itemInputs,
    required DateTime? shipmentDate,
    required DateTime? deliveryDate,
    required String logisticsName,
    required String logisticsCostText,
    required String customsCostText,
    required String insuranceCostText,
    required String notes,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateImportForm(
          title: title,
          supplierName: supplierName,
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
      final totals = ExportTotals.fromCostTexts(
        items: items,
        logisticsCostText: logisticsCostText,
        customsCostText: customsCostText,
        insuranceCostText: insuranceCostText,
      );
      await _importService.updateImport(
        id: id,
        title: title,
        supplierName: supplierName,
        currency: currency,
        items: items,
        totals: totals,
        shipmentDate: shipmentDate,
        deliveryDate: deliveryDate,
        logisticsName: logisticsName,
        logisticsCostMinor: _optionalAmount(logisticsCostText),
        customsCostMinor: _optionalAmount(customsCostText),
        insuranceCostMinor: _optionalAmount(insuranceCostText),
        notes: notes,
      );
      return true;
    } catch (_) {
      errorMessage.value = ImportMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteImport(String id) async {
    if (isDeleting.value || deletingImportId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingImportId.value = id;
    try {
      await _importService.deleteImport(id);
      imports.removeWhere((record) => record.id == id);
      successMessage.value = ImportMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ImportMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingImportId.value = null;
    }
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
                              ImportMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              ImportMessages.deleteBody,
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
                          ImportMessages.deleteCancel,
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
                          ImportMessages.deleteConfirm,
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
