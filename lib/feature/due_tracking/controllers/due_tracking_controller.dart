import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_list_item.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/feature/due_tracking/services/due_tracking_export_service.dart';
import 'package:Ok/feature/due_tracking/services/due_tracking_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/due_record_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class DueTrackingController extends GetxController {
  DueTrackingController(
    this._dueTrackingService,
    this._exportService,
  );

  final DueTrackingService _dueTrackingService;
  final DueTrackingExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<DueRecordListItem> dueRecords = <DueRecordListItem>[].obs;
  final Rxn<DueRecord> selectedDueRecord = Rxn<DueRecord>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<DueRecordDisplayStatusFilter> selectedStatusFilter =
      Rxn<DueRecordDisplayStatusFilter>();
  final Rxn<CurrencyType> selectedCurrencyFilter = Rxn<CurrencyType>();
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingDueRecordId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedStatusFilter.value != null ||
      selectedCurrencyFilter.value != null ||
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

  Future<void> loadDueRecords() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _dueTrackingService.getDueRecords();
      dueRecords.assignAll(result);
    } catch (_) {
      errorMessage.value = DueRecordMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _dueTrackingService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> searchAndFilterDueRecords() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    filterWarningMessage.value = null;

    if (hasInvalidDateRange) {
      filterWarningMessage.value = DueRecordMessages.dateRangeError;
      return;
    }

    isLoading.value = true;
    try {
      final result = await _dueTrackingService.searchDueRecords(
        searchQuery: searchQuery.value,
        statusFilter: selectedStatusFilter.value,
        currencyFilter: selectedCurrencyFilter.value,
        startDate: startDateFilter.value,
        endDate: endDateFilter.value,
      );
      dueRecords.assignAll(result);
    } catch (_) {
      errorMessage.value = DueRecordMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createDueRecord({
    required String? customerId,
    required DateTime? dueDate,
    required String amountText,
    required CurrencyType? currency,
    required String invoiceNo,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateDueRecordForm(
      customerId: customerId,
      dueDate: dueDate,
      amountText: amountText,
      currency: currency,
      invoiceNo: invoiceNo,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final amountMinor = MoneyUtils.parseAmountToMinor(amountText.trim())!;
      final id = await _dueTrackingService.createDueRecord(
        customerId: customerId!,
        invoiceNo: invoiceNo,
        amountMinor: amountMinor,
        currency: currency!,
        dueDate: dueDate!,
      );
      successMessage.value = DueRecordMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = DueRecordMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getDueRecordById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedDueRecord.value = null;
    isLoading.value = true;
    try {
      final record = await _dueTrackingService.getDueRecordById(id);
      if (record == null) {
        errorMessage.value = DueRecordMessages.notFound;
        selectedDueRecord.value = null;
        return false;
      }

      selectedDueRecord.value = record;
      return true;
    } catch (_) {
      errorMessage.value = DueRecordMessages.notFound;
      selectedDueRecord.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDueRecord({
    required String id,
    required String? customerId,
    required DateTime? dueDate,
    required String amountText,
    required CurrencyType? currency,
    required String invoiceNo,
    required DueRecordStatus? status,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateDueRecordForm(
      customerId: customerId,
      dueDate: dueDate,
      amountText: amountText,
      currency: currency,
      invoiceNo: invoiceNo,
      status: status,
      requireStatus: true,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      final amountMinor = MoneyUtils.parseAmountToMinor(amountText.trim())!;
      await _dueTrackingService.updateDueRecord(
        id: id,
        customerId: customerId!,
        invoiceNo: invoiceNo,
        amountMinor: amountMinor,
        currency: currency!,
        dueDate: dueDate!,
        status: status!,
      );
      return true;
    } catch (_) {
      errorMessage.value = DueRecordMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDueRecord(String id) async {
    if (isDeleting.value || deletingDueRecordId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingDueRecordId.value = id;
    try {
      await _dueTrackingService.deleteDueRecord(id);
      dueRecords.removeWhere((record) => record.id == id);
      successMessage.value = DueRecordMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = DueRecordMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingDueRecordId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    if (dueRecords.isEmpty) {
      errorMessage.value = DueRecordMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final exported =
          await _exportService.exportDueRecordsToExcel(dueRecords.toList());
      if (!exported) {
        return false;
      }
      successMessage.value = DueRecordMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = DueRecordMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatusFilter.value = null;
    selectedCurrencyFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    filterWarningMessage.value = null;
    searchAndFilterDueRecords();
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
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
                              DueRecordMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              DueRecordMessages.deleteBody,
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
                          DueRecordMessages.deleteCancel,
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
                          DueRecordMessages.deleteConfirm,
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
