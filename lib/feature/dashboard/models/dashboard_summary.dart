import 'package:equatable/equatable.dart';

final class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalCustomers,
    required this.pendingDueCount,
    required this.overdueDueCount,
    required this.currentMonthMeetingsCount,
    required this.currentMonthPriceOffersCount,
    required this.openPriceOffersCount,
  });

  final int totalCustomers;
  final int pendingDueCount;
  final int overdueDueCount;
  final int currentMonthMeetingsCount;
  final int currentMonthPriceOffersCount;
  final int openPriceOffersCount;

  bool get isEmpty =>
      totalCustomers == 0 &&
      pendingDueCount == 0 &&
      overdueDueCount == 0 &&
      currentMonthMeetingsCount == 0 &&
      currentMonthPriceOffersCount == 0 &&
      openPriceOffersCount == 0;

  @override
  List<Object?> get props => [
        totalCustomers,
        pendingDueCount,
        overdueDueCount,
        currentMonthMeetingsCount,
        currentMonthPriceOffersCount,
        openPriceOffersCount,
      ];
}
