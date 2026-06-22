import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_quality_export_service.dart';
import 'package:Ok/feature/scrap_quality/services/scrap_quality_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class ScrapQualityController extends GetxController {
  ScrapQualityController(
    this._scrapQualityService,
    this._exportService,
  );

  final ScrapQualityService _scrapQualityService;
  final ScrapQualityExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<ScrapQualityListItem> records = <ScrapQualityListItem>[].obs;
  final Rxn<ScrapQualityRecord> selectedRecord = Rxn<ScrapQualityRecord>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<ScrapQualityUnit> selectedUnitFilter = Rxn<ScrapQualityUnit>();
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingRecordId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedUnitFilter.value != null ||
      startDateFilter.value != null ||
      endDateFilter.value != null;

  bool get hasInvalidDateRange {
    final start = startDateFilter.value;
    final end = endDateFilter.value;
    if (start == null || end == null) {
      return false;
    }

    return start.isAfter(end);
  }

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<void> loadRecords() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _scrapQualityService.getRecords();
      records.assignAll(result);
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _scrapQualityService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> searchAndFilterRecords() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    filterWarningMessage.value = null;

    if (hasInvalidDateRange) {
      filterWarningMessage.value = ScrapQualityMessages.dateRangeError;
      return;
    }

    isLoading.value = true;
    try {
      final result = await _scrapQualityService.searchRecords(
        searchQuery: searchQuery.value,
        unitFilter: selectedUnitFilter.value?.label,
        startDate: startDateFilter.value,
        endDate: endDateFilter.value,
      );
      records.assignAll(result);
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createRecord({
    required String? customerId,
    required String quality,
    required String quantityText,
    required ScrapQualityUnit? unit,
    required String customUnitText,
    required String note,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateScrapQualityForm(
      customerId: customerId,
      quality: quality,
      quantityText: quantityText,
      unit: unit,
      customUnitText: customUnitText,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final quantity = QuantityUtils.parseQuantity(quantityText.trim())!;
      final resolvedUnit = _resolveUnit(unit!, customUnitText);
      final id = await _scrapQualityService.createRecord(
        customerId: customerId!,
        quality: quality,
        quantity: quantity,
        unit: resolvedUnit,
        recordDate: DateTime.now(),
        note: note,
      );
      successMessage.value = ScrapQualityMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getRecordById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedRecord.value = null;
    isLoading.value = true;
    try {
      final record = await _scrapQualityService.getRecordById(id);
      if (record == null) {
        errorMessage.value = ScrapQualityMessages.notFound;
        selectedRecord.value = null;
        return false;
      }

      selectedRecord.value = record;
      return true;
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.notFound;
      selectedRecord.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateRecord({
    required String id,
    required String? customerId,
    required String quality,
    required String quantityText,
    required ScrapQualityUnit? unit,
    required String customUnitText,
    required DateTime? recordDate,
    required String note,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateScrapQualityForm(
      customerId: customerId,
      quality: quality,
      quantityText: quantityText,
      unit: unit,
      customUnitText: customUnitText,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      final quantity = QuantityUtils.parseQuantity(quantityText.trim())!;
      final resolvedUnit = _resolveUnit(unit!, customUnitText);
      await _scrapQualityService.updateRecord(
        id: id,
        customerId: customerId!,
        quality: quality,
        quantity: quantity,
        unit: resolvedUnit,
        recordDate: recordDate!,
        note: note,
      );
      successMessage.value = ScrapQualityMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    if (isDeleting.value || deletingRecordId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingRecordId.value = id;
    try {
      await _scrapQualityService.deleteRecord(id);
      records.removeWhere((record) => record.id == id);
      successMessage.value = ScrapQualityMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingRecordId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    if (records.isEmpty) {
      errorMessage.value = ScrapQualityMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final exported =
          await _exportService.exportRecordsToExcel(records.toList());
      if (!exported) {
        return false;
      }
      successMessage.value = ScrapQualityMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ScrapQualityMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedUnitFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    filterWarningMessage.value = null;
    searchAndFilterRecords();
  }

  String _resolveUnit(ScrapQualityUnit unit, String customUnitText) {
    if (unit == ScrapQualityUnit.other) {
      return customUnitText.trim();
    }
    return unit.label;
  }

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
                              ScrapQualityMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              ScrapQualityMessages.deleteBody,
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
                          ScrapQualityMessages.deleteCancel,
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
                          ScrapQualityMessages.deleteConfirm,
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
