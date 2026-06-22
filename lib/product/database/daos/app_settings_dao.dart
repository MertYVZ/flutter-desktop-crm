import 'package:drift/drift.dart';

import 'package:Ok/feature/price_offers/models/offer_pdf_settings.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(appSettings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, String>> getAllAsMap() async {
    final rows = await select(appSettings).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> upsert(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertMany(Map<String, String> values) async {
    final now = DateTime.now();
    await batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          appSettings,
          AppSettingsCompanion.insert(
            key: entry.key,
            value: entry.value,
            updatedAt: Value(now),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> seedOfferPdfDefaultsIfMissing() async {
    final defaults = OfferPdfSettings.defaults.toKeyValueMap();
    final now = DateTime.now();

    for (final entry in defaults.entries) {
      await into(appSettings).insert(
        AppSettingsCompanion.insert(
          key: entry.key,
          value: entry.value,
          updatedAt: Value(now),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}
