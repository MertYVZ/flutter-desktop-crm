import 'package:equatable/equatable.dart';

final class ScrapQualityAnalytics extends Equatable {
  const ScrapQualityAnalytics({
    this.topFoundCustomer,
    this.topPurchasedCustomer,
    this.topLostCustomer,
    this.topScrapType,
    this.topCity,
    this.highestOfferPrice,
    this.lowestOfferPrice,
  });

  final String? topFoundCustomer;
  final String? topPurchasedCustomer;
  final String? topLostCustomer;
  final String? topScrapType;
  final String? topCity;
  final double? highestOfferPrice;
  final double? lowestOfferPrice;

  @override
  List<Object?> get props => [
        topFoundCustomer,
        topPurchasedCustomer,
        topLostCustomer,
        topScrapType,
        topCity,
        highestOfferPrice,
        lowestOfferPrice,
      ];
}
