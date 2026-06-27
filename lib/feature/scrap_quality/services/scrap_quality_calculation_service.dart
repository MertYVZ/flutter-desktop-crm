import 'package:Ok/feature/scrap_quality/models/scrap_quality_analytics.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_summary.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';

final class ScrapQualityCalculationService {
  ScrapQualityCalculationService._();

  static ScrapQualitySummary calculateSummary(
    List<ScrapQualityListItem> records,
  ) {
    if (records.isEmpty) {
      return ScrapQualitySummary.empty;
    }

    var totalFoundKg = 0.0;
    var totalPurchasedKg = 0.0;
    var totalNotPurchasedKg = 0.0;
    var totalPendingKg = 0.0;
    var offerTotal = 0.0;
    var offerCount = 0;

    for (final record in records) {
      totalFoundKg += record.quantityKg;

      switch (record.salesStatusEnum) {
        case ScrapSalesStatus.purchased:
          totalPurchasedKg += record.quantityKg;
        case ScrapSalesStatus.notPurchased:
          totalNotPurchasedKg += record.quantityKg;
        case ScrapSalesStatus.unresolved:
        case ScrapSalesStatus.waiting:
          totalPendingKg += record.quantityKg;
        case null:
          totalPendingKg += record.quantityKg;
      }

      final offerPrice = record.offerPrice;
      if (offerPrice != null && offerPrice > 0) {
        offerTotal += offerPrice;
        offerCount++;
      }
    }

    // Kaybedilen = yalnızca "Alınmadı"; bekleyen/sonuçlanmamış ayrı kartta.
    final totalLostKg = totalNotPurchasedKg;
    final averageOfferPrice = offerCount == 0 ? 0.0 : offerTotal / offerCount;
    final purchaseRatePercent = totalFoundKg == 0
        ? 0.0
        : (totalPurchasedKg / totalFoundKg) * 100.0;

    return ScrapQualitySummary(
      totalFoundKg: totalFoundKg,
      totalPurchasedKg: totalPurchasedKg,
      totalLostKg: totalLostKg,
      totalPendingKg: totalPendingKg,
      totalNotPurchasedKg: totalNotPurchasedKg,
      averageOfferPrice: averageOfferPrice,
      purchaseRatePercent: purchaseRatePercent,
    );
  }

  static ScrapQualityAnalytics calculateAnalytics(
    List<ScrapQualityListItem> records,
  ) {
    if (records.isEmpty) {
      return const ScrapQualityAnalytics();
    }

    final foundByCustomer = <String, double>{};
    final purchasedByCustomer = <String, double>{};
    final lostByCustomer = <String, double>{};
    final typeTotals = <String, double>{};
    final cityCounts = <String, int>{};
    double? highestOffer;
    double? lowestOffer;

    for (final record in records) {
      final customer = record.displayCustomerName;
      foundByCustomer[customer] =
          (foundByCustomer[customer] ?? 0) + record.quantityKg;

      final status = record.salesStatusEnum;
      if (status == ScrapSalesStatus.purchased) {
        purchasedByCustomer[customer] =
            (purchasedByCustomer[customer] ?? 0) + record.quantityKg;
      } else if (status == ScrapSalesStatus.notPurchased) {
        lostByCustomer[customer] =
            (lostByCustomer[customer] ?? 0) + record.quantityKg;
      }

      final type = record.scrapType.trim();
      if (type.isNotEmpty) {
        typeTotals[type] = (typeTotals[type] ?? 0) + record.quantityKg;
      }

      final city = record.city?.trim();
      if (city != null && city.isNotEmpty) {
        cityCounts[city] = (cityCounts[city] ?? 0) + 1;
      }

      final offer = record.offerPrice;
      if (offer != null && offer > 0) {
        highestOffer = highestOffer == null
            ? offer
            : (offer > highestOffer ? offer : highestOffer);
        lowestOffer = lowestOffer == null
            ? offer
            : (offer < lowestOffer ? offer : lowestOffer);
      }
    }

    return ScrapQualityAnalytics(
      topFoundCustomer: _topKeyByValue(foundByCustomer),
      topPurchasedCustomer: _topKeyByValue(purchasedByCustomer),
      topLostCustomer: _topKeyByValue(lostByCustomer),
      topScrapType: _topKeyByValue(typeTotals),
      topCity: _topKeyByCount(cityCounts),
      highestOfferPrice: highestOffer,
      lowestOfferPrice: lowestOffer,
    );
  }

  static String? _topKeyByValue(Map<String, double> values) {
    if (values.isEmpty) {
      return null;
    }

    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static String? _topKeyByCount(Map<String, int> values) {
    if (values.isEmpty) {
      return null;
    }

    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
