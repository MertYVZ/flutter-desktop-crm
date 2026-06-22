import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/daos/app_settings_dao.dart';
import 'package:Ok/product/database/daos/auth_session_dao.dart';
import 'package:Ok/product/database/daos/customer_dao.dart';
import 'package:Ok/product/database/daos/due_record_dao.dart';
import 'package:Ok/product/database/daos/legal_text_template_dao.dart';
import 'package:Ok/product/database/daos/meeting_dao.dart';
import 'package:Ok/product/database/daos/note_dao.dart';
import 'package:Ok/product/database/daos/price_offer_dao.dart';
import 'package:Ok/product/database/daos/scrap_quality_dao.dart';
import 'package:Ok/product/database/daos/user_dao.dart';

/// Facade over [AppDatabase] for dependency injection and testability.
final class DatabaseService {
  DatabaseService(this._database);

  final AppDatabase _database;

  UserDao get users => _database.userDao;

  AuthSessionDao get authSessions => _database.authSessionDao;

  AppSettingsDao get appSettings => _database.appSettingsDao;

  CustomerDao get customers => _database.customerDao;

  DueRecordDao get dueRecords => _database.dueRecordDao;

  MeetingDao get meetings => _database.meetingDao;

  NoteDao get notes => _database.noteDao;

  ScrapQualityDao get scrapQualityRecords => _database.scrapQualityDao;

  PriceOfferDao get priceOffers => _database.priceOfferDao;

  LegalTextTemplateDao get legalTextTemplates => _database.legalTextTemplateDao;

  AppDatabase get database => _database;

  Future<void> close() => _database.close();
}
