import 'package:drift/drift.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:Ok/product/utility/date_time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Local session persistence using SharedPreferences and Drift.
final class SessionService {
  SessionService(this._databaseService, this._preferences);

  static const sessionDuration = Duration(hours: 8);
  static const _activeSessionIdKey = 'active_session_id';

  final DatabaseService _databaseService;
  final SharedPreferences _preferences;
  final Uuid _uuid = const Uuid();

  Future<AuthSession> createSession(String userId) async {
    final now = DateTime.now();
    final sessionId = _uuid.v4();
    final token = _uuid.v4();

    await _databaseService.authSessions.insertSession(
      AuthSessionsCompanion.insert(
        id: sessionId,
        userId: userId,
        token: token,
        createdAt: Value(now),
        expiresAt: now.add(sessionDuration),
      ),
    );

    await _preferences.setString(_activeSessionIdKey, sessionId);

    final session =
        await _databaseService.authSessions.getSessionById(sessionId);
    if (session == null) {
      throw StateError('Session could not be created.');
    }
    return session;
  }

  Future<AuthSession?> getActiveSession() async {
    final sessionId = _preferences.getString(_activeSessionIdKey);
    if (sessionId == null || sessionId.isEmpty) {
      return null;
    }

    final session =
        await _databaseService.authSessions.getSessionById(sessionId);
    if (session == null || isSessionExpired(session)) {
      await clearSession();
      return null;
    }
    return session;
  }

  Future<void> clearSession() async {
    final sessionId = _preferences.getString(_activeSessionIdKey);
    if (sessionId != null && sessionId.isNotEmpty) {
      await _databaseService.authSessions.revokeSession(sessionId);
    }
    await _preferences.remove(_activeSessionIdKey);
  }

  bool isSessionExpired(AuthSession session) {
    if (session.revokedAt != null) {
      return true;
    }
    return DateTimeUtils.isInPast(session.expiresAt);
  }
}
