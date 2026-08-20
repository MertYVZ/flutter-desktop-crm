import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:equatable/equatable.dart';

final class ImportDetail extends Equatable {
  const ImportDetail({
    required this.record,
    required this.items,
  });

  final ImportRecord record;
  final List<ExportItemData> items;

  String get id => record.id;

  PriceOfferCurrencyType get currency =>
      PriceOfferCurrencyTypeX.fromValue(record.currency) ??
      PriceOfferCurrencyType.try_;

  @override
  List<Object?> get props => [record, items];
}
