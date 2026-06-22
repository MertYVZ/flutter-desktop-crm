enum ScrapQualityUnit {
  kg('KG'),
  ton('Ton'),
  gram('Gram'),
  adet('Adet'),
  koli('Koli'),
  paket('Paket'),
  cuval('Çuval'),
  palet('Palet'),
  kasa('Kasa'),
  varil('Varil'),
  kamyon('Kamyon'),
  konteyner('Konteyner'),
  metre('Metre'),
  metrekare('Metrekare'),
  metrekup('Metreküp'),
  litre('Litre'),
  other('Diğer');

  const ScrapQualityUnit(this.label);

  final String label;

  static const ScrapQualityUnit defaultUnit = ScrapQualityUnit.kg;

  static ScrapQualityUnit? fromLabel(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final unit in values) {
      if (unit != ScrapQualityUnit.other && unit.label == value) {
        return unit;
      }
    }

    return null;
  }

  static bool isPredefinedLabel(String value) => fromLabel(value) != null;
}
