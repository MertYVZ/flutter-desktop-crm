import 'package:Ok/feature/due_tracking/models/currency_type.dart'
    as due_currency;
import 'package:Ok/feature/price_offers/models/currency_type.dart';

due_currency.CurrencyType mapExportCurrency(PriceOfferCurrencyType? currency) {
  switch (currency) {
    case PriceOfferCurrencyType.usd:
      return due_currency.CurrencyType.usd;
    case PriceOfferCurrencyType.eur:
      return due_currency.CurrencyType.eur;
    case PriceOfferCurrencyType.try_:
    case null:
      return due_currency.CurrencyType.try_;
  }
}
