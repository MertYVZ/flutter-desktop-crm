enum CustomerType {
  individual,
  corporate,
  foreign,
}

extension CustomerTypeX on CustomerType {
  String get value {
    switch (this) {
      case CustomerType.individual:
        return 'individual';
      case CustomerType.corporate:
        return 'corporate';
      case CustomerType.foreign:
        return 'foreign';
    }
  }

  String get label {
    switch (this) {
      case CustomerType.individual:
        return 'Bireysel';
      case CustomerType.corporate:
        return 'Kurumsal';
      case CustomerType.foreign:
        return 'Yabancı';
    }
  }

  static CustomerType? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return CustomerType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CustomerType.individual,
    );
  }
}
