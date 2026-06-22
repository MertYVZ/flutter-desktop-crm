import 'package:drift/drift.dart';

import 'package:Ok/feature/meetings/models/meeting_list_item.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/meetings_table.dart';

part 'meeting_dao.g.dart';

@DriftAccessor(tables: [Meetings, Customers])
class MeetingDao extends DatabaseAccessor<AppDatabase> with _$MeetingDaoMixin {
  MeetingDao(super.db);

  Future<List<MeetingListItem>> getMeetings() => searchMeetings();

  Future<List<MeetingListItem>> searchMeetings({
    String? searchQuery,
    MeetingMethod? methodFilter,
    MeetingSubject? subjectFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = select(meetings).join([
      innerJoin(customers, customers.id.equalsExp(meetings.customerId)),
    ]);

    query.where(meetings.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      final matchingSubjects = MeetingSubject.values
          .where(
            (subject) =>
                subject.label.toLowerCase().contains(trimmedSearch.toLowerCase()),
          )
          .map((subject) => subject.value)
          .toList();

      var searchCondition = customers.name.lower().like(pattern) |
          meetings.notes.lower().like(pattern) |
          meetings.subject.lower().like(pattern);

      if (matchingSubjects.isNotEmpty) {
        searchCondition =
            searchCondition | meetings.subject.isIn(matchingSubjects);
      }

      query.where(searchCondition);
    }

    if (methodFilter != null) {
      query.where(meetings.method.equals(methodFilter.value));
    }

    if (subjectFilter != null) {
      query.where(meetings.subject.equals(subjectFilter.value));
    }

    if (startDate != null) {
      query.where(
        meetings.date.isBiggerOrEqualValue(_startOfDay(startDate)),
      );
    }

    if (endDate != null) {
      query.where(
        meetings.date.isSmallerOrEqualValue(_endOfDay(endDate)),
      );
    }

    query.orderBy([OrderingTerm.desc(meetings.date)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<Meeting?> getMeetingById(String id) => (select(meetings)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<MeetingListItem?> getMeetingListItemById(String id) async {
    final query = select(meetings).join([
      innerJoin(customers, customers.id.equalsExp(meetings.customerId)),
    ])
      ..where(meetings.id.equals(id) & meetings.deletedAt.isNull());

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    return _mapRowToListItem(row);
  }

  Future<int> insertMeeting(MeetingsCompanion meeting) =>
      into(meetings).insert(meeting);

  Future<bool> updateMeeting(Meeting meeting) =>
      update(meetings).replace(meeting);

  Future<int> softDeleteMeeting(String id) => (update(meetings)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(MeetingsCompanion(deletedAt: Value(DateTime.now())));

  MeetingListItem _mapRowToListItem(TypedResult row) {
    final meeting = row.readTable(meetings);
    final customer = row.readTable(customers);

    return MeetingListItem(
      id: meeting.id,
      customerId: meeting.customerId,
      customerName: customer.name,
      date: meeting.date,
      method: meeting.method,
      subject: meeting.subject,
      notes: meeting.notes,
      createdAt: meeting.createdAt,
      updatedAt: meeting.updatedAt,
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
