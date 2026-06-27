import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_summary.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

final class ScrapQualityExportService {
  Future<bool> exportRecordsToExcel({
    required List<ScrapQualityListItem> records,
    required ScrapQualitySummary summary,
    required DateTime month,
  }) async {
    final excel = Excel.createExcel();
    final sheetTitle = 'Hurda Takip';
    final defaultSheetName = excel.sheets.keys.first;
    if (defaultSheetName != sheetTitle) {
      excel.rename(defaultSheetName, sheetTitle);
    }
    final sheet = excel[sheetTitle];

    sheet.appendRow([
      TextCellValue('Müşteri Adı'),
      TextCellValue('Miktar'),
      TextCellValue('Birim'),
      TextCellValue('KG Karşılığı'),
      TextCellValue('Hurda Türü / Kalite'),
      TextCellValue('Tarih'),
      TextCellValue('İl'),
      TextCellValue('Satış Durumu'),
      TextCellValue('Teklif Fiyatı'),
      TextCellValue('Hedef Fiyat'),
      TextCellValue('Alınmama Nedeni'),
      TextCellValue('Notlar'),
    ]);

    for (final record in records) {
      sheet.appendRow([
        TextCellValue(record.displayCustomerName),
        TextCellValue(QuantityUtils.formatForExport(record.quantity)),
        TextCellValue(record.unit),
        TextCellValue(QuantityUtils.formatForExport(record.quantityKg)),
        TextCellValue(record.scrapType),
        TextCellValue(AppDateUtils.formatDate(record.recordDate)),
        TextCellValue(record.city ?? ''),
        TextCellValue(record.salesStatusEnum?.label ?? record.salesStatus),
        TextCellValue(
          record.offerPrice == null
              ? ''
              : MoneyUtils.formatAmountInput(record.offerPrice!),
        ),
        TextCellValue(
          record.targetPrice == null
              ? ''
              : MoneyUtils.formatAmountInput(record.targetPrice!),
        ),
        TextCellValue(record.lostReasonLabel ?? ''),
        TextCellValue(record.note ?? ''),
      ]);
    }

    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('Toplam Bulunan Hurda Miktarı'),
      TextCellValue(QuantityUtils.formatForExport(summary.totalFoundKg)),
    ]);
    sheet.appendRow([
      TextCellValue('Toplam Satın Alınan Hurda Miktarı'),
      TextCellValue(QuantityUtils.formatForExport(summary.totalPurchasedKg)),
    ]);
    sheet.appendRow([
      TextCellValue('Kaybedilen / Alınamayan Hurda Miktarı (Alınmadı)'),
      TextCellValue(
        QuantityUtils.formatForExport(summary.totalNotPurchasedKg),
      ),
    ]);
    sheet.appendRow([
      TextCellValue('Bekleyen / Sonuçlanmamış Hurda Miktarı'),
      TextCellValue(QuantityUtils.formatForExport(summary.totalPendingKg)),
    ]);
    sheet.appendRow([
      TextCellValue('Ortalama Teklif Fiyatı'),
      TextCellValue(
        summary.averageOfferPrice <= 0
            ? ''
            : MoneyUtils.formatAmountInput(summary.averageOfferPrice),
      ),
    ]);
    sheet.appendRow([
      TextCellValue('Alım Oranı'),
      TextCellValue('${summary.purchaseRatePercent.toStringAsFixed(1)}%'),
    ]);

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final monthLabel = AppDateUtils.turkishMonths[month.month - 1];
    final fileName =
        'Hurda_Takip_${monthLabel}_$month.year.xlsx'.replaceAll(' ', '_');

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
