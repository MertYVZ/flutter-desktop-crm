import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/customers/services/customer_detail_service.dart';
import 'package:Ok/feature/customers/services/customers_service.dart';
import 'package:Ok/feature/due_tracking/models/due_record_list_item.dart';
import 'package:Ok/feature/meetings/models/meeting_list_item.dart';
import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/reminders/services/reminders_service.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_route_args.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

enum CustomerDetailTab {
  priceOffers,
  meetings,
  dueRecords,
  reminders,
  notes,
  scrapQuality,
  contacts,
}

final class CustomerDetailController extends GetxController {
  CustomerDetailController(
    this._customerDetailService,
    this._customersService,
    this._remindersService,
  );

  final CustomerDetailService _customerDetailService;
  final CustomersService _customersService;
  final RemindersService _remindersService;

  final RxBool isLoadingCustomer = false.obs;
  final RxBool isLoadingTabData = false.obs;
  final RxBool isSavingContact = false.obs;
  final RxBool isDeletingContact = false.obs;
  final RxBool isDeletingCustomer = false.obs;
  final RxBool isCompletingReminder = false.obs;
  final RxnString completingReminderId = RxnString();
  final RxnString deletingContactId = RxnString();
  final Rxn<Customer> customer = Rxn<Customer>();
  final RxInt selectedTabIndex = 0.obs;
  final RxList<PriceOfferListItem> priceOffers = <PriceOfferListItem>[].obs;
  final RxList<MeetingListItem> meetings = <MeetingListItem>[].obs;
  final RxList<DueRecordListItem> dueRecords = <DueRecordListItem>[].obs;
  final RxList<ReminderListItem> reminders = <ReminderListItem>[].obs;
  final RxList<NoteListItem> notes = <NoteListItem>[].obs;
  final RxList<ScrapQualityListItem> scrapQualityRecords =
      <ScrapQualityListItem>[].obs;
  final RxList<CustomerContactItem> contacts = <CustomerContactItem>[].obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  final Set<int> _loadedTabIndexes = <int>{};
  int? _pendingTabLoadIndex;

  String? get customerId => customer.value?.id;

  void openCreateForm(AppRoutes route) {
    final id = customerId;
    if (id == null) {
      return;
    }

    Get.toNamed<void>(
      route.value,
      arguments: AppRouteArgs.withCustomerId(id),
    );
  }

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<bool> loadCustomer(String id) async {
    if (isLoadingCustomer.value) {
      return false;
    }

    clearMessages();
    customer.value = null;
    _loadedTabIndexes.clear();
    _pendingTabLoadIndex = null;
    _clearTabData();

    isLoadingCustomer.value = true;
    try {
      final result = await _customerDetailService.getCustomerById(id);
      if (result == null) {
        errorMessage.value = CustomerMessages.notFound;
        return false;
      }

      customer.value = result;
      selectedTabIndex.value = 0;
      await loadSelectedTabData();
      return true;
    } catch (_) {
      errorMessage.value = CustomerMessages.notFound;
      return false;
    } finally {
      isLoadingCustomer.value = false;
    }
  }

  Future<void> changeTab(int index) async {
    if (selectedTabIndex.value == index) {
      return;
    }

    selectedTabIndex.value = index;
    await loadSelectedTabData();
  }

  Future<void> loadSelectedTabData() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    final tabIndex = selectedTabIndex.value;
    if (_loadedTabIndexes.contains(tabIndex)) {
      return;
    }

