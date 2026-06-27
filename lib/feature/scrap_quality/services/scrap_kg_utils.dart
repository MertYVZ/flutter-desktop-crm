import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';

final class ScrapKgUtils {
  ScrapKgUtils._();

  static bool supportsAutoConversion(ScrapQualityUnit unit) {
    return unit == ScrapQualityUnit.kg ||
        unit == ScrapQualityUnit.ton ||
        unit == ScrapQualityUnit.gram;
  }

  static bool requiresManualKg(ScrapQualityUnit unit) =>
      !supportsAutoConversion(unit);

  static double? autoConvertToKg({
    required double quantity,
    required ScrapQualityUnit unit,
  }) {
    switch (unit) {
      case ScrapQualityUnit.kg:
        return quantity;
      case ScrapQualityUnit.ton:
        return quantity * 1000;
      case ScrapQualityUnit.gram:
        return quantity / 1000;
      default:
        return null;
    }
  }

  static double resolveQuantityKg({
    required double quantity,
    required String unitLabel,
    required ScrapQualityUnit? unit,
    double? manualQuantityKg,
  }) {
    if (unit != null) {
      final auto = autoConvertToKg(quantity: quantity, unit: unit);
      if (auto != null) {
        return auto;
      }
    }

    if (manualQuantityKg != null && manualQuantityKg > 0) {
      return manualQuantityKg;
    }

    final parsedUnit = ScrapQualityUnit.fromLabel(unitLabel);
    if (parsedUnit != null) {
      final auto = autoConvertToKg(quantity: quantity, unit: parsedUnit);
      if (auto != null) {
        return auto;
      }
    }

    return quantity;
  }

  static double backfillQuantityKg({
    required double quantity,
    required String unitLabel,
  }) {
    final unit = ScrapQualityUnit.fromLabel(unitLabel);
    if (unit != null) {
      final auto = autoConvertToKg(quantity: quantity, unit: unit);
      if (auto != null) {
        return auto;
      }
    }

    return quantity;
  }
}
