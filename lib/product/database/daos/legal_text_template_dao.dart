import 'package:drift/drift.dart';

import 'package:Ok/feature/price_offers/data/default_legal_text_templates.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/legal_text_templates_table.dart';

part 'legal_text_template_dao.g.dart';

@DriftAccessor(tables: [LegalTextTemplates])
class LegalTextTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$LegalTextTemplateDaoMixin {
  LegalTextTemplateDao(super.db);

  Future<LegalTextTemplate?> getByOfferType(String offerType) =>
      (select(legalTextTemplates)..where((t) => t.offerType.equals(offerType)))
          .getSingleOrNull();

  Future<List<LegalTextTemplate>> getAll() =>
      (select(legalTextTemplates)
            ..orderBy([(t) => OrderingTerm.asc(t.offerType)]))
          .get();

  Future<bool> updateTemplate({
    required String offerType,
    required String content,
  }) async {
    final affectedRows = await (update(legalTextTemplates)
          ..where((t) => t.offerType.equals(offerType)))
        .write(
      LegalTextTemplatesCompanion(
        content: Value(content),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return affectedRows > 0;
  }

  Future<void> seedDefaultsIfMissing() async {
    final now = DateTime.now();

    for (final entry in defaultLegalTextTemplates.entries) {
      await into(legalTextTemplates).insert(
        LegalTextTemplatesCompanion.insert(
          offerType: entry.key.value,
          content: entry.value,
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}
