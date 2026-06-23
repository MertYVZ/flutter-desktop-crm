import 'dart:io';

import 'package:Ok/feature/price_offers/models/offer_pdf_settings.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/pdf/price_offer_pdf_builder.dart';
import 'package:Ok/feature/price_offers/services/offer_pdf_settings_service.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:file_picker/file_picker.dart';

final class PriceOfferPdfService {
  PriceOfferPdfService(this._settingsService);

  final OfferPdfSettingsService _settingsService;

  Future<bool> generateAndSavePdf({
    required PriceOfferDetail offer,
    OfferPdfSettings? settings,
  }) async {
    final pdfSettings = settings ?? await _settingsService.getAll();

    final builder = PriceOfferPdfBuilder(
      offer: offer,
      settings: pdfSettings,
    );
    final document = await builder.buildDocument();
    final bytes = await document.save();

    final customerSlug = _sanitizeFileNamePart(offer.customerName);
    final offerDatePart = AppDateUtils.displayDate.format(offer.offerDate);
    final generatedAt = AppDateUtils.exportTimestamp.format(DateTime.now());
    final fileName =
        'FiyatTeklifi_${customerSlug}_${offerDatePart}_$generatedAt.pdf';

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'PDF dosyasını kaydet',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (outputPath == null) {
      return false;
    }

    await File(outputPath).writeAsBytes(bytes);
    return true;
  }

  String _sanitizeFileNamePart(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    if (sanitized.isEmpty) {
      return 'teklif';
    }
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }
}
