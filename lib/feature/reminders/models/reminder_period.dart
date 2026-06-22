enum ReminderPeriod {
  daily,
  weekly,
  biweekly,
  monthly,
  sixMonthly,
  nineMonthly,
  yearly,
}

extension ReminderPeriodX on ReminderPeriod {
  String get value {
    switch (this) {
      case ReminderPeriod.daily:
        return 'daily';
      case ReminderPeriod.weekly:
        return 'weekly';
      case ReminderPeriod.biweekly:
        return 'biweekly';
      case ReminderPeriod.monthly:
        return 'monthly';
      case ReminderPeriod.sixMonthly:
        return 'sixMonthly';
      case ReminderPeriod.nineMonthly:
        return 'nineMonthly';
      case ReminderPeriod.yearly:
        return 'yearly';
    }
  }

  String get label {
    switch (this) {
      case ReminderPeriod.daily:
        return 'Günlük';
      case ReminderPeriod.weekly:
        return 'Haftalık';
      case ReminderPeriod.biweekly:
        return 'İki Haftada Bir';
      case ReminderPeriod.monthly:
        return 'Aylık';
      case ReminderPeriod.sixMonthly:
        return '6 Aylık';
      case ReminderPeriod.nineMonthly:
        return '9 Aylık';
      case ReminderPeriod.yearly:
        return 'Yıllık';
    }
  }

  static ReminderPeriod? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final period in ReminderPeriod.values) {
      if (period.value == value) {
        return period;
      }
    }

    return null;
  }
}
