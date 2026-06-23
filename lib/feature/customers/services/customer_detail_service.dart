import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/due_tracking/models/due_record_list_item.dart';
import 'package:Ok/feature/meetings/models/meeting_list_item.dart';
import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class CustomerDetailService {
  CustomerDetailService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<Customer?> getCustomerById(String customerId) =>
      _databaseService.customers.getCustomerById(customerId);

  Future<List<PriceOfferListItem>> getCustomerPriceOffers(
    String customerId,
  ) =>
      _databaseService.priceOffers.getOffersByCustomerId(customerId);

  Future<List<MeetingListItem>> getCustomerMeetings(String customerId) =>
      _databaseService.meetings.getMeetingsByCustomerId(customerId);

  Future<List<DueRecordListItem>> getCustomerDueRecords(String customerId) =>
      _databaseService.dueRecords.getDueRecordsByCustomerId(customerId);

  Future<List<ReminderListItem>> getCustomerReminders(String customerId) =>
      _databaseService.reminders.getRemindersByCustomerId(customerId);

  Future<List<NoteListItem>> getCustomerNotes(String customerId) =>
      _databaseService.notes.getNotesByCustomerId(customerId);

  Future<List<ScrapQualityListItem>> getCustomerScrapQualityRecords(
    String customerId,
  ) =>
      _databaseService.scrapQualityRecords.getRecordsByCustomerId(customerId);

  Future<List<CustomerContactItem>> getCustomerContacts(
    String customerId,
  ) async {
    final contacts =
        await _databaseService.customerContacts.getContactsByCustomerId(
      customerId,
    );
    return contacts.map(CustomerContactItem.fromEntity).toList();
  }

  Future<String> createCustomerContact({
    required String customerId,
    required String fullName,
    String? title,
    String? email,
    String? phone,
    required bool isPrimary,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.database.transaction(() async {
      if (isPrimary) {
        await _databaseService.customerContacts.clearPrimaryForCustomer(
          customerId,
        );
      }

      await _databaseService.customerContacts.insertContact(
        CustomerContactsCompanion.insert(
          id: id,
          customerId: customerId,
          fullName: fullName.trim(),
          title: Value(_nullableTrim(title)),
          email: Value(_nullableTrim(email)),
          phone: Value(_nullableTrim(phone)),
          isPrimary: Value(isPrimary),
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    return id;
  }

  Future<void> updateCustomerContact({
    required String id,
    required String customerId,
    required String fullName,
    String? title,
    String? email,
    String? phone,
    required bool isPrimary,
  }) async {
    final existing = await _databaseService.customerContacts.getContactById(id);
    if (existing == null) {
      throw StateError('Customer contact not found');
    }

    await _databaseService.database.transaction(() async {
      if (isPrimary) {
        await _databaseService.customerContacts.clearPrimaryForCustomer(
          customerId,
        );
      }

      final updated = existing.copyWith(
        fullName: fullName.trim(),
        title: Value(_nullableTrim(title)),
        email: Value(_nullableTrim(email)),
        phone: Value(_nullableTrim(phone)),
        isPrimary: isPrimary,
        updatedAt: DateTime.now(),
      );

      final success =
          await _databaseService.customerContacts.updateContact(updated);
      if (!success) {
        throw StateError('Customer contact update failed');
      }
    });
  }

  Future<void> deleteCustomerContact(String id) async {
    final affectedRows =
        await _databaseService.customerContacts.softDeleteContact(id);
    if (affectedRows == 0) {
      throw StateError('Customer contact not found');
    }
  }

  Future<void> setPrimaryContact(String customerId, String contactId) async {
    await _databaseService.database.transaction(() async {
      await _databaseService.customerContacts.clearPrimaryForCustomer(
        customerId,
      );

      final existing =
          await _databaseService.customerContacts.getContactById(contactId);
      if (existing == null) {
        throw StateError('Customer contact not found');
      }

      final updated = existing.copyWith(
        isPrimary: true,
        updatedAt: DateTime.now(),
      );

      final success =
          await _databaseService.customerContacts.updateContact(updated);
      if (!success) {
        throw StateError('Primary contact update failed');
      }
    });
  }

  String? _nullableTrim(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
