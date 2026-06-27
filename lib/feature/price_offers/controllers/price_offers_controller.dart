import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/feature/price_offers/services/price_offer_pdf_service.dart';
import 'package:Ok/feature/price_offers/services/price_offers_export_service.dart';
import 'package:Ok/feature/price_offers/services/price_offers_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/price_offer_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class PriceOffersController extends GetxController {
  PriceOffersController(
    this._priceOffersService,
    this._exportService,
    this._pdfService,
  );

  final PriceOffersService _priceOffersService;
  final PriceOffersExportService _exportService;
  final PriceOfferPdfService _pdfService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxBool isGeneratingPdf = false.obs;
  final RxList<PriceOfferListItem> offers = <PriceOfferListItem>[].obs;
  final Rxn<PriceOfferDetail> selectedOffer = Rxn<PriceOfferDetail>();
  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<CustomerContactItem> customerContacts =
      <CustomerContactItem>[].obs;
  final RxBool isLoadingContacts = false.obs;
  final RxString searchQuery = ''.obs;
  final Rxn<OfferType> selectedTypeFilter = Rxn<OfferType>();
  final Rxn<PriceOfferStatus> selectedStatusFilter = Rxn<PriceOfferStatus>();
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString filterWarningMessage = RxnString();
  final RxnString deletingOfferId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedTypeFilter.value != null ||
      selectedStatusFilter.value != null ||
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

  Future<void> loadOffers() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _priceOffersService.getOffers();
      offers.assignAll(result);
    } catch (_) {
      errorMessage.value = PriceOfferMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomersForDropdown() async {
    try {
      final result = await _priceOffersService.getSelectableCustomers();
      customers.assignAll(result);
    } catch (_) {
      customers.clear();
    }
  }

  Future<void> loadCustomerContacts(String? customerId) async {
    if (customerId == null || customerId.isEmpty) {
      customerContacts.clear();
      return;
    }

    if (isLoadingContacts.value) {
      return;
    }

    isLoadingContacts.value = true;
    try {
      final result = await _priceOffersService.getCustomerContacts(customerId);
      customerContacts.assignAll(result);
    } catch (_) {
      customerContacts.clear();
    } finally {
      isLoadingContacts.value = false;
    }
  }

  Future<void> searchAndFilterOffers() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    filterWarningMessage.value = null;

    if (hasInvalidDateRange) {
      filterWarningMessage.value = PriceOfferMessages.dateRangeError;
      return;
    }

    isLoading.value = true;
    try {
      final result = await _priceOffersService.searchOffers(
        searchQuery: searchQuery.value,
        typeFilter: selectedTypeFilter.value,
        statusFilter: selectedStatusFilter.value,
        startDate: startDateFilter.value,
        endDate: endDateFilter.value,
      );
      offers.assignAll(result);
    } catch (_) {
      errorMessage.value = PriceOfferMessages.createError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createOffer({
    required OfferType? type,
    required DateTime? offerDate,
    required DateTime? validityDate,
    required String? customerId,
    required String contactPerson,
    required String authorizedPhone,
    required String mobilePhone,
    required String legalText,
    required List<PriceOfferItemFormValidation> itemValidations,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validatePriceOfferForm(
      type: type,
      offerDate: offerDate,
      validityDate: validityDate,
      customerId: customerId,
      contactPerson: contactPerson,
      legalText: legalText,
      authorizedPhone: authorizedPhone,
      mobilePhone: mobilePhone,
      items: itemValidations,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    final items = _mapItemInputs(itemValidations);
    if (items == null) {
      return null;
    }

    isSaving.value = true;
    try {
      final id = await _priceOffersService.createOffer(
        type: type!,
        offerDate: offerDate!,
        validityDate: validityDate!,
        customerId: customerId!,
        contactPerson: contactPerson,
        authorizedPhone: authorizedPhone,
        mobilePhone: mobilePhone,
        legalText: legalText,
        items: items,
      );
      successMessage.value = PriceOfferMessages.createSuccess;
      return id;
    } catch (_) {
      errorMessage.value = PriceOfferMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getOfferById(String id) async {
    if (isLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedOffer.value = null;
    isLoading.value = true;
    try {
      final offer = await _priceOffersService.getOfferById(id);
      if (offer == null) {
        errorMessage.value = PriceOfferMessages.notFound;
        selectedOffer.value = null;
        return false;
      }

      selectedOffer.value = offer;
      return true;
    } catch (_) {
      errorMessage.value = PriceOfferMessages.notFound;
      selectedOffer.value = null;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateOffer({
    required String id,
    required OfferType? type,
    required DateTime? offerDate,
    required DateTime? validityDate,
    required String? customerId,
    required String contactPerson,
    required String authorizedPhone,
    required String mobilePhone,
    required String legalText,
    required PriceOfferStatus? status,
    required List<PriceOfferItemFormValidation> itemValidations,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validatePriceOfferForm(
      type: type,
      offerDate: offerDate,
      validityDate: validityDate,
      customerId: customerId,
      contactPerson: contactPerson,
      legalText: legalText,
      authorizedPhone: authorizedPhone,
      mobilePhone: mobilePhone,
      items: itemValidations,
      status: status,
      requireStatus: true,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    final items = _mapItemInputs(itemValidations);
    if (items == null) {
      return false;
    }

    isSaving.value = true;
    try {
      await _priceOffersService.updateOffer(
        id: id,
        type: type!,
        offerDate: offerDate!,
        validityDate: validityDate!,
        customerId: customerId!,
        contactPerson: contactPerson,
        authorizedPhone: authorizedPhone,
        mobilePhone: mobilePhone,
        legalText: legalText,
        status: status!,
        items: items,
      );
      successMessage.value = PriceOfferMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceOfferMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteOffer(String id) async {
    if (isDeleting.value || deletingOfferId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingOfferId.value = id;
    try {
      await _priceOffersService.deleteOffer(id);
      offers.removeWhere((offer) => offer.id == id);
      if (selectedOffer.value?.id == id) {
        selectedOffer.value = null;
      }
      successMessage.value = PriceOfferMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceOfferMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingOfferId.value = null;
    }
  }

  Future<bool> exportToExcel() async {
    if (isExporting.value) {
      return false;
    }

    clearMessages();

    if (offers.isEmpty) {
      errorMessage.value = PriceOfferMessages.exportEmpty;
      return false;
    }

    isExporting.value = true;
    try {
      final exported =
          await _exportService.exportOffersToExcel(offers.toList());
      if (!exported) {
        return false;
      }
      successMessage.value = PriceOfferMessages.exportSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceOfferMessages.exportError;
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  Future<bool> generateOfferPdf(String offerId) async {
    if (isGeneratingPdf.value) {
      return false;
    }

    clearMessages();

    var offer = selectedOffer.value;
    if (offer == null || offer.id != offerId) {
      final loaded = await getOfferById(offerId);
      if (!loaded) {
        return false;
      }
      offer = selectedOffer.value;
    }

    if (offer == null) {
      errorMessage.value = PriceOfferMessages.notFound;
      return false;
    }

    isGeneratingPdf.value = true;
    try {
      final generated = await _pdfService.generateAndSavePdf(offer: offer);
      if (!generated) {
        return false;
      }
      successMessage.value = PriceOfferMessages.pdfSuccess;
      return true;
    } catch (_) {
      errorMessage.value = PriceOfferMessages.pdfError;
      return false;
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedTypeFilter.value = null;
    selectedStatusFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    filterWarningMessage.value = null;
    searchAndFilterOffers();
  }

  List<PriceOfferItemInput>? _mapItemInputs(
    List<PriceOfferItemFormValidation> validations,
  ) {
    final items = <PriceOfferItemInput>[];

    for (final item in validations) {
      final quantity = QuantityUtils.parseQuantity(item.quantityText);
      final priceMinor = MoneyUtils.parseAmountToMinor(item.priceText);
      final currency = item.currency;

      if (quantity == null ||
          priceMinor == null ||
          currency == null ||
          quantity <= 0 ||
          priceMinor < 0) {
        return null;
      }

      items.add(
        PriceOfferItemInput(
          productName: item.productName,
          unitType: item.unitType,
          quantity: quantity,
          priceMinor: priceMinor,
          currency: currency,
        ),
      );
    }

    return items;
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
                              PriceOfferMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              PriceOfferMessages.deleteBody,
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
                          PriceOfferMessages.deleteCancel,
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
                          PriceOfferMessages.deleteConfirm,
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
