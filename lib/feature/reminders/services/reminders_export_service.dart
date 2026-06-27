import 'dart:io';

import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class RemindersExportService {
  Future<bool> exportRemindersToExcel(List<ReminderListItem> records) async {
    final excel = Excel.createExcel();
    const sheetTitle = 'Hatırlatmalar';
    final defaultSheetName = excel.sheets.keys.first;
    if (defaultSheetName != sheetTitle) {
      excel.rename(defaultSheetName, sheetTitle);
    }
    final sheet = excel[sheetTitle];

    sheet.appendRow([
      TextCellValue('Müşteri Adı'),
      TextCellValue('Başlık'),
      TextCellValue('Periyot'),
      TextCellValue('Hatırlatma Tarihi'),
      TextCellValue('Bir Sonraki Hatırlatma Tarihi'),
      TextCellValue('Durum'),
      TextCellValue('Not'),
      TextCellValue('Son Tamamlanma'),
    ]);

    for (final reminder in records) {
      sheet.appendRow([
        TextCellValue(reminder.customerName),
        TextCellValue(reminder.title),
        TextCellValue(reminder.reminderPeriod?.label ?? reminder.period),
        TextCellValue(AppDateUtils.formatDate(reminder.startDate)),
        TextCellValue(AppDateUtils.formatDate(reminder.nextReminderDate)),
        TextCellValue(reminder.reminderStatus?.label ?? reminder.status),
        TextCellValue(reminder.note ?? ''),
        TextCellValue(
          reminder.lastCompletedAt == null
              ? ''
              : AppDateUtils.formatDateTime(reminder.lastCompletedAt!),
        ),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_hatirlatmalar_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

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
