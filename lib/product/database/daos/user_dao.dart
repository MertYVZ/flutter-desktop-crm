import 'package:drift/drift.dart';

import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<User?> getUserById(String id) =>
      (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<User?> getUserByUsername(String username) => (select(users)
        ..where(
          (t) =>
              t.username.equals(username) &
              t.deletedAt.isNull(),
        ))
      .getSingleOrNull();

  Future<int> countActiveUsers() => (select(users)
        ..where((t) => t.deletedAt.isNull()))
      .get()
      .then((rows) => rows.length);

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(User user) => update(users).replace(user);
}
