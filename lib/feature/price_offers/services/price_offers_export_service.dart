import 'dart:io';

import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

final class PriceOffersExportService {
  Future<bool> exportOffersToExcel(List<PriceOfferListItem> offers) async {
    final excel = Excel.createExcel();
    const sheetTitle = 'Fiyat Teklifleri';
    final defaultSheetName = excel.sheets.keys.first;
    if (defaultSheetName != sheetTitle) {
      excel.rename(defaultSheetName, sheetTitle);
    }
    final sheet = excel[sheetTitle];

    sheet.appendRow([
      TextCellValue('Teklif Tarihi'),
      TextCellValue('Geçerlilik Tarihi'),
      TextCellValue('Tip'),
      TextCellValue('Müşteri'),
      TextCellValue('İlgili Kişi'),
      TextCellValue('Yetkili Telefon'),
      TextCellValue('Yetkili Telefonu'),
      TextCellValue('Durum'),
      TextCellValue('Oluşturulma tarihi'),
      TextCellValue('Güncellenme tarihi'),
    ]);

    for (final offer in offers) {
      sheet.appendRow([
        TextCellValue(AppDateUtils.formatDate(offer.offerDate)),
        TextCellValue(AppDateUtils.formatDate(offer.validityDate)),
        TextCellValue(offer.offerType?.label ?? offer.type),
        TextCellValue(offer.customerName),
        TextCellValue(offer.contactPerson),
        TextCellValue(offer.displayAuthorizedPhone),
        TextCellValue(offer.displayMobilePhone),
        TextCellValue(offer.offerStatus?.label ?? offer.status),
        TextCellValue(AppDateUtils.formatDateTime(offer.createdAt)),
        TextCellValue(AppDateUtils.formatDateTime(offer.updatedAt)),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Excel encode failed');
    }

    final fileName =
        'ok_teknik_metal_crm_fiyat_teklifleri_${AppDateUtils.exportTimestamp.format(DateTime.now())}.xlsx';

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
