enum ScrapType {
  carbide('Karbür'),
  hss('HSS'),
  iron('Demir'),
  steel('Çelik'),
  stainless('Paslanmaz'),
  chrome('Krom'),
  copper('Bakır'),
  brass('Pirinç / Sarı'),
  bronze('Bronz / Kızıl'),
  aluminum('Alüminyum'),
  lead('Kurşun'),
  zinc('Çinko'),
  tin('Kalay'),
  nickel('Nikel'),
  titanium('Titanyum'),
  tungsten('Tungsten'),
  molybdenum('Molibden'),
  cobalt('Kobalt'),
  castIron('Döküm'),
  cableScrap('Hurda Kablo'),
  electronicScrap('Elektronik Hurda'),
  batteryScrap('Akü Hurdası'),
  motorScrap('Motor Hurdası'),
  swarf('Talaş'),
  chips('Kırpıntı'),
  mixedScrap('Karışık Hurda'),
  other('Diğer');

  const ScrapType(this.label);

  final String label;
}

extension ScrapTypeX on ScrapType {
  static ScrapType? fromLabel(String? label) {
    if (label == null || label.isEmpty) {
      return null;
    }

    for (final type in ScrapType.values) {
      if (type.label == label) {
        return type;
      }
    }

    return null;
  }

  static String resolve(ScrapType? type, String customText) {
    if (type == null) {
      return '';
    }

    if (type == ScrapType.other) {
      return customText.trim();
    }

    return type.label;
  }
}
