import 'dart:io';

import 'package:Ok/feature/due_tracking/models/due_record_display_status.dart';
import 'package:Ok/feature/due_tracking/models/due_record_list_item.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class DueTrackingExportService {
  Future<bool> exportDueRecordsToExcel(List<DueRecordListItem> records) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }
    final sheet = excel['Vade Takip'];

    sheet.appendRow([
      TextCellValue('Müşteri adı'),
      TextCellValue('Fatura no'),
      TextCellValue('Tutar'),
      TextCellValue('Para birimi'),
      TextCellValue('Vade tarihi'),
      TextCellValue('Durum'),
      TextCellValue('Oluşturulma tarihi'),
      TextCellValue('Güncellenme tarihi'),
    ]);

    for (final record in records) {
      sheet.appendRow([
        TextCellValue(record.customerName),
        TextCellValue(record.invoiceNo),
        TextCellValue(MoneyUtils.formatAmountMinorForExport(record.amountMinor)),
        TextCellValue(record.currency),
        TextCellValue(AppDateUtils.formatDate(record.dueDate)),
        TextCellValue(record.displayStatus.label),
        TextCellValue(AppDateUtils.formatDate(record.createdAt)),
        TextCellValue(AppDateUtils.formatDate(record.updatedAt)),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_vade_takip_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

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
