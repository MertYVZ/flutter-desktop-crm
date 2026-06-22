import 'package:Ok/feature/meetings/models/meeting_list_item.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/feature/meetings/services/meetings_export_service.dart';
import 'package:Ok/feature/meetings/services/meetings_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/meeting_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class MeetingsController extends GetxController {
  MeetingsController(
    this._meetingsService,
    this._exportService,
  );

  final MeetingsService _meetingsService;
  final MeetingsExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<MeetingListItem> meetings = <MeetingListItem>[].obs;
  final Rxn<MeetingListItem> selectedMeeting = Rxn<MeetingListItem>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<MeetingMethod> selectedMethodFilter = Rxn<MeetingMethod>();
  final Rxn<MeetingSubject> selectedSubjectFilter = Rxn<MeetingSubject>();
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingMeetingId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedMethodFilter.value != null ||
      selectedSubjectFilter.value != null ||
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

  Future<void> loadMeetings() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _meetingsService.getMeetings();
      meetings.assignAll(result);
    } catch (_) {
      errorMessage.value = MeetingMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _meetingsService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> searchAndFilterMeetings() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    filterWarningMessage.value = null;

    if (hasInvalidDateRange) {
      filterWarningMessage.value = MeetingMessages.dateRangeError;
      return;
    }

    isLoading.value = true;
    try {
      final result = await _meetingsService.searchMeetings(
        searchQuery: searchQuery.value,
        methodFilter: selectedMethodFilter.value,
        subjectFilter: selectedSubjectFilter.value,
        startDate: startDateFilter.value,
        endDate: endDateFilter.value,
      );
      meetings.assignAll(result);
    } catch (_) {
      errorMessage.value = MeetingMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createMeeting({
    required String? customerId,
    required DateTime? date,
    required MeetingMethod? method,
    required MeetingSubject? subject,
    required String notes,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateMeetingForm(
      customerId: customerId,
      date: date,
      method: method,
      subject: subject,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final id = await _meetingsService.createMeeting(
        customerId: customerId!,
        date: date!,
        method: method!,
        subject: subject!,
        notes: notes,
      );
      successMessage.value = MeetingMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = MeetingMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getMeetingById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedMeeting.value = null;
    isLoading.value = true;
    try {
      final meeting = await _meetingsService.getMeetingById(id);
      if (meeting == null) {
        errorMessage.value = MeetingMessages.notFound;
        selectedMeeting.value = null;
        return false;
      }

      selectedMeeting.value = meeting;
      return true;
    } catch (_) {
      errorMessage.value = MeetingMessages.notFound;
      selectedMeeting.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMeeting({
    required String id,
    required String? customerId,
    required DateTime? date,
    required MeetingMethod? method,
    required MeetingSubject? subject,
    required String notes,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateMeetingForm(
      customerId: customerId,
      date: date,
      method: method,
      subject: subject,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      await _meetingsService.updateMeeting(
        id: id,
        customerId: customerId!,
        date: date!,
        method: method!,
        subject: subject!,
        notes: notes,
      );
      successMessage.value = MeetingMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = MeetingMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteMeeting(String id) async {
    if (isDeleting.value || deletingMeetingId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingMeetingId.value = id;
    try {
      await _meetingsService.deleteMeeting(id);
      meetings.removeWhere((meeting) => meeting.id == id);
      if (selectedMeeting.value?.id == id) {
        selectedMeeting.value = null;
      }
      successMessage.value = MeetingMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = MeetingMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingMeetingId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    if (meetings.isEmpty) {
      errorMessage.value = MeetingMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final exported =
          await _exportService.exportMeetingsToExcel(meetings.toList());
      if (!exported) {
        return false;
      }
      successMessage.value = MeetingMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = MeetingMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedMethodFilter.value = null;
    selectedSubjectFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    filterWarningMessage.value = null;
    searchAndFilterMeetings();
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
                              MeetingMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              MeetingMessages.deleteBody,
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
                          MeetingMessages.deleteCancel,
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
                          MeetingMessages.deleteConfirm,
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
