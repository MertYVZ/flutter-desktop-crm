enum NoteCustomerFilter {
  general,
  linkedToCustomer,
}

extension NoteCustomerFilterX on NoteCustomerFilter {
  String get label {
    switch (this) {
      case NoteCustomerFilter.general:
        return 'Genel Notlar';
      case NoteCustomerFilter.linkedToCustomer:
        return 'Müşteriye Bağlı';
    }
  }
}
