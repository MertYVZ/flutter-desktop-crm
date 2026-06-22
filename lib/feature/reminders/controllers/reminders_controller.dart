import 'package:Ok/feature/reminders/models/reminder_date_state_filter.dart';
import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/feature/reminders/services/reminders_export_service.dart';
import 'package:Ok/feature/reminders/services/reminders_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/reminder_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class RemindersController extends GetxController {
  RemindersController(
    this._remindersService,
    this._exportService,
  );

  final RemindersService _remindersService;
  final RemindersExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<ReminderListItem> reminders = <ReminderListItem>[].obs;
  final Rxn<ReminderListItem> selectedReminder = Rxn<ReminderListItem>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<ReminderPeriod> selectedPeriodFilter = Rxn<ReminderPeriod>();
  final Rxn<ReminderStatus> selectedStatusFilter = Rxn<ReminderStatus>();
  final Rxn<ReminderDateStateFilter> selectedDateStateFilter =
      Rxn<ReminderDateStateFilter>();
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingReminderId = RxnString();
  final RxnString completingReminderId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedPeriodFilter.value != null ||
      selectedStatusFilter.value != null ||
      selectedDateStateFilter.value != null ||
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

  Future<void> loadReminders() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _remindersService.getReminders();
      reminders.assignAll(result);
    } catch (_) {
      errorMessage.value = ReminderMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _remindersService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> searchAndFilterReminders() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    filterWarningMessage.value = null;

    if (hasInvalidDateRange) {
      filterWarningMessage.value = ReminderMessages.dateRangeError;
      return;
    }

    isLoading.value = true;
    try {
      final result = await _remindersService.searchReminders(
        searchQuery: searchQuery.value,
        periodFilter: selectedPeriodFilter.value,
        statusFilter: selectedStatusFilter.value,
        dateStateFilter: selectedDateStateFilter.value,
        startDate: startDateFilter.value,
        endDate: endDateFilter.value,
      );
      reminders.assignAll(result);
    } catch (_) {
      errorMessage.value = ReminderMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createReminder({
    required String? customerId,
    required String title,
    required ReminderPeriod? period,
    required DateTime? startDate,
    required String note,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateReminderForm(
      customerId: customerId,
      title: title,
      period: period,
      startDate: startDate,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final id = await _remindersService.createReminder(
        customerId: customerId!,
        title: title,
        period: period!,
        startDate: startDate!,
        note: note,
      );
      successMessage.value = ReminderMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = ReminderMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getReminderById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedReminder.value = null;
    isLoading.value = true;
    try {
      final reminder = await _remindersService.getReminderById(id);
      if (reminder == null) {
        errorMessage.value = ReminderMessages.notFound;
        selectedReminder.value = null;
        return false;
      }

      selectedReminder.value = reminder;
      return true;
    } catch (_) {
      errorMessage.value = ReminderMessages.notFound;
      selectedReminder.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateReminder({
    required String id,
    required String? customerId,
    required String title,
    required ReminderPeriod? period,
    required DateTime? startDate,
    required DateTime? nextReminderDate,
    required ReminderStatus? status,
    required String note,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateReminderForm(
      customerId: customerId,
      title: title,
      period: period,
      startDate: startDate,
      nextReminderDate: nextReminderDate,
      status: status,
      requireNextReminderDate: true,
      requireStatus: true,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      await _remindersService.updateReminder(
        id: id,
        customerId: customerId!,
        title: title,
        period: period!,
        startDate: startDate!,
        nextReminderDate: nextReminderDate!,
        status: status!,
        note: note,
      );
      successMessage.value = ReminderMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ReminderMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> completeReminder(String id) async {
    if (isCompleting.value || completingReminderId.value == id) {
      return false;
    }

    final confirmed = await _showCompleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isCompleting.value = true;
    completingReminderId.value = id;
    try {
      await _remindersService.completeReminder(id);
      successMessage.value = ReminderMessages.completeSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ReminderMessages.completeError;
      return false;
    } finally {
      isCompleting.value = false;
      completingReminderId.value = null;
    }
  }

  Future<bool> deleteReminder(String id) async {
    if (isDeleting.value || deletingReminderId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingReminderId.value = id;
    try {
      await _remindersService.deleteReminder(id);
      reminders.removeWhere((reminder) => reminder.id == id);
      if (selectedReminder.value?.id == id) {
        selectedReminder.value = null;
      }
      successMessage.value = ReminderMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ReminderMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingReminderId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    if (reminders.isEmpty) {
      errorMessage.value = ReminderMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final exported =
          await _exportService.exportRemindersToExcel(reminders.toList());
      if (!exported) {
        return false;
      }
      successMessage.value = ReminderMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = ReminderMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedPeriodFilter.value = null;
    selectedStatusFilter.value = null;
    selectedDateStateFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    filterWarningMessage.value = null;
    searchAndFilterReminders();
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await Get.dialog<bool>(
      _buildConfirmDialog(
        title: ReminderMessages.deleteTitle,
        body: ReminderMessages.deleteBody,
        cancelLabel: ReminderMessages.deleteCancel,
        confirmLabel: ReminderMessages.deleteConfirm,
        confirmColor: ColorName.error,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
    );

    return result ?? false;
  }

  Future<bool> _showCompleteConfirmDialog() async {
    final result = await Get.dialog<bool>(
      _buildConfirmDialog(
        title: ReminderMessages.completeTitle,
        body: ReminderMessages.completeBody,
        cancelLabel: ReminderMessages.completeCancel,
        confirmLabel: ReminderMessages.completeConfirm,
        confirmColor: ColorName.primary,
        icon: Icons.check_circle_outline_rounded,
        iconBackgroundColor: AppUiTokens.accentSoft,
        iconColor: ColorName.primary,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
    );

    return result ?? false;
  }

  Widget _buildConfirmDialog({
    required String title,
    required String body,
    required String cancelLabel,
    required String confirmLabel,
    required Color confirmColor,
    IconData icon = Icons.delete_outline_rounded,
    Color iconBackgroundColor = const Color(0xFFFEF2F2),
    Color iconColor = ColorName.error,
  }) {
    return Dialog(
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
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppUiTokens.radiusMd,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppUiTokens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppUiTokens.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppUiTokens.space8),
                          Text(
                            body,
                            style: const TextStyle(
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
                      child: Text(
                        cancelLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: AppUiTokens.space8),
                    FilledButton(
                      onPressed: () => Get.back<bool>(result: true),
                      style: AppInteractiveTheme.filledButtonStyle(
                        FilledButton.styleFrom(
                          backgroundColor: confirmColor,
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
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
