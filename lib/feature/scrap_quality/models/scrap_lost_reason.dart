enum ScrapLostReason {
  priceHigh('price_high', 'Fiyat düşük kaldı'),
  competitorWon('competitor_won', 'Rakip aldı'),
  remoteLocation('remote_location', 'Uzak lokasyon'),
  lowQuantity('low_quantity', 'Miktar az'),
  transportIssue('transport_issue', 'Ulaşım / araç problemi'),
  noCustomerResponse('no_customer_response', 'Müşteri dönüş yapmadı'),
  timingIssue('timing_issue', 'Mesai / zaman uygun değildi'),
  qualityMismatch('quality_mismatch', 'Kalite uygun değil'),
  other('other', 'Diğer');

  const ScrapLostReason(this.value, this.label);

  final String value;
  final String label;
}

extension ScrapLostReasonX on ScrapLostReason {
  static ScrapLostReason? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final reason in ScrapLostReason.values) {
      if (reason.value == value) {
        return reason;
      }
    }

    return null;
  }

  static ScrapLostReason? fromLabel(String? label) {
    if (label == null || label.isEmpty) {
      return null;
    }

    for (final reason in ScrapLostReason.values) {
      if (reason.label == label) {
        return reason;
      }
    }

    return null;
  }
}
