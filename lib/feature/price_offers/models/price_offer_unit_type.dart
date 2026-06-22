enum PriceOfferUnitType {
  kg('KG'),
  ton('Ton'),
  adet('Adet'),
  kutu('Kutu'),
  paket('Paket'),
  metre('Metre');

  const PriceOfferUnitType(this.label);

  final String label;

  static PriceOfferUnitType? fromLabel(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final unit in values) {
      if (unit.label == value) {
        return unit;
      }
    }

    return null;
  }
}
