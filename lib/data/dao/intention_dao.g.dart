// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intention_dao.dart';

// ignore_for_file: type=lint
mixin _$IntentionDaoMixin on DatabaseAccessor<CyaDatabase> {
  $IntentionsTable get intentions => attachedDatabase.intentions;
  $IntentionEventsTable get intentionEvents => attachedDatabase.intentionEvents;
  IntentionDaoManager get managers => IntentionDaoManager(this);
}

class IntentionDaoManager {
  final _$IntentionDaoMixin _db;
  IntentionDaoManager(this._db);
  $$IntentionsTableTableManager get intentions =>
      $$IntentionsTableTableManager(_db.attachedDatabase, _db.intentions);
  $$IntentionEventsTableTableManager get intentionEvents =>
      $$IntentionEventsTableTableManager(
        _db.attachedDatabase,
        _db.intentionEvents,
      );
}
