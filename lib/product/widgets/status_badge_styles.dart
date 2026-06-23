import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';

extension CustomerStatusBadgeStyle on CustomerStatus {
  AppBadgeStyle get badgeStyle {
    switch (this) {
      case CustomerStatus.active:
        return AppStatusTone.success.badgeStyle;
      case CustomerStatus.passive:
        return AppStatusTone.neutral.badgeStyle;
    }
  }
}

extension PriceListStatusBadgeStyle on PriceListStatus {
  AppBadgeStyle get badgeStyle {
    switch (this) {
      case PriceListStatus.active:
        return AppStatusTone.success.badgeStyle;
      case PriceListStatus.archived:
        return AppStatusTone.neutral.badgeStyle;
      case PriceListStatus.draft:
        return AppStatusTone.neutral.badgeStyle;
    }
  }
}

extension DueRecordDisplayStatusBadgeStyle on DueRecordDisplayStatus {
  AppBadgeStyle get badgeStyle {
    switch (this) {
      case DueRecordDisplayStatus.pending:
        return AppStatusTone.warning.badgeStyle;
      case DueRecordDisplayStatus.overdue:
        return AppStatusTone.error.badgeStyle;
      case DueRecordDisplayStatus.paid:
        return AppStatusTone.success.badgeStyle;
    }
  }
}

extension ReminderStatusBadgeStyle on ReminderStatus {
  AppBadgeStyle get badgeStyle {
    switch (this) {
      case ReminderStatus.active:
        return AppStatusTone.success.badgeStyle;
      case ReminderStatus.passive:
        return AppStatusTone.neutral.badgeStyle;
    }
  }
}
