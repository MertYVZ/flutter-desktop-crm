import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/product/utility/constants/auth_messages.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/utility/constants/due_record_messages.dart';
import 'package:Ok/product/utility/constants/meeting_messages.dart';
import 'package:Ok/product/utility/constants/note_messages.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:Ok/product/utility/constants/price_list_messages.dart';
import 'package:Ok/product/utility/constants/price_offer_messages.dart';
import 'package:Ok/product/utility/constants/reminder_messages.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';

/// Password validation helpers with Turkish error messages.
abstract final class Validators {
  static String? validateNewPassword(String password) {
    if (password.length < 8) {
      return PasswordValidationMessages.minLength;
    }
    if (!RegExp('[A-Z]').hasMatch(password)) {
      return PasswordValidationMessages.uppercase;
    }
    if (!RegExp('[a-z]').hasMatch(password)) {
      return PasswordValidationMessages.lowercase;
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return PasswordValidationMessages.digit;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(password)) {
      return PasswordValidationMessages.specialChar;
    }
    return null;
  }

  static String? validatePasswordConfirmation(
    String password,
    String confirmation,
  ) {
    if (password != confirmation) {
      return PasswordValidationMessages.mismatch;
    }
    return null;
  }

  static String? validatePasswordChange({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final newPasswordError = validateNewPassword(newPassword);
    if (newPasswordError != null) {
      return newPasswordError;
    }

    final confirmationError =
        validatePasswordConfirmation(newPassword, confirmPassword);
    if (confirmationError != null) {
      return confirmationError;
    }

    if (oldPassword == newPassword) {
      return PasswordValidationMessages.sameAsOld;
    }

    return null;
  }

  static String? validateCustomerForm({
    required String name,
    required CustomerType? type,
    required String city,
    required String country,
    required String phone,
    required String email,
  }) {
    if (name.trim().isEmpty) {
      return CustomerMessages.nameRequired;
    }

    if (type == null) {
      return CustomerMessages.typeRequired;
    }

    if (city.trim().isEmpty) {
      return CustomerMessages.cityRequired;
    }

    if (country.trim().isEmpty) {
      return CustomerMessages.countryRequired;
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmedEmail)) {
      return CustomerMessages.invalidEmail;
    }

    final trimmedPhone = phone.trim();
    if (trimmedPhone.isNotEmpty && trimmedPhone.length < 7) {
      return CustomerMessages.phoneTooShort;
    }

    return null;
  }

  static String? validateCustomerContactForm({
    required String fullName,
    required String email,
    required String phone,
  }) {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      return CustomerDetailMessages.contactFullNameRequired;
    }

