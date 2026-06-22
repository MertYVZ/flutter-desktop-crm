enum DueRecordStatus {
  pending,
  paid,
}

extension DueRecordStatusX on DueRecordStatus {
  String get value {
    switch (this) {
      case DueRecordStatus.pending:
        return 'pending';
      case DueRecordStatus.paid:
        return 'paid';
    }
  }

  String get label {
    switch (this) {
      case DueRecordStatus.pending:
        return 'Bekliyor';
      case DueRecordStatus.paid:
        return 'Ödendi';
    }
  }

  static DueRecordStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final status in DueRecordStatus.values) {
      if (status.value == value) {
        return status;
      }
    }

    return null;
  }
}
