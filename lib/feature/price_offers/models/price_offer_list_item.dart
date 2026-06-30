import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:equatable/equatable.dart';

final class PriceOfferListItem extends Equatable {
  const PriceOfferListItem({
    required this.id,
    required this.type,
    required this.offerDate,
    required this.validityDate,
    required this.customerId,
    required this.customerName,
    required this.contactPerson,
    required this.authorizedPhone,
    required this.mobilePhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final DateTime offerDate;
  final DateTime validityDate;
  final String customerId;
  final String customerName;
  final String contactPerson;
  final String? authorizedPhone;
  final String? mobilePhone;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferType? get offerType => OfferTypeX.fromValue(type);

  PriceOfferStatus? get offerStatus => PriceOfferStatusX.fromValue(status);

  String get displayAuthorizedPhone =>
      authorizedPhone == null || authorizedPhone!.trim().isEmpty
          ? '-'
          : authorizedPhone!;

  String get displayMobilePhone =>
      mobilePhone == null || mobilePhone!.trim().isEmpty
          ? '-'
          : mobilePhone!;

  @override
  List<Object?> get props => [
        id,
        type,
        offerDate,
        validityDate,
        customerId,
        customerName,
        contactPerson,
        authorizedPhone,
        mobilePhone,
        status,
        createdAt,
        updatedAt,
      ];
}

final class PriceOfferItemData extends Equatable {
  const PriceOfferItemData({
    required this.id,
    required this.productName,
    required this.unitType,
    required this.quantity,
    required this.priceMinor,
    required this.currency,
    required this.sortOrder,
  });

  final String id;
  final String productName;
  final String unitType;
  final double quantity;
  final int priceMinor;
  final String currency;
  final int sortOrder;

  PriceOfferCurrencyType? get currencyType =>
      PriceOfferCurrencyTypeX.fromValue(currency);

  double get rowTotalMinor => (quantity * priceMinor).roundToDouble();

  @override
  List<Object?> get props => [
        id,
        productName,
        unitType,
        quantity,
        priceMinor,
        currency,
        sortOrder,
      ];
}

final class PriceOfferDetail extends Equatable {
  const PriceOfferDetail({
    required this.id,
    required this.type,
    required this.offerDate,
    required this.validityDate,
    required this.customerId,
    required this.customerName,
    required this.contactPerson,
    required this.authorizedPhone,
    required this.mobilePhone,
    required this.legalText,
    required this.status,
    required this.discount,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  final String id;
  final String type;
  final DateTime offerDate;
  final DateTime validityDate;
  final String customerId;
  final String customerName;
  final String contactPerson;
  final String? authorizedPhone;
  final String? mobilePhone;
  final String legalText;
  final String status;
  final PriceOfferDiscount discount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PriceOfferItemData> items;

  OfferType? get offerType => OfferTypeX.fromValue(type);

  PriceOfferStatus? get offerStatus => PriceOfferStatusX.fromValue(status);

  String get displayAuthorizedPhone =>
      authorizedPhone == null || authorizedPhone!.trim().isEmpty
          ? '-'
          : authorizedPhone!;

  String get displayMobilePhone =>
      mobilePhone == null || mobilePhone!.trim().isEmpty
          ? '-'
          : mobilePhone!;

  @override
  List<Object?> get props => [
        id,
        type,
        offerDate,
        validityDate,
        customerId,
        customerName,
        contactPerson,
        authorizedPhone,
        mobilePhone,
        legalText,
        status,
        discount,
        createdAt,
        updatedAt,
        items,
      ];
}

final class PriceOfferItemInput {
  const PriceOfferItemInput({
    required this.productName,
    required this.unitType,
    required this.quantity,
    required this.priceMinor,
    required this.currency,
  });

  final String productName;
  final String unitType;
  final double quantity;
  final int priceMinor;
  final PriceOfferCurrencyType currency;
}
