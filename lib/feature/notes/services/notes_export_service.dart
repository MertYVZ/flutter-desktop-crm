import 'dart:io';

import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class NotesExportService {
  Future<bool> exportNotesToExcel(List<NoteListItem> records) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }
    final sheet = excel['Not Defteri'];

    sheet.appendRow([
      TextCellValue('Müşteri'),
      TextCellValue('Başlık'),
      TextCellValue('İçerik'),
      TextCellValue('Oluşturulma tarihi'),
      TextCellValue('Güncellenme tarihi'),
    ]);

    for (final note in records) {
      sheet.appendRow([
        TextCellValue(note.displayCustomerName),
        TextCellValue(note.title),
        TextCellValue(note.content),
        TextCellValue(AppDateUtils.formatDateTime(note.createdAt)),
        TextCellValue(AppDateUtils.formatDateTime(note.updatedAt)),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_not_defteri_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

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
