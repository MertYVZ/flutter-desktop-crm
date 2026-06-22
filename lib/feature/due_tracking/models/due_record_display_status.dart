import 'package:Ok/feature/due_tracking/models/due_record_status.dart';

enum DueRecordDisplayStatus {
  pending,
  overdue,
  paid,
}

extension DueRecordDisplayStatusX on DueRecordDisplayStatus {
  String get label {
    switch (this) {
      case DueRecordDisplayStatus.pending:
        return 'Bekliyor';
      case DueRecordDisplayStatus.overdue:
        return 'Gecikmiş';
      case DueRecordDisplayStatus.paid:
        return 'Ödendi';
    }
  }

  static DueRecordDisplayStatus fromRecord({
    required String status,
    required DateTime dueDate,
  }) {
    if (status == DueRecordStatus.paid.value) {
      return DueRecordDisplayStatus.paid;
    }

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    if (dueDate.isBefore(startOfToday)) {
      return DueRecordDisplayStatus.overdue;
    }

    return DueRecordDisplayStatus.pending;
  }
}

enum DueRecordDisplayStatusFilter {
  pending,
  overdue,
  paid,
}

extension DueRecordDisplayStatusFilterX on DueRecordDisplayStatusFilter {
  String get label {
    switch (this) {
      case DueRecordDisplayStatusFilter.pending:
        return 'Bekliyor';
      case DueRecordDisplayStatusFilter.overdue:
        return 'Gecikmiş';
      case DueRecordDisplayStatusFilter.paid:
        return 'Ödendi';
    }
  }
}
