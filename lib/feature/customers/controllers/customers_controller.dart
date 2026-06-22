import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/feature/customers/services/customers_service.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class CustomersController extends GetxController {
  CustomersController(this._customersService);

  final CustomersService _customersService;

  final RxBool isListLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxList<Customer> customers = <Customer>[].obs;
  final Rxn<Customer> selectedCustomer = Rxn<Customer>();
  final RxString searchQuery = ''.obs;
  final Rxn<CustomerType> selectedTypeFilter = Rxn<CustomerType>();
  final Rxn<CustomerStatus> selectedStatusFilter = Rxn<CustomerStatus>();
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxnString deletingCustomerId = RxnString();

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedTypeFilter.value != null ||
      selectedStatusFilter.value != null;

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<void> loadCustomers() async {
    if (isListLoading.value) {
      return;
    }

    errorMessage.value = null;
    isListLoading.value = true;
    try {
      final result = await _customersService.getCustomers();
      customers.assignAll(result);
    } catch (_) {
      errorMessage.value = CustomerMessages.createError;
    } finally {
      isListLoading.value = false;
    }
  }

  Future<void> searchAndFilterCustomers() async {
    if (isListLoading.value) {
      return;
    }

    errorMessage.value = null;
    isListLoading.value = true;
    try {
      final result = await _customersService.searchCustomers(
        searchQuery: searchQuery.value,
        typeFilter: selectedTypeFilter.value,
        statusFilter: selectedStatusFilter.value,
      );
      customers.assignAll(result);
    } catch (_) {
      errorMessage.value = CustomerMessages.createError;
    } finally {
      isListLoading.value = false;
    }
  }

  Future<String?> createCustomer({
    required String name,
    required CustomerType? type,
    required String phone,
    required String email,
    required String city,
    required String country,
    required String address,
  }) async {
    if (isSaving.value) {
      return null;
    }

    clearMessages();

    final validationError = Validators.validateCustomerForm(
      name: name,
      type: type,
      city: city,
      country: country,
      phone: phone,
      email: email,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    try {
      final id = await _customersService.createCustomer(
        name: name,
        type: type!,
        phone: phone,
        email: email,
        city: city,
        country: country,
        address: address,
      );
      return id;
    } catch (_) {
      errorMessage.value = CustomerMessages.createError;
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> getCustomerById(String id) async {
    if (isDetailLoading.value) {
      return false;
    }

    errorMessage.value = null;
    selectedCustomer.value = null;
    isDetailLoading.value = true;
    try {
      final customer = await _customersService.getCustomerById(id);
      if (customer == null) {
        errorMessage.value = CustomerMessages.notFound;
        selectedCustomer.value = null;
        return false;
      }

      selectedCustomer.value = customer;
      return true;
    } catch (_) {
      errorMessage.value = CustomerMessages.notFound;
      selectedCustomer.value = null;
      return false;
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String name,
    required CustomerType? type,
    required String phone,
    required String email,
    required String city,
    required String country,
    required String address,
    required CustomerStatus? status,
  }) async {
    if (isSaving.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateCustomerForm(
      name: name,
      type: type,
      city: city,
      country: country,
      phone: phone,
      email: email,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    if (status == null) {
      errorMessage.value = CustomerMessages.notFound;
      return false;
    }

    isSaving.value = true;
    try {
      await _customersService.updateCustomer(
        id: id,
        name: name,
        type: type!,
        phone: phone,
        email: email,
        city: city,
        country: country,
        address: address,
        status: status,
      );

      final updated = await _customersService.getCustomerById(id);
      selectedCustomer.value = updated;
      successMessage.value = CustomerMessages.updateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = CustomerMessages.updateError;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    if (isDeleting.value || deletingCustomerId.value == id) {
      return false;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeleting.value = true;
    deletingCustomerId.value = id;
    try {
      await _customersService.deleteCustomer(id);
      customers.removeWhere((customer) => customer.id == id);
      if (selectedCustomer.value?.id == id) {
        selectedCustomer.value = null;
      }
      successMessage.value = CustomerMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = CustomerMessages.deleteError;
      return false;
    } finally {
      isDeleting.value = false;
      deletingCustomerId.value = null;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedTypeFilter.value = null;
    selectedStatusFilter.value = null;
    searchAndFilterCustomers();
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
                              CustomerMessages.deleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              CustomerMessages.deleteBody,
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
                          CustomerMessages.deleteCancel,
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
                          CustomerMessages.deleteConfirm,
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
