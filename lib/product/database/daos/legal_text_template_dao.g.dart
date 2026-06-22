// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_text_template_dao.dart';

// ignore_for_file: type=lint
mixin _$LegalTextTemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $LegalTextTemplatesTable get legalTextTemplates =>
      attachedDatabase.legalTextTemplates;
  LegalTextTemplateDaoManager get managers => LegalTextTemplateDaoManager(this);
}

class LegalTextTemplateDaoManager {
  final _$LegalTextTemplateDaoMixin _db;
  LegalTextTemplateDaoManager(this._db);
  $$LegalTextTemplatesTableTableManager get legalTextTemplates =>
      $$LegalTextTemplatesTableTableManager(
          _db.attachedDatabase, _db.legalTextTemplates);
}