    switch (CustomerDetailTab.values[tabIndex]) {
      case CustomerDetailTab.priceOffers:
        await loadPriceOffers();
      case CustomerDetailTab.meetings:
        await loadMeetings();
      case CustomerDetailTab.dueRecords:
        await loadDueRecords();
      case CustomerDetailTab.reminders:
        await loadReminders();
      case CustomerDetailTab.notes:
        await loadNotes();
      case CustomerDetailTab.scrapQuality:
        await loadScrapQualityRecords();
      case CustomerDetailTab.contacts:
        await loadContacts();
    }
  }

  Future<void> refreshCurrentTab() async {
    _loadedTabIndexes.remove(selectedTabIndex.value);
    await loadSelectedTabData();
  }

  Future<void> loadPriceOffers() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result = await _customerDetailService.getCustomerPriceOffers(id);
      priceOffers.assignAll(result);
    }, CustomerDetailTab.priceOffers.index);
  }

  Future<void> loadMeetings() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result = await _customerDetailService.getCustomerMeetings(id);
      meetings.assignAll(result);
    }, CustomerDetailTab.meetings.index);
  }

  Future<void> loadDueRecords() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result = await _customerDetailService.getCustomerDueRecords(id);
      dueRecords.assignAll(result);
    }, CustomerDetailTab.dueRecords.index);
  }

  Future<void> loadReminders() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result = await _customerDetailService.getCustomerReminders(id);
      reminders.assignAll(result);
    }, CustomerDetailTab.reminders.index);
  }

  Future<void> loadNotes() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result = await _customerDetailService.getCustomerNotes(id);
      notes.assignAll(result);
    }, CustomerDetailTab.notes.index);
  }

  Future<void> loadScrapQualityRecords() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result =
          await _customerDetailService.getCustomerScrapQualityRecords(id);
      scrapQualityRecords.assignAll(result);
    }, CustomerDetailTab.scrapQuality.index);
  }

  Future<void> loadContacts() async {
    final id = customerId;
    if (id == null) {
      return;
    }

    await _loadTabData(() async {
      final result = await _customerDetailService.getCustomerContacts(id);
      contacts.assignAll(result);
    }, CustomerDetailTab.contacts.index);
  }

  Future<bool> createContact({
    required String fullName,
    required String title,
    required String email,
    required String phone,
    required bool isPrimary,
  }) async {
    final id = customerId;
    if (id == null || isSavingContact.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateCustomerContactForm(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSavingContact.value = true;
    try {
      await _customerDetailService.createCustomerContact(
        customerId: id,
        fullName: fullName,
        title: title,
        email: email,
        phone: phone,
        isPrimary: isPrimary,
      );
      _loadedTabIndexes.remove(CustomerDetailTab.contacts.index);
      await loadContacts();
      successMessage.value = CustomerDetailMessages.contactCreateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = CustomerDetailMessages.contactCreateError;
      return false;
    } finally {
      isSavingContact.value = false;
    }
  }

  Future<bool> updateContact({
    required String contactId,
    required String fullName,
    required String title,
    required String email,
    required String phone,
    required bool isPrimary,
  }) async {
    final id = customerId;
    if (id == null || isSavingContact.value) {
      return false;
    }

    clearMessages();

    final validationError = Validators.validateCustomerContactForm(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isSavingContact.value = true;
    try {
      await _customerDetailService.updateCustomerContact(
        id: contactId,
        customerId: id,
        fullName: fullName,
        title: title,
        email: email,
        phone: phone,
        isPrimary: isPrimary,
      );
      _loadedTabIndexes.remove(CustomerDetailTab.contacts.index);
      await loadContacts();
      successMessage.value = CustomerDetailMessages.contactUpdateSuccess;
      return true;
    } catch (_) {
      errorMessage.value = CustomerDetailMessages.contactUpdateError;
      return false;
    } finally {
      isSavingContact.value = false;
    }
  }

  Future<bool> deleteContact(String contactId) async {
    if (isDeletingContact.value || deletingContactId.value == contactId) {
      return false;
    }

    final confirmed = await _showContactDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeletingContact.value = true;
    deletingContactId.value = contactId;
    try {
      await _customerDetailService.deleteCustomerContact(contactId);
      _loadedTabIndexes.remove(CustomerDetailTab.contacts.index);
      await loadContacts();
      successMessage.value = CustomerDetailMessages.contactDeleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = CustomerDetailMessages.contactDeleteError;
      return false;
    } finally {
      isDeletingContact.value = false;
      deletingContactId.value = null;
    }
  }

  Future<bool> setPrimaryContact(String contactId) async {
    final id = customerId;
    if (id == null) {
      return false;
    }

    clearMessages();
    try {
      await _customerDetailService.setPrimaryContact(id, contactId);
      _loadedTabIndexes.remove(CustomerDetailTab.contacts.index);
      await loadContacts();
      return true;
    } catch (_) {
      errorMessage.value = CustomerDetailMessages.contactUpdateError;
      return false;
    }
  }

  Future<bool> completeReminder(String reminderId) async {
    if (isCompletingReminder.value ||
        completingReminderId.value == reminderId) {
      return false;
    }

    clearMessages();
    isCompletingReminder.value = true;
    completingReminderId.value = reminderId;
    try {
      await _remindersService.completeReminder(reminderId);
      _loadedTabIndexes.remove(CustomerDetailTab.reminders.index);
      await loadReminders();
      return true;
    } catch (_) {
      errorMessage.value = CustomerDetailMessages.reminderCompleteError;
      return false;
    } finally {
      isCompletingReminder.value = false;
      completingReminderId.value = null;
    }
  }

  Future<bool> deleteCustomer() async {
    final id = customerId;
    if (id == null || isDeletingCustomer.value) {
      return false;
    }

    final confirmed = await _showCustomerDeleteConfirmDialog();
    if (!confirmed) {
      return false;
    }

    clearMessages();
    isDeletingCustomer.value = true;
    try {
      await _customersService.deleteCustomer(id);
      successMessage.value = CustomerMessages.deleteSuccess;
      return true;
    } catch (_) {
      errorMessage.value = CustomerMessages.deleteError;
      return false;
    } finally {
      isDeletingCustomer.value = false;
    }
  }

  Future<void> _loadTabData(
    Future<void> Function() loader,
    int tabIndex,
  ) async {
    if (isLoadingTabData.value) {
      _pendingTabLoadIndex = selectedTabIndex.value;
      return;
    }

    isLoadingTabData.value = true;
    try {
      await loader();
      _loadedTabIndexes.add(tabIndex);
    } catch (_) {
      errorMessage.value = CustomerDetailMessages.tabLoadError;
    } finally {
      isLoadingTabData.value = false;
      final pending = _pendingTabLoadIndex;
      _pendingTabLoadIndex = null;
      if (pending != null &&
          pending == selectedTabIndex.value &&
          !_loadedTabIndexes.contains(pending)) {
        await loadSelectedTabData();
      }
    }
  }

  void _clearTabData() {
    priceOffers.clear();
    meetings.clear();
    dueRecords.clear();
    reminders.clear();
    notes.clear();
    scrapQualityRecords.clear();
    contacts.clear();
  }

  Future<bool> _showContactDeleteConfirmDialog() async {
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
                              CustomerDetailMessages.contactDeleteTitle,
                              style: TextStyle(
                                color: AppUiTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppUiTokens.space8),
                            Text(
                              CustomerDetailMessages.contactDeleteBody,
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
                          ),
                        ),
                        child: const Text(
                          CustomerDetailMessages.contactDeleteCancel,
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space8),
                      FilledButton(
                        onPressed: () => Get.back<bool>(result: true),
                        style: AppInteractiveTheme.filledButtonStyle(
                          FilledButton.styleFrom(
                            backgroundColor: ColorName.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        child: const Text(
                          CustomerDetailMessages.contactDeleteConfirm,
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

  Future<bool> _showCustomerDeleteConfirmDialog() async {
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
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppUiTokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    CustomerMessages.deleteTitle,
                    style: TextStyle(
                      color: AppUiTokens.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppUiTokens.space8),
                  const Text(
                    CustomerMessages.deleteBody,
                    style: TextStyle(
                      color: AppUiTokens.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppUiTokens.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back<bool>(result: false),
                        child: const Text(CustomerMessages.deleteCancel),
                      ),
                      const SizedBox(width: AppUiTokens.space8),
                      FilledButton(
                        onPressed: () => Get.back<bool>(result: true),
                        style: AppInteractiveTheme.filledButtonStyle(
                          FilledButton.styleFrom(
                            backgroundColor: ColorName.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        child: const Text(CustomerMessages.deleteConfirm),
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
    );

    return result ?? false;
  }
}
