import 'dart:io';

import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/feature/meetings/models/meeting_list_item.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class MeetingsExportService {
  Future<bool> exportMeetingsToExcel(List<MeetingListItem> meetings) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }
    final sheet = excel['Görüşmeler'];

    sheet.appendRow([
      TextCellValue('Müşteri adı'),
      TextCellValue('Tarih'),
      TextCellValue('Yöntem'),
      TextCellValue('Konu'),
      TextCellValue('Notlar'),
      TextCellValue('Oluşturulma tarihi'),
      TextCellValue('Güncellenme tarihi'),
    ]);

    for (final meeting in meetings) {
      sheet.appendRow([
        TextCellValue(meeting.customerName),
        TextCellValue(AppDateUtils.formatDate(meeting.date)),
        TextCellValue(meeting.meetingMethod?.label ?? meeting.method),
        TextCellValue(meeting.meetingSubject?.label ?? meeting.subject),
        TextCellValue(meeting.notes ?? ''),
        TextCellValue(AppDateUtils.formatDate(meeting.createdAt)),
        TextCellValue(AppDateUtils.formatDate(meeting.updatedAt)),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_gorusmeler_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

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
