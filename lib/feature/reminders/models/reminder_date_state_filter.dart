enum ReminderDateStateFilter {
  today,
  overdue,
  future,
}

extension ReminderDateStateFilterX on ReminderDateStateFilter {
  String get label {
    switch (this) {
      case ReminderDateStateFilter.today:
        return 'Bugün';
      case ReminderDateStateFilter.overdue:
        return 'Gecikmiş';
      case ReminderDateStateFilter.future:
        return 'Gelecek';
    }
  }
}
