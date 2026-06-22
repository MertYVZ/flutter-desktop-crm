import 'package:Ok/feature/meetings/models/meeting_list_item.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class MeetingsService {
  MeetingsService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<MeetingListItem>> getMeetings() =>
      _databaseService.meetings.getMeetings();

  Future<List<MeetingListItem>> searchMeetings({
    String? searchQuery,
    MeetingMethod? methodFilter,
    MeetingSubject? subjectFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _databaseService.meetings.searchMeetings(
      searchQuery: searchQuery,
      methodFilter: methodFilter,
      subjectFilter: subjectFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<MeetingListItem?> getMeetingById(String id) =>
      _databaseService.meetings.getMeetingListItemById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createMeeting({
    required String customerId,
    required DateTime date,
    required MeetingMethod method,
    required MeetingSubject subject,
    String? notes,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.meetings.insertMeeting(
      MeetingsCompanion.insert(
        id: id,
        customerId: customerId,
        date: date,
        method: method.value,
        subject: subject.value,
        notes: Value(_nullableTrim(notes)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateMeeting({
    required String id,
    required String customerId,
    required DateTime date,
    required MeetingMethod method,
    required MeetingSubject subject,
    String? notes,
  }) async {
    final existing =
        await _databaseService.meetings.getMeetingById(id);
    if (existing == null) {
      throw StateError('Meeting not found');
    }

    final updated = existing.copyWith(
      customerId: customerId,
      date: date,
      method: method.value,
      subject: subject.value,
      notes: Value(_nullableTrim(notes)),
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.meetings.updateMeeting(updated);
    if (!success) {
      throw StateError('Meeting update failed');
    }
  }

  Future<void> deleteMeeting(String id) async {
    final affectedRows =
        await _databaseService.meetings.softDeleteMeeting(id);
    if (affectedRows == 0) {
      throw StateError('Meeting not found');
    }
  }

  String? _nullableTrim(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
