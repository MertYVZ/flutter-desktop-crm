import 'package:equatable/equatable.dart';

final class ScrapQualitySummary extends Equatable {
  const ScrapQualitySummary({
    required this.totalFoundKg,
    required this.totalPurchasedKg,
    required this.totalLostKg,
    required this.totalPendingKg,
    required this.totalNotPurchasedKg,
    required this.averageOfferPrice,
    required this.purchaseRatePercent,
  });

  static const empty = ScrapQualitySummary(
    totalFoundKg: 0,
    totalPurchasedKg: 0,
    totalLostKg: 0,
    totalPendingKg: 0,
    totalNotPurchasedKg: 0,
    averageOfferPrice: 0,
    purchaseRatePercent: 0,
  );

  final double totalFoundKg;
  final double totalPurchasedKg;
  final double totalLostKg;
  final double totalPendingKg;
  final double totalNotPurchasedKg;
  final double averageOfferPrice;
  final double purchaseRatePercent;

  @override
  List<Object?> get props => [
        totalFoundKg,
        totalPurchasedKg,
        totalLostKg,
        totalPendingKg,
        totalNotPurchasedKg,
        averageOfferPrice,
        purchaseRatePercent,
      ];
}
