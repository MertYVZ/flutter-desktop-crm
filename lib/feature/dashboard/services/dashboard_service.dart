import 'package:Ok/feature/dashboard/models/dashboard_calendar_event.dart';
import 'package:Ok/feature/dashboard/models/dashboard_calendar_event_type.dart';
import 'package:Ok/feature/dashboard/models/dashboard_summary.dart';
import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/services/reminders_service.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:drift/drift.dart';

final class DashboardService {
  DashboardService(
    this._databaseService,
    this._remindersService,
  );

  final DatabaseService _databaseService;
  final RemindersService _remindersService;

  Future<DashboardSummary> getSummary() async {
    final now = DateTime.now();
    final today = AppDateUtils.normalizeDate(now);
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final db = _databaseService.database;

    final totalCustomers = await _countWhere(
      db.customers,
      db.customers.deletedAt.isNull(),
    );

    final pendingDueCount = await _countWhere(
      db.dueRecords,
      db.dueRecords.deletedAt.isNull() &
          db.dueRecords.status.equals(DueRecordStatus.pending.value) &
          db.dueRecords.dueDate.isBiggerOrEqualValue(today),
    );

    final overdueDueCount = await _countWhere(
      db.dueRecords,
      db.dueRecords.deletedAt.isNull() &
          db.dueRecords.status.equals(DueRecordStatus.pending.value) &
          db.dueRecords.dueDate.isSmallerThanValue(today),
    );

    final currentMonthMeetingsCount = await _countWhere(
      db.meetings,
      db.meetings.deletedAt.isNull() &
          db.meetings.date.isBiggerOrEqualValue(monthStart) &
          db.meetings.date.isSmallerThanValue(nextMonthStart),
    );

    final currentMonthPriceOffersCount = await _countWhere(
      db.priceOffers,
      db.priceOffers.deletedAt.isNull() &
          db.priceOffers.offerDate.isBiggerOrEqualValue(monthStart) &
          db.priceOffers.offerDate.isSmallerThanValue(nextMonthStart),
    );

    final openPriceOffersCount = await _countWhere(
      db.priceOffers,
      db.priceOffers.deletedAt.isNull() &
          db.priceOffers.status.isIn([
            PriceOfferStatus.draft.value,
            PriceOfferStatus.sent.value,
          ]),
    );

    return DashboardSummary(
      totalCustomers: totalCustomers,
      pendingDueCount: pendingDueCount,
      overdueDueCount: overdueDueCount,
      currentMonthMeetingsCount: currentMonthMeetingsCount,
      currentMonthPriceOffersCount: currentMonthPriceOffersCount,
      openPriceOffersCount: openPriceOffersCount,
    );
  }

  Future<List<DashboardCalendarEvent>> getCalendarEventsForMonth(
    DateTime month,
  ) async {
    final meetingEvents = await getMeetingEventsForMonth(month);
    final priceOfferEvents = await getPriceOfferEventsForMonth(month);
    final reminderEvents = await getReminderEventsForMonth(month);
    final dueRecordEvents = await getDueRecordEventsForMonth(month);

    final events = <DashboardCalendarEvent>[
      ...meetingEvents,
      ...priceOfferEvents,
      ...reminderEvents,
      ...dueRecordEvents,
    ]..sort((a, b) => a.date.compareTo(b.date));

    return events;
  }

  Future<List<DashboardCalendarEvent>> getMeetingEventsForMonth(
    DateTime month,
  ) async {
    final range = _monthRange(month);
    final rows = await _databaseService.meetings.searchMeetings(
      startDate: range.start,
      endDate: range.endInclusive,
    );

    return rows.map((meeting) {
      final subjectLabel = meeting.meetingSubject?.label ?? meeting.subject;
      final methodLabel = meeting.meetingMethod?.label ?? meeting.method;

      return DashboardCalendarEvent(
        id: 'meeting-${meeting.id}',
        title: 'Görüşme',
        subtitle: '$subjectLabel · $methodLabel',
        date: meeting.date,
        type: DashboardCalendarEventType.meeting,
        customerName: meeting.customerName,
        route: AppRoutes.meetingsDetail.pathForId(meeting.id),
        sourceId: meeting.id,
        sourceType: DashboardCalendarEventType.meeting.sourceType,
      );
    }).toList();
  }

