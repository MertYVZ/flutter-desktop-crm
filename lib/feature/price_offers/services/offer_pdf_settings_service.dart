import 'package:Ok/feature/price_offers/models/offer_pdf_settings.dart';
import 'package:Ok/product/database/database_service.dart';

final class OfferPdfSettingsService {
  OfferPdfSettingsService(this._databaseService);

  final DatabaseService _databaseService;

  Future<OfferPdfSettings> getAll() async {
    await _databaseService.appSettings.seedOfferPdfDefaultsIfMissing();
    final values = await _databaseService.appSettings.getAllAsMap();
    return OfferPdfSettings.fromMap(values);
  }

  Future<void> save(OfferPdfSettings settings) async {
    await _databaseService.appSettings.upsertMany(settings.toKeyValueMap());
  }

  Future<void> seedDefaultsIfMissing() async {
    await _databaseService.appSettings.seedOfferPdfDefaultsIfMissing();
  }
}