    if (trimmedName.length < 2) {
      return CustomerDetailMessages.contactFullNameTooShort;
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmedEmail)) {
      return CustomerDetailMessages.contactInvalidEmail;
    }

    final trimmedPhone = phone.trim();
    if (trimmedPhone.isNotEmpty && trimmedPhone.length < 7) {
      return CustomerDetailMessages.contactPhoneTooShort;
    }

    return null;
  }

  static String? validateDueRecordForm({
    required String? customerId,
    required DateTime? dueDate,
    required String amountText,
    required CurrencyType? currency,
    required String invoiceNo,
    DueRecordStatus? status,
    bool requireStatus = false,
  }) {
    if (customerId == null || customerId.isEmpty) {
      return DueRecordMessages.customerRequired;
    }

    if (dueDate == null) {
      return DueRecordMessages.dueDateRequired;
    }

    final trimmedAmount = amountText.trim();
    if (trimmedAmount.isEmpty) {
      return DueRecordMessages.amountRequired;
    }

    final amountMinor = MoneyUtils.parseAmountToMinor(trimmedAmount);
    if (amountMinor == null || amountMinor <= 0) {
      return DueRecordMessages.amountPositive;
    }

    if (currency == null) {
      return DueRecordMessages.currencyRequired;
    }

    if (invoiceNo.trim().isEmpty) {
      return DueRecordMessages.invoiceNoRequired;
    }

    if (requireStatus && status == null) {
      return DueRecordMessages.statusRequired;
    }

    return null;
  }

  static String? validateMeetingForm({
    required String? customerId,
    required DateTime? date,
    required MeetingMethod? method,
    required MeetingSubject? subject,
  }) {
    if (customerId == null || customerId.isEmpty) {
      return MeetingMessages.customerRequired;
    }

    if (date == null) {
      return MeetingMessages.dateRequired;
    }

    if (method == null) {
      return MeetingMessages.methodRequired;
    }

    if (subject == null) {
      return MeetingMessages.subjectRequired;
    }

    return null;
  }

  static String? validateNoteForm({
    required String title,
    required String content,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return NoteMessages.titleRequired;
    }

    if (trimmedTitle.length < 2) {
      return NoteMessages.titleMinLength;
    }

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      return NoteMessages.contentRequired;
    }

    if (trimmedContent.length < 3) {
      return NoteMessages.contentMinLength;
    }

    return null;
  }

  static String? validateScrapQualityForm({
    required String? customerId,
    required String quality,
    required String quantityText,
    required ScrapQualityUnit? unit,
    required String customUnitText,
  }) {
    if (customerId == null || customerId.isEmpty) {
      return ScrapQualityMessages.customerRequired;
    }

    final trimmedQuality = quality.trim();
    if (trimmedQuality.isEmpty) {
      return ScrapQualityMessages.qualityRequired;
    }

    if (trimmedQuality.length < 2) {
      return ScrapQualityMessages.qualityMinLength;
    }

    final trimmedQuantity = quantityText.trim();
    if (trimmedQuantity.isEmpty) {
      return ScrapQualityMessages.quantityRequired;
    }

    final quantity = QuantityUtils.parseQuantity(trimmedQuantity);
    if (quantity == null || quantity <= 0) {
      return ScrapQualityMessages.quantityPositive;
    }

    if (unit == null) {
      return ScrapQualityMessages.unitRequired;
    }

    if (unit == ScrapQualityUnit.other && customUnitText.trim().isEmpty) {
      return ScrapQualityMessages.customUnitRequired;
    }

    return null;
  }

  static String? validateReminderForm({
    required String? customerId,
    required String title,
    required ReminderPeriod? period,
    required DateTime? startDate,
    DateTime? nextReminderDate,
    ReminderStatus? status,
    bool requireNextReminderDate = false,
    bool requireStatus = false,
  }) {
    if (customerId == null || customerId.isEmpty) {
      return ReminderMessages.customerRequired;
    }

    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return ReminderMessages.titleRequired;
    }

    if (trimmedTitle.length < 2) {
      return ReminderMessages.titleMinLength;
    }

    if (period == null) {
      return ReminderMessages.periodRequired;
    }

    if (startDate == null) {
      return ReminderMessages.startDateRequired;
    }

    if (requireNextReminderDate && nextReminderDate == null) {
      return ReminderMessages.nextReminderDateRequired;
    }

    if (requireStatus && status == null) {
      return ReminderMessages.statusRequired;
    }

    return null;
  }

  static String? validatePriceOfferForm({
    required OfferType? type,
    required DateTime? offerDate,
    required String? customerId,
    required String contactPerson,
    required String legalText,
    required String authorizedPhone,
    required String mobilePhone,
    required List<PriceOfferItemFormValidation> items,
    PriceOfferStatus? status,
    bool requireStatus = false,
  }) {
    if (type == null) {
      return PriceOfferMessages.typeRequired;
    }

    if (offerDate == null) {
      return PriceOfferMessages.dateRequired;
    }

    if (customerId == null || customerId.isEmpty) {
      return PriceOfferMessages.customerRequired;
    }

    if (contactPerson.trim().isEmpty) {
      return PriceOfferMessages.contactPersonRequired;
    }

    if (legalText.trim().isEmpty) {
      return PriceOfferMessages.legalTextRequired;
    }

    if (requireStatus && status == null) {
      return PriceOfferMessages.statusRequired;
    }

    final trimmedAuthorizedPhone = authorizedPhone.trim();
    if (trimmedAuthorizedPhone.isNotEmpty &&
        trimmedAuthorizedPhone.length < 7) {
      return PriceOfferMessages.phoneTooShort;
    }

    final trimmedMobilePhone = mobilePhone.trim();
    if (trimmedMobilePhone.isNotEmpty && trimmedMobilePhone.length < 7) {
      return PriceOfferMessages.phoneTooShort;
    }

    if (items.isEmpty) {
      return PriceOfferMessages.itemsRequired;
    }

    for (final item in items) {
      if (item.productName.trim().isEmpty) {
        return PriceOfferMessages.productNameRequired;
      }

      if (item.unitType.trim().isEmpty) {
        return PriceOfferMessages.unitTypeRequired;
      }

      final trimmedQuantity = item.quantityText.trim();
      if (trimmedQuantity.isEmpty) {
        return PriceOfferMessages.quantityPositive;
      }

      final quantity = QuantityUtils.parseQuantity(trimmedQuantity);
      if (quantity == null || quantity <= 0) {
        return PriceOfferMessages.quantityPositive;
      }

      final trimmedPrice = item.priceText.trim();
      if (trimmedPrice.isEmpty) {
        return PriceOfferMessages.priceNonNegative;
      }

      final priceMinor = MoneyUtils.parseAmountToMinor(trimmedPrice);
      if (priceMinor == null || priceMinor < 0) {
        return PriceOfferMessages.priceNonNegative;
      }

      if (item.currency == null) {
        return PriceOfferMessages.currencyRequired;
      }
    }

    return null;
  }

  static String? validatePriceListForm({
    required String title,
    required DateTime? effectiveDate,
  }) {
    if (title.trim().isEmpty) {
      return PriceListMessages.titleRequired;
    }

    if (effectiveDate == null) {
      return PriceListMessages.effectiveDateRequired;
    }

    return null;
  }

  static String? validatePriceListItemForm({
    required String productName,
    required PriceListCurrency? currency,
    required String minPriceText,
    required String maxPriceText,
  }) {
    if (productName.trim().isEmpty) {
      return PriceListMessages.productNameRequired;
    }

    if (currency == null) {
      return PriceListMessages.currencyRequired;
    }

    final trimmedMin = minPriceText.trim();
    if (trimmedMin.isEmpty) {
      return PriceListMessages.minPriceRequired;
    }

    final minMinor = MoneyUtils.parseAmountToMinor(trimmedMin);
    if (minMinor == null) {
      return PriceListMessages.minPriceInvalid;
    }

    if (minMinor <= 0) {
      return PriceListMessages.minPricePositive;
    }

    final trimmedMax = maxPriceText.trim();
    if (trimmedMax.isEmpty) {
      return PriceListMessages.maxPriceRequired;
    }

    final maxMinor = MoneyUtils.parseAmountToMinor(trimmedMax);
    if (maxMinor == null) {
      return PriceListMessages.maxPriceInvalid;
    }

    if (maxMinor <= 0) {
      return PriceListMessages.maxPricePositive;
    }

    if (maxMinor < minMinor) {
      return PriceListMessages.maxPriceLessThanMin;
    }

    return null;
  }
}

final class PriceOfferItemFormValidation {
  const PriceOfferItemFormValidation({
    required this.productName,
    required this.unitType,
    required this.quantityText,
    required this.priceText,
    required this.currency,
  });

  final String productName;
  final String unitType;
  final String quantityText;
  final String priceText;
  final PriceOfferCurrencyType? currency;
}
