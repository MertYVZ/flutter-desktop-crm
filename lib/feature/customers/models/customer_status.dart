enum CustomerStatus {
  active,
  passive,
}

extension CustomerStatusX on CustomerStatus {
  String get value {
    switch (this) {
      case CustomerStatus.active:
        return 'active';
      case CustomerStatus.passive:
        return 'passive';
    }
  }

  String get label {
    switch (this) {
      case CustomerStatus.active:
        return 'Aktif';
      case CustomerStatus.passive:
        return 'Pasif';
    }
  }

  static CustomerStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return CustomerStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CustomerStatus.active,
    );
  }
}
