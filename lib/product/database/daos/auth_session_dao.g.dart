// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_dao.dart';

// ignore_for_file: type=lint
mixin _$AuthSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $AuthSessionsTable get authSessions => attachedDatabase.authSessions;
  AuthSessionDaoManager get managers => AuthSessionDaoManager(this);
}

class AuthSessionDaoManager {
  final _$AuthSessionDaoMixin _db;
  AuthSessionDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$AuthSessionsTableTableManager get authSessions =>
      $$AuthSessionsTableTableManager(_db.attachedDatabase, _db.authSessions);
}
