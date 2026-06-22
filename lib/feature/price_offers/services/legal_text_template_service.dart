import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/product/database/database_service.dart';

final class LegalTextTemplateService {
  LegalTextTemplateService(this._databaseService);

  final DatabaseService _databaseService;

  Future<String> getTemplateByOfferType(OfferType type) async {
    final template =
        await _databaseService.legalTextTemplates.getByOfferType(type.value);
    return template?.content ?? '';
  }

  Future<Map<OfferType, String>> getAllTemplates() async {
    final rows = await _databaseService.legalTextTemplates.getAll();
    final result = <OfferType, String>{};

    for (final type in OfferType.values) {
      result[type] = '';
    }

    for (final row in rows) {
      final type = OfferTypeX.fromValue(row.offerType);
      if (type != null) {
        result[type] = row.content;
      }
    }

    return result;
  }

  Future<bool> updateTemplate({
    required OfferType type,
    required String content,
  }) async {
    return _databaseService.legalTextTemplates.updateTemplate(
      offerType: type.value,
      content: content,
    );
  }
}
