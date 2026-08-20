import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:equatable/equatable.dart';

final class ExportTotals extends Equatable {
  const ExportTotals({
    required this.sentTotalMinor,
    required this.wasteTotalMinor,
    required this.afterWasteMinor,
    required this.netTotalMinor,
  });

  factory ExportTotals.fromItems({
    required Iterable<ExportItemData> items,
    int logisticsCostMinor = 0,
    int customsCostMinor = 0,
    int insuranceCostMinor = 0,
  }) {
    var sentTotalMinor = 0;
    var wasteTotalMinor = 0;
    for (final item in items) {
      sentTotalMinor += item.sentTotalMinor;
      wasteTotalMinor += item.wasteTotalMinor;
    }

    final afterWasteMinor = sentTotalMinor - wasteTotalMinor;
    final netTotalMinor = afterWasteMinor -
        logisticsCostMinor -
        customsCostMinor -
        insuranceCostMinor;

    return ExportTotals(
      sentTotalMinor: sentTotalMinor,
      wasteTotalMinor: wasteTotalMinor,
      afterWasteMinor: afterWasteMinor,
      netTotalMinor: netTotalMinor,
    );
  }

  factory ExportTotals.fromCostTexts({
    required Iterable<ExportItemData> items,
    required String logisticsCostText,
    required String customsCostText,
    required String insuranceCostText,
  }) {
    return ExportTotals.fromItems(
      items: items,
      logisticsCostMinor: _optionalAmount(logisticsCostText),
      customsCostMinor: _optionalAmount(customsCostText),
      insuranceCostMinor: _optionalAmount(insuranceCostText),
    );
  }

  static const empty = ExportTotals(
    sentTotalMinor: 0,
    wasteTotalMinor: 0,
    afterWasteMinor: 0,
    netTotalMinor: 0,
  );

  final int sentTotalMinor;
  final int wasteTotalMinor;
  final int afterWasteMinor;
  final int netTotalMinor;

  static int _optionalAmount(String text) =>
      MoneyUtils.parseAmountToMinor(text.trim()) ?? 0;

  @override
  List<Object?> get props => [
        sentTotalMinor,
        wasteTotalMinor,
        afterWasteMinor,
        netTotalMinor,
      ];
}
