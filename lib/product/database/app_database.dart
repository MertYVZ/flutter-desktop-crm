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
  int get schemaVersion => 12;

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
        },
      );
}
