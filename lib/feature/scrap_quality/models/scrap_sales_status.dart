enum ScrapSalesStatus {
  purchased('purchased', 'Alındı'),
  notPurchased('not_purchased', 'Alınmadı'),
  unresolved('unresolved', 'Sonuçlanmadı'),
  waiting('waiting', 'Bekleyecek');

  const ScrapSalesStatus(this.value, this.label);

  final String value;
  final String label;

  bool get isPurchased => this == ScrapSalesStatus.purchased;
  bool get isNotPurchased => this == ScrapSalesStatus.notPurchased;
  bool get isPending =>
      this == ScrapSalesStatus.waiting || this == ScrapSalesStatus.unresolved;
}

extension ScrapSalesStatusX on ScrapSalesStatus {
  static ScrapSalesStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final status in ScrapSalesStatus.values) {
      if (status.value == value) {
        return status;
      }
    }

    return null;
  }
}
