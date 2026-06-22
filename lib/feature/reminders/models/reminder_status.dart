enum ReminderStatus {
  active,
  passive,
}

extension ReminderStatusX on ReminderStatus {
  String get value {
    switch (this) {
      case ReminderStatus.active:
        return 'active';
      case ReminderStatus.passive:
        return 'passive';
    }
  }

  String get label {
    switch (this) {
      case ReminderStatus.active:
        return 'Aktif';
      case ReminderStatus.passive:
        return 'Pasif';
    }
  }

  static ReminderStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final status in ReminderStatus.values) {
      if (status.value == value) {
        return status;
      }
    }

    return null;
  }
}
