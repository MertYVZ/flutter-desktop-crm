import 'dart:io';

import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class ScrapQualityExportService {
  Future<bool> exportRecordsToExcel(List<ScrapQualityListItem> records) async {
    final excel = Excel.createExcel();
    const sheetTitle = 'Hurda Kalite';
    final defaultSheetName = excel.sheets.keys.first;
    if (defaultSheetName != sheetTitle) {
      excel.rename(defaultSheetName, sheetTitle);
    }
    final sheet = excel[sheetTitle];

    sheet.appendRow([
      TextCellValue('Müşteri adı'),
      TextCellValue('Kalite'),
      TextCellValue('Miktar'),
      TextCellValue('Birim'),
      TextCellValue('Kayıt tarihi'),
      TextCellValue('Not'),
      TextCellValue('Oluşturulma tarihi'),
      TextCellValue('Güncellenme tarihi'),
    ]);

    for (final record in records) {
      sheet.appendRow([
        TextCellValue(record.customerName),
        TextCellValue(record.quality),
        TextCellValue(QuantityUtils.formatForExport(record.quantity)),
        TextCellValue(record.unit),
        TextCellValue(AppDateUtils.formatDate(record.recordDate)),
        TextCellValue(
          record.note == null || record.note!.trim().isEmpty
              ? '-'
              : record.note!,
        ),
        TextCellValue(AppDateUtils.formatDate(record.createdAt)),
        TextCellValue(AppDateUtils.formatDate(record.updatedAt)),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_hurda_kalite_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

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
