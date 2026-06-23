import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
import 'package:Ok/feature/price_list/models/price_list_list_item.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/feature/price_list/services/price_list_export_service.dart';
import 'package:Ok/feature/price_list/services/price_list_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/price_list_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class PriceListController extends GetxController {
  PriceListController(
    this._priceListService,
    this._exportService,
  );

  final PriceListService _priceListService;
  final PriceListExportService _exportService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxBool isArchiving = false.obs;

  final Rxn<PriceList> activePriceList = Rxn<PriceList>();
  final RxList<PriceListItemModel> activeItems = <PriceListItemModel>[].obs;
  final RxList<PriceListListItem> archivedLists = <PriceListListItem>[].obs;
  final Rxn<PriceList> selectedPriceList = Rxn<PriceList>();
  final RxList<PriceListItemModel> selectedItems = <PriceListItemModel>[].obs;

  final RxString productSearchQuery = ''.obs;
  final Rxn<PriceListCurrency> productCurrencyFilter = Rxn<PriceListCurrency>();

  final RxString archiveSearchQuery = ''.obs;
  final Rxn<DateTime> archiveStartDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> archiveEndDateFilter = Rxn<DateTime>();

  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingItemId = RxnString();

  bool get hasActiveProductFilters =>
      productSearchQuery.value.trim().isNotEmpty ||
      productCurrencyFilter.value != null;

  bool get hasActiveArchiveFilters =>
      archiveSearchQuery.value.trim().isNotEmpty ||
      archiveStartDateFilter.value != null ||
      archiveEndDateFilter.value != null;

  bool get hasInvalidArchiveDateRange {
    final start = archiveStartDateFilter.value;
    final end = archiveEndDateFilter.value;
    if (start == null || end == null) {
      return false;
    }
    return start.isAfter(end);
  }

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<void> loadActiveSection() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final list = await _priceListService.getActivePriceList();
      activePriceList.value = list;

      if (list != null) {
        final items = await _priceListService.getItemsByPriceListId(
          list.id,
          searchQuery: productSearchQuery.value,
          currencyFilter: productCurrencyFilter.value?.value,
        );
        activeItems.assignAll(items);
      } else {
        activeItems.clear();
      }
    } catch (_) {
      errorMessage.value = PriceListMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchActiveItems() async {
    final list = activePriceList.value;
    if (list == null) {
      activeItems.clear();
      return;
    }

    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final items = await _priceListService.getItemsByPriceListId(
        list.id,
        searchQuery: productSearchQuery.value,
        currencyFilter: productCurrencyFilter.value?.value,
      );
      activeItems.assignAll(items);
    } catch (_) {
      errorMessage.value = PriceListMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadArchivedLists() async {
    filterWarningMessage.value = null;

    if (hasInvalidArchiveDateRange) {
      filterWarningMessage.value = PriceListMessages.dateRangeError;
      return;
    }

    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final lists = await _priceListService.getArchivedPriceLists(
        searchQuery: archiveSearchQuery.value,
        startDate: archiveStartDateFilter.value,
        endDate: archiveEndDateFilter.value,
      );
      archivedLists.assignAll(lists);
    } catch (_) {
      errorMessage.value = PriceListMessages.archiveError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPageData() async {
    await loadActiveSection();
    await loadArchivedLists();
  }

  Future<bool> getPriceListById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedPriceList.value = null;
    selectedItems.clear();
    isLoading.value = true;

    try {
      final list = await _priceListService.getPriceListById(id);
      if (list == null) {
        errorMessage.value = PriceListMessages.notFound;
        return false;
      }

      selectedPriceList.value = list;
      final items = await _priceListService.getItemsByPriceListId(list.id);
      selectedItems.assignAll(items);
      return true;
    } catch (_) {
      errorMessage.value = PriceListMessages.notFound;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createPriceList({
    required String title,
    required DateTime? effectiveDate,
    required String description,
    required bool copyFromActive,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validatePriceListForm(
      title: title,
      effectiveDate: effectiveDate,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final id = await _priceListService.createActivePriceList(
        title: title,
        effectiveDate: effectiveDate!,
        description: description,
        copyFromActive: copyFromActive,
      );
      successMessage.value = PriceListMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = PriceListMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updatePriceList({
    required String id,
    required String title,
    required DateTime? effectiveDate,
    required String description,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final list = await _priceListService.getPriceListById(id);
    if (list == null) {
      errorMessage.value = PriceListMessages.notFound;
      return false;
    }

    if (list.status != PriceListStatus.active.value) {
      errorMessage.value = PriceListMessages.notEditable;
      return false;
    }

    final validationError = Validators.validatePriceListForm(
      title: title,
      effectiveDate: effectiveDate,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      await _priceListService.updatePriceList(
        id: id,
        title: title,
        effectiveDate: effectiveDate!,
        description: description,
      );
      successMessage.value = PriceListMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceListMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> archiveActivePriceList() async {
    final list = activePriceList.value;
    if (list == null || isArchiving.value) {
      return false;
    }

    final confirmed = await _showArchiveConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isArchiving.value = true;
    try {
      await _priceListService.archivePriceList(list.id);
      activePriceList.value = null;
      activeItems.clear();
      successMessage.value = PriceListMessages.archiveSuccess;
      await loadArchivedLists();
      return true;
    } catch (_) {
      errorMessage.value = PriceListMessages.archiveError;
      return false;
    } finally {
      isArchiving.value = false;
    }
  }

  Future<bool> createItem({
    required String priceListId,
    required String productName,
    required PriceListCurrency? currency,
    required String minPriceText,
    required String maxPriceText,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validatePriceListItemForm(
      productName: productName,
      currency: currency,
      minPriceText: minPriceText,
      maxPriceText: maxPriceText,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      await _priceListService.createItem(
        priceListId: priceListId,
        productName: productName,
        currency: currency!,
        minPriceMinor: MoneyUtils.parseAmountToMinor(minPriceText.trim())!,
        maxPriceMinor: MoneyUtils.parseAmountToMinor(maxPriceText.trim())!,
      );
      successMessage.value = PriceListMessages.itemCreateSuccess;
      await loadActiveSection();
      return true;
    } on Exception catch (error) {
      if (error.toString().contains('duplicate')) {
        errorMessage.value = PriceListMessages.duplicateProduct;
      } else {
        errorMessage.value = PriceListMessages.itemCreateError;
      }
      return false;
    } catch (_) {
      errorMessage.value = PriceListMessages.itemCreateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateItem({
    required String id,
    required String productName,
    required PriceListCurrency? currency,
    required String minPriceText,
    required String maxPriceText,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validatePriceListItemForm(
      productName: productName,
      currency: currency,
      minPriceText: minPriceText,
      maxPriceText: maxPriceText,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSaving.value = true;
    try {
      await _priceListService.updateItem(
        id: id,
        productName: productName,
        currency: currency!,
        minPriceMinor: MoneyUtils.parseAmountToMinor(minPriceText.trim())!,
        maxPriceMinor: MoneyUtils.parseAmountToMinor(maxPriceText.trim())!,
      );
      successMessage.value = PriceListMessages.itemUpdateSuccess;
      await loadActiveSection();
      return true;
    } on Exception catch (error) {
      if (error.toString().contains('duplicate')) {
        errorMessage.value = PriceListMessages.duplicateProduct;
      } else {
        errorMessage.value = PriceListMessages.itemUpdateError;
      }
      return false;
    } catch (_) {
      errorMessage.value = PriceListMessages.itemUpdateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteItem(String id) async {
    if (isDeleting.value || deletingItemId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteItemConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingItemId.value = id;
    try {
      await _priceListService.deleteItem(id);
      activeItems.removeWhere((item) => item.id == id);
      selectedItems.removeWhere((item) => item.id == id);
      successMessage.value = PriceListMessages.itemDeleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceListMessages.itemDeleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingItemId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    final list = activePriceList.value;
    if (list == null || activeItems.isEmpty) {
      errorMessage.value = PriceListMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final allItems = await _priceListService.getItemsByPriceListId(list.id);
      if (allItems.isEmpty) {
        errorMessage.value = PriceListMessages.exportEmpty;
        return false;
      }

      final exported = await _exportService.exportPriceListToExcel(
        items: allItems,
      );
      if (!exported) {
        return false;
      }
      successMessage.value = PriceListMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceListMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void clearProductFilters() {
    productSearchQuery.value = '';
    productCurrencyFilter.value = null;
    searchActiveItems();
  }

  void clearArchiveFilters() {
    archiveSearchQuery.value = '';
    archiveStartDateFilter.value = null;
    archiveEndDateFilter.value = null;
    filterWarningMessage.value = null;
    loadArchivedLists();
  }

  Future<bool> _showArchiveConfirmDialog() async {
    final result = await Get.dialog<bool>(
      _ConfirmDialog(
        icon: Icons.archive_outlined,
        iconColor: ColorName.primary,
        iconBackground: AppUiTokens.accentSoft,
        title: PriceListMessages.archiveTitle,
        body: PriceListMessages.archiveBody,
        cancelLabel: PriceListMessages.archiveCancel,
        confirmLabel: PriceListMessages.archiveConfirm,
        confirmColor: ColorName.primary,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
    );

    return result ?? false;
  }

  Future<bool> _showDeleteItemConfirmDialog() async {
    final result = await Get.dialog<bool>(
      _ConfirmDialog(
        icon: Icons.delete_outline_rounded,
        iconColor: ColorName.error,
        iconBackground: const Color(0xFFFEF2F2),
        title: PriceListMessages.deleteItemTitle,
        body: PriceListMessages.deleteItemBody,
        cancelLabel: PriceListMessages.deleteItemCancel,
        confirmLabel: PriceListMessages.deleteItemConfirm,
        confirmColor: ColorName.error,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
    );

    return result ?? false;
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                        color: iconBackground,
                        borderRadius:
                            BorderRadius.circular(AppUiTokens.radiusMd),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
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
                            borderRadius:
                                BorderRadius.circular(AppUiTokens.radiusSm),
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
