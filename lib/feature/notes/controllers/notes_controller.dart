import 'package:Ok/feature/notes/models/note_customer_filter.dart';
import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/feature/notes/services/notes_export_service.dart';
import 'package:Ok/feature/notes/services/notes_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/note_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class NotesController extends GetxController {
  NotesController(
    this._notesService,
    this._exportService,
  );

  final NotesService _notesService;
  final NotesExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<NoteListItem> notes = <NoteListItem>[].obs;
  final Rxn<NoteListItem> selectedNote = Rxn<NoteListItem>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<NoteCustomerFilter> selectedCustomerFilter = Rxn<NoteCustomerFilter>();
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingNoteId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedCustomerFilter.value != null ||
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

  Future<void> loadNotes() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _notesService.getNotes();
      notes.assignAll(result);
    } catch (_) {
      errorMessage.value = NoteMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _notesService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> searchAndFilterNotes() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    filterWarningMessage.value = null;

    if (hasInvalidDateRange) {
      filterWarningMessage.value = NoteMessages.dateRangeError;
      return;
    }

    isLoading.value = true;
    try {
      final result = await _notesService.searchNotes(
        searchQuery: searchQuery.value,
        customerFilter: selectedCustomerFilter.value,
        startDate: startDateFilter.value,
        endDate: endDateFilter.value,
      );
      notes.assignAll(result);
    } catch (_) {
      errorMessage.value = NoteMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createNote({
    required String? customerId,
    required String title,
    required String content,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateNoteForm(
      title: title,
      content: content,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final id = await _notesService.createNote(
        customerId: customerId,
        title: title,
        content: content,
      );
      successMessage.value = NoteMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = NoteMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getNoteById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedNote.value = null;
    isLoading.value = true;
    try {
      final note = await _notesService.getNoteById(id);
      if (note == null) {
        errorMessage.value = NoteMessages.notFound;
        selectedNote.value = null;
        return false;
      }

      selectedNote.value = note;
      return true;
    } catch (_) {
      errorMessage.value = NoteMessages.notFound;
      selectedNote.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateNote({
    required String id,
    required String? customerId,
    required String title,
    required String content,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateNoteForm(
      title: title,
      content: content,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      await _notesService.updateNote(
        id: id,
        customerId: customerId,
        title: title,
        content: content,
      );
      successMessage.value = NoteMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = NoteMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteNote(String id) async {
    if (isDeleting.value || deletingNoteId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingNoteId.value = id;
    try {
      await _notesService.deleteNote(id);
      notes.removeWhere((note) => note.id == id);
      if (selectedNote.value?.id == id) {
        selectedNote.value = null;
      }
      successMessage.value = NoteMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = NoteMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingNoteId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    if (notes.isEmpty) {
      errorMessage.value = NoteMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final exported =
          await _exportService.exportNotesToExcel(notes.toList());
      if (!exported) {
        return false;
      }
      successMessage.value = NoteMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = NoteMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCustomerFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    filterWarningMessage.value = null;
    searchAndFilterNotes();
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
                              NoteMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              NoteMessages.deleteBody,
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
                          NoteMessages.deleteCancel,
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
                          NoteMessages.deleteConfirm,
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
