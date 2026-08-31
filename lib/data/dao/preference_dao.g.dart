// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_dao.dart';

// ignore_for_file: type=lint
mixin _$PreferenceDaoMixin on DatabaseAccessor<CyaDatabase> {
  $PreferencesTable get preferences => attachedDatabase.preferences;
  PreferenceDaoManager get managers => PreferenceDaoManager(this);
}

class PreferenceDaoManager {
  final _$PreferenceDaoMixin _db;
  PreferenceDaoManager(this._db);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db.attachedDatabase, _db.preferences);
}
