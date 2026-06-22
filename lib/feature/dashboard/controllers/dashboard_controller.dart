import 'package:Ok/feature/dashboard/models/dashboard_calendar_event.dart';
import 'package:Ok/feature/dashboard/models/dashboard_summary.dart';
import 'package:Ok/feature/dashboard/services/dashboard_service.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:get/get.dart';

final class DashboardController extends GetxController {
  DashboardController(this._dashboardService);

  final DashboardService _dashboardService;

  final RxBool isLoadingSummary = false.obs;
  final RxBool isLoadingCalendar = false.obs;
  final Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  final RxList<DashboardCalendarEvent> calendarEvents =
      <DashboardCalendarEvent>[].obs;
  final RxList<DashboardCalendarEvent> agendaEvents =
      <DashboardCalendarEvent>[].obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxList<DashboardCalendarEvent> selectedDateEvents =
      <DashboardCalendarEvent>[].obs;
  final RxBool isDayPanelOpen = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );
  }

  Future<void> loadDashboard() async {
    await Future.wait([
      loadSummary(),
      loadCalendarEvents(selectedMonth.value),
      loadAgendaEvents(),
    ]);
  }

  Future<void> loadSummary() async {
    if (isLoadingSummary.value) {
      return;
    }

    isLoadingSummary.value = true;
    try {
      summary.value = await _dashboardService.getSummary();
    } catch (_) {
      errorMessage.value = 'Dashboard özeti yüklenemedi.';
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> loadCalendarEvents(DateTime month) async {
    if (isLoadingCalendar.value) {
      return;
    }

    isLoadingCalendar.value = true;
    try {
      final events = await _dashboardService.getCalendarEventsForMonth(month);
      calendarEvents.assignAll(events);

      final selected = selectedDate.value;
      if (selected != null) {
        selectedDateEvents.assignAll(getEventsForDate(selected));
      }
    } catch (_) {
      errorMessage.value = 'Takvim verileri yüklenemedi.';
    } finally {
      isLoadingCalendar.value = false;
    }
  }

  Future<void> loadAgendaEvents() async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);
      final currentMonthEvents =
          await _dashboardService.getCalendarEventsForMonth(currentMonth);
      final nextMonthEvents =
          await _dashboardService.getCalendarEventsForMonth(nextMonth);

      final deduplicated = <String, DashboardCalendarEvent>{
        for (final event in [...currentMonthEvents, ...nextMonthEvents])
          event.id: event,
      }.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      agendaEvents.assignAll(deduplicated);
    } catch (_) {
      errorMessage.value = 'Dashboard gündem verileri yüklenemedi.';
    }
  }

  Future<void> changeMonth(DateTime month) async {
    selectedMonth.value = DateTime(month.year, month.month);
    closeDayPanel();
    await loadCalendarEvents(selectedMonth.value);
  }

  void selectDate(DateTime date) {
    final normalized = AppDateUtils.normalizeDate(date);
    selectedDate.value = normalized;
    selectedDateEvents.assignAll(getEventsForDate(normalized));
    isDayPanelOpen.value = true;
  }

  void closeDayPanel() {
    isDayPanelOpen.value = false;
    selectedDate.value = null;
    selectedDateEvents.clear();
  }

  List<DashboardCalendarEvent> getEventsForDate(DateTime date) {
    final normalized = AppDateUtils.normalizeDate(date);
    return calendarEvents
        .where(
          (event) =>
              AppDateUtils.normalizeDate(event.date) == normalized,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<DashboardCalendarEvent> get todayEvents {
    final today = AppDateUtils.normalizeDate(DateTime.now());
    return agendaEvents
        .where((event) => AppDateUtils.normalizeDate(event.date) == today)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<DashboardCalendarEvent> get upcomingEvents {
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final endDate = today.add(const Duration(days: 14));

    return agendaEvents
        .where((event) {
          final eventDate = AppDateUtils.normalizeDate(event.date);
          return eventDate.isAfter(today) &&
              (eventDate.isBefore(endDate) || eventDate == endDate);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void navigateToEvent(DashboardCalendarEvent event) {
    final route = event.route;
    if (route == null || route.isEmpty) {
      return;
    }

    Get.toNamed<void>(route);
  }

  void navigateToCustomers() {
    Get.offNamed<void>(AppRoutes.customers.value);
  }

  void navigateToDueTracking() {
    Get.offNamed<void>(AppRoutes.dueTracking.value);
  }

  void navigateToMeetings() {
    Get.offNamed<void>(AppRoutes.meetings.value);
  }

  void navigateToPriceOffers() {
    Get.offNamed<void>(AppRoutes.priceOffers.value);
  }
}