  Future<List<DashboardCalendarEvent>> getPriceOfferEventsForMonth(
    DateTime month,
  ) async {
    final range = _monthRange(month);
    final rows = await _databaseService.priceOffers.searchOffers(
      startDate: range.start,
      endDate: range.endInclusive,
    );

    return rows.map((offer) {
      final typeLabel = OfferTypeX.fromValue(offer.type)?.label ?? offer.type;
      final statusLabel =
          PriceOfferStatusX.fromValue(offer.status)?.label ?? offer.status;

      return DashboardCalendarEvent(
        id: 'price-offer-${offer.id}',
        title: 'Fiyat Teklifi',
        subtitle: '$typeLabel · $statusLabel',
        date: offer.offerDate,
        type: DashboardCalendarEventType.priceOffer,
        customerName: offer.customerName,
        route: AppRoutes.priceOffersDetail.pathForId(offer.id),
        sourceId: offer.id,
        sourceType: DashboardCalendarEventType.priceOffer.sourceType,
      );
    }).toList();
  }

  Future<List<DashboardCalendarEvent>> getReminderEventsForMonth(
    DateTime month,
  ) async {
    final items =
        await _remindersService.getReminderCalendarItemsForMonth(month);

    return items.map((item) {
      return DashboardCalendarEvent(
        id: 'reminder-${item.reminderId}-${item.occurrenceDate.millisecondsSinceEpoch}',
        title: item.title,
        subtitle: item.period.label,
        date: item.occurrenceDate,
        type: DashboardCalendarEventType.reminder,
        customerName: item.customerName,
        route: AppRoutes.remindersEdit.pathForId(item.reminderId),
        sourceId: item.reminderId,
        sourceType: DashboardCalendarEventType.reminder.sourceType,
      );
    }).toList();
  }

  Future<List<DashboardCalendarEvent>> getDueRecordEventsForMonth(
    DateTime month,
  ) async {
    final range = _monthRange(month);
    final rows = await _databaseService.dueRecords.searchDueRecords(
      startDate: range.start,
      endDate: range.endInclusive,
    );

    return rows.map((record) {
      final currency = record.currencyType ?? CurrencyType.try_;
      final amount = MoneyUtils.formatAmountMinor(record.amountMinor, currency);
      final statusLabel = record.displayStatus.label;

      return DashboardCalendarEvent(
        id: 'due-record-${record.id}',
        title: 'Vade',
        subtitle: '$amount · $statusLabel',
        date: AppDateUtils.normalizeDate(record.dueDate),
        type: DashboardCalendarEventType.dueRecord,
        customerName: record.customerName,
        route: AppRoutes.dueTrackingEdit.pathForId(record.id),
        sourceId: record.id,
        sourceType: DashboardCalendarEventType.dueRecord.sourceType,
      );
    }).toList();
  }

  Future<int> _countWhere<T extends Table>(
    TableInfo<T, dynamic> table,
    Expression<bool> where,
  ) async {
    final db = _databaseService.database;
    final idColumn = table.primaryKey.first as GeneratedColumn<Object>;
    final countExpr = idColumn.count();
    final query = db.selectOnly(table)
      ..addColumns([countExpr])
      ..where(where);

    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  ({DateTime start, DateTime endInclusive}) _monthRange(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final nextMonthStart = DateTime(month.year, month.month + 1, 1);
    final endInclusive =
        nextMonthStart.subtract(const Duration(milliseconds: 1));
    return (start: start, endInclusive: endInclusive);
  }
}
