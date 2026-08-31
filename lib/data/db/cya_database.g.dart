// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cya_database.dart';

// ignore_for_file: type=lint
class $IntentionsTable extends Intentions
    with TableInfo<$IntentionsTable, IntentionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntentionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceAppMeta = const VerificationMeta(
    'sourceApp',
  );
  @override
  late final GeneratedColumn<String> sourceApp = GeneratedColumn<String>(
    'source_app',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawContentMeta = const VerificationMeta(
    'rawContent',
  );
  @override
  late final GeneratedColumn<String> rawContent = GeneratedColumn<String>(
    'raw_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deepLinkMeta = const VerificationMeta(
    'deepLink',
  );
  @override
  late final GeneratedColumn<String> deepLink = GeneratedColumn<String>(
    'deep_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderAtMeta = const VerificationMeta(
    'reminderAt',
  );
  @override
  late final GeneratedColumn<DateTime> reminderAt = GeneratedColumn<DateTime>(
    'reminder_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _extractedDeadlineMeta = const VerificationMeta(
    'extractedDeadline',
  );
  @override
  late final GeneratedColumn<DateTime> extractedDeadline =
      GeneratedColumn<DateTime>(
        'extracted_deadline',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceApp,
    rawContent,
    snippet,
    deepLink,
    capturedAt,
    reminderAt,
    category,
    status,
    snoozeCount,
    extractedDeadline,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intentions';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntentionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_app')) {
      context.handle(
        _sourceAppMeta,
        sourceApp.isAcceptableOrUnknown(data['source_app']!, _sourceAppMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceAppMeta);
    }
    if (data.containsKey('raw_content')) {
      context.handle(
        _rawContentMeta,
        rawContent.isAcceptableOrUnknown(data['raw_content']!, _rawContentMeta),
      );
    } else if (isInserting) {
      context.missing(_rawContentMeta);
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    }
    if (data.containsKey('deep_link')) {
      context.handle(
        _deepLinkMeta,
        deepLink.isAcceptableOrUnknown(data['deep_link']!, _deepLinkMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
        _reminderAtMeta,
        reminderAt.isAcceptableOrUnknown(data['reminder_at']!, _reminderAtMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('extracted_deadline')) {
      context.handle(
        _extractedDeadlineMeta,
        extractedDeadline.isAcceptableOrUnknown(
          data['extracted_deadline']!,
          _extractedDeadlineMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntentionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntentionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceApp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_app'],
      )!,
      rawContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_content'],
      )!,
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      ),
      deepLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deep_link'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      reminderAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_at'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      extractedDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}extracted_deadline'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $IntentionsTable createAlias(String alias) {
    return $IntentionsTable(attachedDatabase, alias);
  }
}

class IntentionRow extends DataClass implements Insertable<IntentionRow> {
  final int id;
  final String sourceApp;
  final String rawContent;
  final String? snippet;
  final String? deepLink;
  final DateTime capturedAt;
  final DateTime? reminderAt;
  final String? category;
  final String status;
  final int snoozeCount;
  final DateTime? extractedDeadline;
  final DateTime updatedAt;
  const IntentionRow({
    required this.id,
    required this.sourceApp,
    required this.rawContent,
    this.snippet,
    this.deepLink,
    required this.capturedAt,
    this.reminderAt,
    this.category,
    required this.status,
    required this.snoozeCount,
    this.extractedDeadline,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_app'] = Variable<String>(sourceApp);
    map['raw_content'] = Variable<String>(rawContent);
    if (!nullToAbsent || snippet != null) {
      map['snippet'] = Variable<String>(snippet);
    }
    if (!nullToAbsent || deepLink != null) {
      map['deep_link'] = Variable<String>(deepLink);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<DateTime>(reminderAt);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['status'] = Variable<String>(status);
    map['snooze_count'] = Variable<int>(snoozeCount);
    if (!nullToAbsent || extractedDeadline != null) {
      map['extracted_deadline'] = Variable<DateTime>(extractedDeadline);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IntentionsCompanion toCompanion(bool nullToAbsent) {
    return IntentionsCompanion(
      id: Value(id),
      sourceApp: Value(sourceApp),
      rawContent: Value(rawContent),
      snippet: snippet == null && nullToAbsent
          ? const Value.absent()
          : Value(snippet),
      deepLink: deepLink == null && nullToAbsent
          ? const Value.absent()
          : Value(deepLink),
      capturedAt: Value(capturedAt),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      status: Value(status),
      snoozeCount: Value(snoozeCount),
      extractedDeadline: extractedDeadline == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedDeadline),
      updatedAt: Value(updatedAt),
    );
  }

  factory IntentionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntentionRow(
      id: serializer.fromJson<int>(json['id']),
      sourceApp: serializer.fromJson<String>(json['sourceApp']),
      rawContent: serializer.fromJson<String>(json['rawContent']),
      snippet: serializer.fromJson<String?>(json['snippet']),
      deepLink: serializer.fromJson<String?>(json['deepLink']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      reminderAt: serializer.fromJson<DateTime?>(json['reminderAt']),
      category: serializer.fromJson<String?>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      extractedDeadline: serializer.fromJson<DateTime?>(
        json['extractedDeadline'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceApp': serializer.toJson<String>(sourceApp),
      'rawContent': serializer.toJson<String>(rawContent),
      'snippet': serializer.toJson<String?>(snippet),
      'deepLink': serializer.toJson<String?>(deepLink),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'reminderAt': serializer.toJson<DateTime?>(reminderAt),
      'category': serializer.toJson<String?>(category),
      'status': serializer.toJson<String>(status),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'extractedDeadline': serializer.toJson<DateTime?>(extractedDeadline),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  IntentionRow copyWith({
    int? id,
    String? sourceApp,
    String? rawContent,
    Value<String?> snippet = const Value.absent(),
    Value<String?> deepLink = const Value.absent(),
    DateTime? capturedAt,
    Value<DateTime?> reminderAt = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? status,
    int? snoozeCount,
    Value<DateTime?> extractedDeadline = const Value.absent(),
    DateTime? updatedAt,
  }) => IntentionRow(
    id: id ?? this.id,
    sourceApp: sourceApp ?? this.sourceApp,
    rawContent: rawContent ?? this.rawContent,
    snippet: snippet.present ? snippet.value : this.snippet,
    deepLink: deepLink.present ? deepLink.value : this.deepLink,
    capturedAt: capturedAt ?? this.capturedAt,
    reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
    category: category.present ? category.value : this.category,
    status: status ?? this.status,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    extractedDeadline: extractedDeadline.present
        ? extractedDeadline.value
        : this.extractedDeadline,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  IntentionRow copyWithCompanion(IntentionsCompanion data) {
    return IntentionRow(
      id: data.id.present ? data.id.value : this.id,
      sourceApp: data.sourceApp.present ? data.sourceApp.value : this.sourceApp,
      rawContent: data.rawContent.present
          ? data.rawContent.value
          : this.rawContent,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      deepLink: data.deepLink.present ? data.deepLink.value : this.deepLink,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      reminderAt: data.reminderAt.present
          ? data.reminderAt.value
          : this.reminderAt,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      extractedDeadline: data.extractedDeadline.present
          ? data.extractedDeadline.value
          : this.extractedDeadline,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntentionRow(')
          ..write('id: $id, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('rawContent: $rawContent, ')
          ..write('snippet: $snippet, ')
          ..write('deepLink: $deepLink, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('extractedDeadline: $extractedDeadline, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceApp,
    rawContent,
    snippet,
    deepLink,
    capturedAt,
    reminderAt,
    category,
    status,
    snoozeCount,
    extractedDeadline,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntentionRow &&
          other.id == this.id &&
          other.sourceApp == this.sourceApp &&
          other.rawContent == this.rawContent &&
          other.snippet == this.snippet &&
          other.deepLink == this.deepLink &&
          other.capturedAt == this.capturedAt &&
          other.reminderAt == this.reminderAt &&
          other.category == this.category &&
          other.status == this.status &&
          other.snoozeCount == this.snoozeCount &&
          other.extractedDeadline == this.extractedDeadline &&
          other.updatedAt == this.updatedAt);
}

class IntentionsCompanion extends UpdateCompanion<IntentionRow> {
  final Value<int> id;
  final Value<String> sourceApp;
  final Value<String> rawContent;
  final Value<String?> snippet;
  final Value<String?> deepLink;
  final Value<DateTime> capturedAt;
  final Value<DateTime?> reminderAt;
  final Value<String?> category;
  final Value<String> status;
  final Value<int> snoozeCount;
  final Value<DateTime?> extractedDeadline;
  final Value<DateTime> updatedAt;
  const IntentionsCompanion({
    this.id = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.rawContent = const Value.absent(),
    this.snippet = const Value.absent(),
    this.deepLink = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.extractedDeadline = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  IntentionsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceApp,
    required String rawContent,
    this.snippet = const Value.absent(),
    this.deepLink = const Value.absent(),
    required DateTime capturedAt,
    this.reminderAt = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.extractedDeadline = const Value.absent(),
    required DateTime updatedAt,
  }) : sourceApp = Value(sourceApp),
       rawContent = Value(rawContent),
       capturedAt = Value(capturedAt),
       updatedAt = Value(updatedAt);
  static Insertable<IntentionRow> custom({
    Expression<int>? id,
    Expression<String>? sourceApp,
    Expression<String>? rawContent,
    Expression<String>? snippet,
    Expression<String>? deepLink,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? reminderAt,
    Expression<String>? category,
    Expression<String>? status,
    Expression<int>? snoozeCount,
    Expression<DateTime>? extractedDeadline,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceApp != null) 'source_app': sourceApp,
      if (rawContent != null) 'raw_content': rawContent,
      if (snippet != null) 'snippet': snippet,
      if (deepLink != null) 'deep_link': deepLink,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (extractedDeadline != null) 'extracted_deadline': extractedDeadline,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  IntentionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceApp,
    Value<String>? rawContent,
    Value<String?>? snippet,
    Value<String?>? deepLink,
    Value<DateTime>? capturedAt,
    Value<DateTime?>? reminderAt,
    Value<String?>? category,
    Value<String>? status,
    Value<int>? snoozeCount,
    Value<DateTime?>? extractedDeadline,
    Value<DateTime>? updatedAt,
  }) {
    return IntentionsCompanion(
      id: id ?? this.id,
      sourceApp: sourceApp ?? this.sourceApp,
      rawContent: rawContent ?? this.rawContent,
      snippet: snippet ?? this.snippet,
      deepLink: deepLink ?? this.deepLink,
      capturedAt: capturedAt ?? this.capturedAt,
      reminderAt: reminderAt ?? this.reminderAt,
      category: category ?? this.category,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      extractedDeadline: extractedDeadline ?? this.extractedDeadline,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceApp.present) {
      map['source_app'] = Variable<String>(sourceApp.value);
    }
    if (rawContent.present) {
      map['raw_content'] = Variable<String>(rawContent.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (deepLink.present) {
      map['deep_link'] = Variable<String>(deepLink.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<DateTime>(reminderAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (extractedDeadline.present) {
      map['extracted_deadline'] = Variable<DateTime>(extractedDeadline.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntentionsCompanion(')
          ..write('id: $id, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('rawContent: $rawContent, ')
          ..write('snippet: $snippet, ')
          ..write('deepLink: $deepLink, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('extractedDeadline: $extractedDeadline, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $IntentionEventsTable extends IntentionEvents
    with TableInfo<$IntentionEventsTable, IntentionEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntentionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _intentionIdMeta = const VerificationMeta(
    'intentionId',
  );
  @override
  late final GeneratedColumn<int> intentionId = GeneratedColumn<int>(
    'intention_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES intentions (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    intentionId,
    type,
    occurredAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intention_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntentionEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('intention_id')) {
      context.handle(
        _intentionIdMeta,
        intentionId.isAcceptableOrUnknown(
          data['intention_id']!,
          _intentionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intentionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntentionEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntentionEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      intentionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intention_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $IntentionEventsTable createAlias(String alias) {
    return $IntentionEventsTable(attachedDatabase, alias);
  }
}

class IntentionEventRow extends DataClass
    implements Insertable<IntentionEventRow> {
  final int id;
  final int intentionId;
  final String type;
  final DateTime occurredAt;
  final String? metadata;
  const IntentionEventRow({
    required this.id,
    required this.intentionId,
    required this.type,
    required this.occurredAt,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['intention_id'] = Variable<int>(intentionId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  IntentionEventsCompanion toCompanion(bool nullToAbsent) {
    return IntentionEventsCompanion(
      id: Value(id),
      intentionId: Value(intentionId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory IntentionEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntentionEventRow(
      id: serializer.fromJson<int>(json['id']),
      intentionId: serializer.fromJson<int>(json['intentionId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'intentionId': serializer.toJson<int>(intentionId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  IntentionEventRow copyWith({
    int? id,
    int? intentionId,
    String? type,
    DateTime? occurredAt,
    Value<String?> metadata = const Value.absent(),
  }) => IntentionEventRow(
    id: id ?? this.id,
    intentionId: intentionId ?? this.intentionId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  IntentionEventRow copyWithCompanion(IntentionEventsCompanion data) {
    return IntentionEventRow(
      id: data.id.present ? data.id.value : this.id,
      intentionId: data.intentionId.present
          ? data.intentionId.value
          : this.intentionId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntentionEventRow(')
          ..write('id: $id, ')
          ..write('intentionId: $intentionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, intentionId, type, occurredAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntentionEventRow &&
          other.id == this.id &&
          other.intentionId == this.intentionId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.metadata == this.metadata);
}

class IntentionEventsCompanion extends UpdateCompanion<IntentionEventRow> {
  final Value<int> id;
  final Value<int> intentionId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String?> metadata;
  const IntentionEventsCompanion({
    this.id = const Value.absent(),
    this.intentionId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  IntentionEventsCompanion.insert({
    this.id = const Value.absent(),
    required int intentionId,
    required String type,
    required DateTime occurredAt,
    this.metadata = const Value.absent(),
  }) : intentionId = Value(intentionId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<IntentionEventRow> custom({
    Expression<int>? id,
    Expression<int>? intentionId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (intentionId != null) 'intention_id': intentionId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadata != null) 'metadata': metadata,
    });
  }

  IntentionEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? intentionId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String?>? metadata,
  }) {
    return IntentionEventsCompanion(
      id: id ?? this.id,
      intentionId: intentionId ?? this.intentionId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (intentionId.present) {
      map['intention_id'] = Variable<int>(intentionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntentionEventsCompanion(')
          ..write('id: $id, ')
          ..write('intentionId: $intentionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, PreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  PreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class PreferenceRow extends DataClass implements Insertable<PreferenceRow> {
  final String key;
  final String value;
  const PreferenceRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory PreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  PreferenceRow copyWith({String? key, String? value}) =>
      PreferenceRow(key: key ?? this.key, value: value ?? this.value);
  PreferenceRow copyWithCompanion(PreferencesCompanion data) {
    return PreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceRow &&
          other.key == this.key &&
          other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<PreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<PreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CyaDatabase extends GeneratedDatabase {
  _$CyaDatabase(QueryExecutor e) : super(e);
  $CyaDatabaseManager get managers => $CyaDatabaseManager(this);
  late final $IntentionsTable intentions = $IntentionsTable(this);
  late final $IntentionEventsTable intentionEvents = $IntentionEventsTable(
    this,
  );
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final IntentionDao intentionDao = IntentionDao(this as CyaDatabase);
  late final PreferenceDao preferenceDao = PreferenceDao(this as CyaDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    intentions,
    intentionEvents,
    preferences,
  ];
}

typedef $$IntentionsTableCreateCompanionBuilder =
    IntentionsCompanion Function({
      Value<int> id,
      required String sourceApp,
      required String rawContent,
      Value<String?> snippet,
      Value<String?> deepLink,
      required DateTime capturedAt,
      Value<DateTime?> reminderAt,
      Value<String?> category,
      Value<String> status,
      Value<int> snoozeCount,
      Value<DateTime?> extractedDeadline,
      required DateTime updatedAt,
    });
typedef $$IntentionsTableUpdateCompanionBuilder =
    IntentionsCompanion Function({
      Value<int> id,
      Value<String> sourceApp,
      Value<String> rawContent,
      Value<String?> snippet,
      Value<String?> deepLink,
      Value<DateTime> capturedAt,
      Value<DateTime?> reminderAt,
      Value<String?> category,
      Value<String> status,
      Value<int> snoozeCount,
      Value<DateTime?> extractedDeadline,
      Value<DateTime> updatedAt,
    });

final class $$IntentionsTableReferences
    extends BaseReferences<_$CyaDatabase, $IntentionsTable, IntentionRow> {
  $$IntentionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IntentionEventsTable, List<IntentionEventRow>>
  _intentionEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.intentionEvents,
    aliasName: 'intentions__id__intention_events__intention_id',
  );

  $$IntentionEventsTableProcessedTableManager get intentionEventsRefs {
    final manager = $$IntentionEventsTableTableManager(
      $_db,
      $_db.intentionEvents,
    ).filter((f) => f.intentionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _intentionEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IntentionsTableFilterComposer
    extends Composer<_$CyaDatabase, $IntentionsTable> {
  $$IntentionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deepLink => $composableBuilder(
    column: $table.deepLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get extractedDeadline => $composableBuilder(
    column: $table.extractedDeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> intentionEventsRefs(
    Expression<bool> Function($$IntentionEventsTableFilterComposer f) f,
  ) {
    final $$IntentionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intentionEvents,
      getReferencedColumn: (t) => t.intentionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionEventsTableFilterComposer(
            $db: $db,
            $table: $db.intentionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntentionsTableOrderingComposer
    extends Composer<_$CyaDatabase, $IntentionsTable> {
  $$IntentionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deepLink => $composableBuilder(
    column: $table.deepLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get extractedDeadline => $composableBuilder(
    column: $table.extractedDeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IntentionsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $IntentionsTable> {
  $$IntentionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceApp =>
      $composableBuilder(column: $table.sourceApp, builder: (column) => column);

  GeneratedColumn<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<String> get deepLink =>
      $composableBuilder(column: $table.deepLink, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get extractedDeadline => $composableBuilder(
    column: $table.extractedDeadline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> intentionEventsRefs<T extends Object>(
    Expression<T> Function($$IntentionEventsTableAnnotationComposer a) f,
  ) {
    final $$IntentionEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intentionEvents,
      getReferencedColumn: (t) => t.intentionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.intentionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntentionsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $IntentionsTable,
          IntentionRow,
          $$IntentionsTableFilterComposer,
          $$IntentionsTableOrderingComposer,
          $$IntentionsTableAnnotationComposer,
          $$IntentionsTableCreateCompanionBuilder,
          $$IntentionsTableUpdateCompanionBuilder,
          (IntentionRow, $$IntentionsTableReferences),
          IntentionRow,
          PrefetchHooks Function({bool intentionEventsRefs})
        > {
  $$IntentionsTableTableManager(_$CyaDatabase db, $IntentionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntentionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntentionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntentionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceApp = const Value.absent(),
                Value<String> rawContent = const Value.absent(),
                Value<String?> snippet = const Value.absent(),
                Value<String?> deepLink = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<DateTime?> extractedDeadline = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => IntentionsCompanion(
                id: id,
                sourceApp: sourceApp,
                rawContent: rawContent,
                snippet: snippet,
                deepLink: deepLink,
                capturedAt: capturedAt,
                reminderAt: reminderAt,
                category: category,
                status: status,
                snoozeCount: snoozeCount,
                extractedDeadline: extractedDeadline,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceApp,
                required String rawContent,
                Value<String?> snippet = const Value.absent(),
                Value<String?> deepLink = const Value.absent(),
                required DateTime capturedAt,
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<DateTime?> extractedDeadline = const Value.absent(),
                required DateTime updatedAt,
              }) => IntentionsCompanion.insert(
                id: id,
                sourceApp: sourceApp,
                rawContent: rawContent,
                snippet: snippet,
                deepLink: deepLink,
                capturedAt: capturedAt,
                reminderAt: reminderAt,
                category: category,
                status: status,
                snoozeCount: snoozeCount,
                extractedDeadline: extractedDeadline,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntentionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({intentionEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (intentionEventsRefs) db.intentionEvents,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (intentionEventsRefs)
                    await $_getPrefetchedData<
                      IntentionRow,
                      $IntentionsTable,
                      IntentionEventRow
                    >(
                      currentTable: table,
                      referencedTable: $$IntentionsTableReferences
                          ._intentionEventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IntentionsTableReferences(
                            db,
                            table,
                            p0,
                          ).intentionEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.intentionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IntentionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $IntentionsTable,
      IntentionRow,
      $$IntentionsTableFilterComposer,
      $$IntentionsTableOrderingComposer,
      $$IntentionsTableAnnotationComposer,
      $$IntentionsTableCreateCompanionBuilder,
      $$IntentionsTableUpdateCompanionBuilder,
      (IntentionRow, $$IntentionsTableReferences),
      IntentionRow,
      PrefetchHooks Function({bool intentionEventsRefs})
    >;
typedef $$IntentionEventsTableCreateCompanionBuilder =
    IntentionEventsCompanion Function({
      Value<int> id,
      required int intentionId,
      required String type,
      required DateTime occurredAt,
      Value<String?> metadata,
    });
typedef $$IntentionEventsTableUpdateCompanionBuilder =
    IntentionEventsCompanion Function({
      Value<int> id,
      Value<int> intentionId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String?> metadata,
    });

final class $$IntentionEventsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $IntentionEventsTable,
          IntentionEventRow
        > {
  $$IntentionEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IntentionsTable _intentionIdTable(_$CyaDatabase db) => db.intentions
      .createAlias('intention_events__intention_id__intentions__id');

  $$IntentionsTableProcessedTableManager get intentionId {
    final $_column = $_itemColumn<int>('intention_id')!;

    final manager = $$IntentionsTableTableManager(
      $_db,
      $_db.intentions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_intentionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntentionEventsTableFilterComposer
    extends Composer<_$CyaDatabase, $IntentionEventsTable> {
  $$IntentionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  $$IntentionsTableFilterComposer get intentionId {
    final $$IntentionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intentionId,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionsTableFilterComposer(
            $db: $db,
            $table: $db.intentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntentionEventsTableOrderingComposer
    extends Composer<_$CyaDatabase, $IntentionEventsTable> {
  $$IntentionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  $$IntentionsTableOrderingComposer get intentionId {
    final $$IntentionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intentionId,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionsTableOrderingComposer(
            $db: $db,
            $table: $db.intentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntentionEventsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $IntentionEventsTable> {
  $$IntentionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$IntentionsTableAnnotationComposer get intentionId {
    final $$IntentionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intentionId,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionsTableAnnotationComposer(
            $db: $db,
            $table: $db.intentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntentionEventsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $IntentionEventsTable,
          IntentionEventRow,
          $$IntentionEventsTableFilterComposer,
          $$IntentionEventsTableOrderingComposer,
          $$IntentionEventsTableAnnotationComposer,
          $$IntentionEventsTableCreateCompanionBuilder,
          $$IntentionEventsTableUpdateCompanionBuilder,
          (IntentionEventRow, $$IntentionEventsTableReferences),
          IntentionEventRow,
          PrefetchHooks Function({bool intentionId})
        > {
  $$IntentionEventsTableTableManager(
    _$CyaDatabase db,
    $IntentionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntentionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntentionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntentionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> intentionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
              }) => IntentionEventsCompanion(
                id: id,
                intentionId: intentionId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int intentionId,
                required String type,
                required DateTime occurredAt,
                Value<String?> metadata = const Value.absent(),
              }) => IntentionEventsCompanion.insert(
                id: id,
                intentionId: intentionId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntentionEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({intentionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (intentionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.intentionId,
                                referencedTable:
                                    $$IntentionEventsTableReferences
                                        ._intentionIdTable(db),
                                referencedColumn:
                                    $$IntentionEventsTableReferences
                                        ._intentionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IntentionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $IntentionEventsTable,
      IntentionEventRow,
      $$IntentionEventsTableFilterComposer,
      $$IntentionEventsTableOrderingComposer,
      $$IntentionEventsTableAnnotationComposer,
      $$IntentionEventsTableCreateCompanionBuilder,
      $$IntentionEventsTableUpdateCompanionBuilder,
      (IntentionEventRow, $$IntentionEventsTableReferences),
      IntentionEventRow,
      PrefetchHooks Function({bool intentionId})
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$CyaDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$CyaDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$CyaDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $PreferencesTable,
          PreferenceRow,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            PreferenceRow,
            BaseReferences<_$CyaDatabase, $PreferencesTable, PreferenceRow>,
          ),
          PreferenceRow,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$CyaDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $PreferencesTable,
      PreferenceRow,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        PreferenceRow,
        BaseReferences<_$CyaDatabase, $PreferencesTable, PreferenceRow>,
      ),
      PreferenceRow,
      PrefetchHooks Function()
    >;

class $CyaDatabaseManager {
  final _$CyaDatabase _db;
  $CyaDatabaseManager(this._db);
  $$IntentionsTableTableManager get intentions =>
      $$IntentionsTableTableManager(_db, _db.intentions);
  $$IntentionEventsTableTableManager get intentionEvents =>
      $$IntentionEventsTableTableManager(_db, _db.intentionEvents);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
