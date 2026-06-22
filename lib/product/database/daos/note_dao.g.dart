// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dao.dart';

// ignore_for_file: type=lint
mixin _$NoteDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotesTable get notes => attachedDatabase.notes;
  $CustomersTable get customers => attachedDatabase.customers;
  NoteDaoManager get managers => NoteDaoManager(this);
}

class NoteDaoManager {
  final _$NoteDaoMixin _db;
  NoteDaoManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db.attachedDatabase, _db.notes);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
