import 'dart:io';

import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class PriceListExportService {
  Future<bool> exportPriceListToExcel({
    required List<PriceListItemModel> items,
  }) async {
    if (items.isEmpty) {
      return false;
    }

    final excel = Excel.createExcel();
    const sheetTitle = 'Fiyat Listesi';
    final defaultSheetName = excel.sheets.keys.first;
    if (defaultSheetName != sheetTitle) {
      excel.rename(defaultSheetName, sheetTitle);
    }
    final sheet = excel[sheetTitle];

    sheet.appendRow([
      TextCellValue('Ürün Adı'),
      TextCellValue('Para Birimi'),
      TextCellValue('Min. Fiyat (kg)'),
      TextCellValue('Max. Fiyat (kg)'),
    ]);

    for (final item in items) {
      final currencyLabel = item.currencyType?.label ?? item.currency;
      sheet.appendRow([
        TextCellValue(item.productName),
        TextCellValue(currencyLabel),
        TextCellValue(MoneyUtils.formatAmountMinorForExport(item.minPriceMinor)),
        TextCellValue(MoneyUtils.formatAmountMinorForExport(item.maxPriceMinor)),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_fiyat_listesi_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Excel dosyasını kaydet',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
    );

    if (outputPath == null) {
      return false;
    }

    await File(outputPath).writeAsBytes(bytes);
    return true;
  }
}
