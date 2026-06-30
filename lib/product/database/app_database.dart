import 'package:drift/drift.dart';

import 'package:Ok/product/database/connection/native_database_connection.dart';
import 'package:Ok/product/database/daos/app_settings_dao.dart';
import 'package:Ok/product/database/daos/auth_session_dao.dart';
import 'package:Ok/product/database/daos/customer_contact_dao.dart';
import 'package:Ok/product/database/daos/customer_dao.dart';
import 'package:Ok/product/database/daos/due_record_dao.dart';
import 'package:Ok/product/database/daos/meeting_dao.dart';
import 'package:Ok/product/database/daos/note_dao.dart';
import 'package:Ok/product/database/daos/legal_text_template_dao.dart';
import 'package:Ok/product/database/daos/price_list_dao.dart';
import 'package:Ok/product/database/daos/price_offer_dao.dart';
import 'package:Ok/product/database/daos/reminder_dao.dart';
import 'package:Ok/product/database/daos/scrap_quality_dao.dart';
import 'package:Ok/product/database/daos/user_dao.dart';
import 'package:Ok/product/database/tables/app_settings_table.dart';
import 'package:Ok/product/database/tables/auth_sessions_table.dart';
import 'package:Ok/product/database/tables/customer_contacts_table.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/due_records_table.dart';
import 'package:Ok/product/database/tables/meetings_table.dart';
import 'package:Ok/product/database/tables/notes_table.dart';
import 'package:Ok/product/database/tables/legal_text_templates_table.dart';
import 'package:Ok/product/database/tables/price_list_items_table.dart';
import 'package:Ok/product/database/tables/price_lists_table.dart';
import 'package:Ok/product/database/tables/price_offer_items_table.dart';
import 'package:Ok/product/database/tables/price_offers_table.dart';
import 'package:Ok/product/database/tables/reminders_table.dart';
import 'package:Ok/product/database/tables/scrap_quality_records_table.dart';
import 'package:Ok/product/database/tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    AuthSessions,
    AppSettings,
    Customers,
    CustomerContacts,
    DueRecords,
    Meetings,
    Notes,
    ScrapQualityRecords,
    PriceOffers,
    PriceOfferItems,
    LegalTextTemplates,
    Reminders,
    PriceLists,
    PriceListItems,
  ],
  daos: [
    UserDao,
    AuthSessionDao,
    AppSettingsDao,
    CustomerDao,
    CustomerContactDao,
    DueRecordDao,
    MeetingDao,
    NoteDao,
    ScrapQualityDao,
    PriceOfferDao,
    LegalTextTemplateDao,
    ReminderDao,
    PriceListDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openNativeConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await legalTextTemplateDao.seedDefaultsIfMissing();
          await appSettingsDao.seedOfferPdfDefaultsIfMissing();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(customers);
          }
          if (from < 3) {
            await m.createTable(dueRecords);
          }
          if (from < 4) {
            await m.createTable(meetings);
          }
          if (from < 5) {
            await m.createTable(scrapQualityRecords);
          }
          if (from < 6) {
            await m.createTable(notes);
          }
          if (from < 7) {
            await m.createTable(priceOffers);
            await m.createTable(priceOfferItems);
          }
          if (from < 8) {
            await m.createTable(legalTextTemplates);
            await legalTextTemplateDao.seedDefaultsIfMissing();
          }
          if (from < 9) {
            await appSettingsDao.seedOfferPdfDefaultsIfMissing();
          }
          if (from < 10) {
            await m.createTable(reminders);
          }
          if (from < 11) {
            await m.createTable(priceLists);
            await m.createTable(priceListItems);
          }
          if (from < 12) {
            await m.createTable(customerContacts);
          }
          if (from < 13) {
            final hasValidityDate = await customSelect(
              "SELECT 1 FROM pragma_table_info('price_offers') "
              "WHERE name = 'validity_date' LIMIT 1",
            ).getSingleOrNull();

            if (hasValidityDate == null) {
              // SQLite cannot ADD NOT NULL without default on populated tables.
              await customStatement(
                'ALTER TABLE price_offers ADD COLUMN validity_date INTEGER',
              );
            }

            await customStatement(
              'UPDATE price_offers SET validity_date = offer_date + 604800000 '
              'WHERE validity_date IS NULL',
            );
          }
          if (from < 14) {
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'customer_name_snapshot',
              'TEXT',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'quantity_kg',
              'REAL DEFAULT 0',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'city',
              'TEXT',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'sales_status',
              "TEXT DEFAULT 'unresolved'",
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'offer_price',
              'REAL',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'target_price',
              'REAL',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'lost_reason',
              'TEXT',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'follow_up_date',
              'INTEGER',
            );

            await customStatement('''
              UPDATE scrap_quality_records
              SET quantity_kg = CASE
                WHEN LOWER(unit) = 'kg' THEN quantity
                WHEN LOWER(unit) = 'ton' THEN quantity * 1000
                WHEN LOWER(unit) = 'gram' THEN quantity / 1000.0
                ELSE quantity
              END
              WHERE quantity_kg IS NULL OR quantity_kg = 0
            ''');

            await customStatement('''
              UPDATE scrap_quality_records
              SET sales_status = 'unresolved'
              WHERE sales_status IS NULL OR TRIM(sales_status) = ''
            ''');

            await customStatement('''
              UPDATE scrap_quality_records
              SET customer_name_snapshot = (
                SELECT name FROM customers
                WHERE customers.id = scrap_quality_records.customer_id
              )
              WHERE customer_name_snapshot IS NULL
            ''');
          }
          if (from < 15) {
            await _addColumnIfNotExists(
              'price_offers',
              'discount_type',
              'TEXT',
            );
            await _addColumnIfNotExists(
              'price_offers',
              'discount_percentage',
              'REAL',
            );
            await _addColumnIfNotExists(
              'price_offers',
              'discount_amount_minor',
              'INTEGER',
            );
            await _addColumnIfNotExists(
              'price_offers',
              'discount_currency',
              'TEXT',
            );
          }
          if (from < 16) {
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'quality_grade',
              'TEXT',
            );
            await _addColumnIfNotExists(
              'scrap_quality_records',
              'currency',
              'TEXT',
            );
          }
        },
      );

  Future<void> _addColumnIfNotExists(
    String table,
    String column,
    String definition,
  ) async {
    final exists = await customSelect(
      "SELECT 1 FROM pragma_table_info('$table') "
      "WHERE name = '$column' LIMIT 1",
    ).getSingleOrNull();

    if (exists == null) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}
