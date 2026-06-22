import 'package:drift/drift.dart';

import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/auth_sessions_table.dart';

part 'auth_session_dao.g.dart';

@DriftAccessor(tables: [AuthSessions])
class AuthSessionDao extends DatabaseAccessor<AppDatabase>
    with _$AuthSessionDaoMixin {
  AuthSessionDao(super.db);

  Future<AuthSession?> getSessionById(String id) => (select(authSessions)
        ..where((t) => t.id.equals(id)))
      .getSingleOrNull();

  Future<int> insertSession(AuthSessionsCompanion session) =>
      into(authSessions).insert(session);

  Future<void> revokeSession(String id) => (update(authSessions)
        ..where((t) => t.id.equals(id)))
      .write(
        AuthSessionsCompanion(revokedAt: Value(DateTime.now())),
      );

  Future<void> revokeAllForUser(String userId) => (update(authSessions)
        ..where((t) => t.userId.equals(userId) & t.revokedAt.isNull()))
      .write(
        AuthSessionsCompanion(revokedAt: Value(DateTime.now())),
      );
}
