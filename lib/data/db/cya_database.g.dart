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
  static const VerificationMeta _sourcePackageMeta = const VerificationMeta(
    'sourcePackage',
  );
  @override
  late final GeneratedColumn<String> sourcePackage = GeneratedColumn<String>(
    'source_package',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    sourcePackage,
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
    if (data.containsKey('source_package')) {
      context.handle(
        _sourcePackageMeta,
        sourcePackage.isAcceptableOrUnknown(
          data['source_package']!,
          _sourcePackageMeta,
        ),
      );
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
      sourcePackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_package'],
      ),
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

  /// The Android package the promise was shared from, e.g.
  /// `com.whatsapp`. Nullable: an in-app capture has no source package, and a
  /// share whose sender cannot be attributed has none either.
  ///
  /// Stored so the UI can show the *real* launcher icon of the app a promise
  /// came from rather than an approximation — recognising WhatsApp's own icon
  /// in a list is instant in a way that a generic speech bubble never is.
  final String? sourcePackage;
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
    this.sourcePackage,
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
    if (!nullToAbsent || sourcePackage != null) {
      map['source_package'] = Variable<String>(sourcePackage);
    }
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
      sourcePackage: sourcePackage == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePackage),
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
      sourcePackage: serializer.fromJson<String?>(json['sourcePackage']),
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
      'sourcePackage': serializer.toJson<String?>(sourcePackage),
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
    Value<String?> sourcePackage = const Value.absent(),
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
    sourcePackage: sourcePackage.present
        ? sourcePackage.value
        : this.sourcePackage,
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
      sourcePackage: data.sourcePackage.present
          ? data.sourcePackage.value
          : this.sourcePackage,
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
          ..write('sourcePackage: $sourcePackage, ')
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
    sourcePackage,
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
          other.sourcePackage == this.sourcePackage &&
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
  final Value<String?> sourcePackage;
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
    this.sourcePackage = const Value.absent(),
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
    this.sourcePackage = const Value.absent(),
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
    Expression<String>? sourcePackage,
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
      if (sourcePackage != null) 'source_package': sourcePackage,
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
    Value<String?>? sourcePackage,
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
      sourcePackage: sourcePackage ?? this.sourcePackage,
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
    if (sourcePackage.present) {
      map['source_package'] = Variable<String>(sourcePackage.value);
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
          ..write('sourcePackage: $sourcePackage, ')
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

class $MemoriesTable extends Memories
    with TableInfo<$MemoriesTable, MemoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Cya!'),
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    source,
    capturedAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class MemoryRow extends DataClass implements Insertable<MemoryRow> {
  final String id;
  final String kind;
  final String source;
  final DateTime capturedAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const MemoryRow({
    required this.id,
    required this.kind,
    required this.source,
    required this.capturedAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['source'] = Variable<String>(source);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      id: Value(id),
      kind: Value(kind),
      source: Value(source),
      capturedAt: Value(capturedAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory MemoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      source: serializer.fromJson<String>(json['source']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'source': serializer.toJson<String>(source),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  MemoryRow copyWith({
    String? id,
    String? kind,
    String? source,
    DateTime? capturedAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => MemoryRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    capturedAt: capturedAt ?? this.capturedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  MemoryRow copyWithCompanion(MemoriesCompanion data) {
    return MemoryRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, source, capturedAt, updatedAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.capturedAt == this.capturedAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class MemoriesCompanion extends UpdateCompanion<MemoryRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> source;
  final Value<DateTime> capturedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const MemoriesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesCompanion.insert({
    required String id,
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime capturedAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       capturedAt = Value(capturedAt),
       updatedAt = Value(updatedAt);
  static Insertable<MemoryRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? source,
    Value<DateTime>? capturedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return MemoriesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryRevisionsTable extends MemoryRevisions
    with TableInfo<$MemoryRevisionsTable, MemoryRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memoryId,
    revision,
    body,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {memoryId, revision},
  ];
  @override
  MemoryRevisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryRevisionsTable createAlias(String alias) {
    return $MemoryRevisionsTable(attachedDatabase, alias);
  }
}

class MemoryRevisionRow extends DataClass
    implements Insertable<MemoryRevisionRow> {
  final String id;
  final String memoryId;
  final int revision;
  final String body;
  final DateTime createdAt;
  const MemoryRevisionRow({
    required this.id,
    required this.memoryId,
    required this.revision,
    required this.body,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['revision'] = Variable<int>(revision);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryRevisionsCompanion toCompanion(bool nullToAbsent) {
    return MemoryRevisionsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      revision: Value(revision),
      body: Value(body),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryRevisionRow(
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      revision: serializer.fromJson<int>(json['revision']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'revision': serializer.toJson<int>(revision),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryRevisionRow copyWith({
    String? id,
    String? memoryId,
    int? revision,
    String? body,
    DateTime? createdAt,
  }) => MemoryRevisionRow(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    revision: revision ?? this.revision,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryRevisionRow copyWithCompanion(MemoryRevisionsCompanion data) {
    return MemoryRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      revision: data.revision.present ? data.revision.value : this.revision,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRevisionRow(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('revision: $revision, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryId, revision, body, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryRevisionRow &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.revision == this.revision &&
          other.body == this.body &&
          other.createdAt == this.createdAt);
}

class MemoryRevisionsCompanion extends UpdateCompanion<MemoryRevisionRow> {
  final Value<String> id;
  final Value<String> memoryId;
  final Value<int> revision;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemoryRevisionsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.revision = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryRevisionsCompanion.insert({
    required String id,
    required String memoryId,
    required int revision,
    required String body,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memoryId = Value(memoryId),
       revision = Value(revision),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<MemoryRevisionRow> custom({
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<int>? revision,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (revision != null) 'revision': revision,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? memoryId,
    Value<int>? revision,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemoryRevisionsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      revision: revision ?? this.revision,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('revision: $revision, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryEventsTable extends MemoryEvents
    with TableInfo<$MemoryEventsTable, MemoryEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memories (id) ON DELETE CASCADE',
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
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_revisions (id) ON DELETE CASCADE',
    ),
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
    memoryId,
    type,
    occurredAt,
    revisionId,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
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
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
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
  MemoryEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $MemoryEventsTable createAlias(String alias) {
    return $MemoryEventsTable(attachedDatabase, alias);
  }
}

class MemoryEventRow extends DataClass implements Insertable<MemoryEventRow> {
  final int id;
  final String memoryId;
  final String type;
  final DateTime occurredAt;
  final String? revisionId;
  final String? metadata;
  const MemoryEventRow({
    required this.id,
    required this.memoryId,
    required this.type,
    required this.occurredAt,
    this.revisionId,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || revisionId != null) {
      map['revision_id'] = Variable<String>(revisionId);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  MemoryEventsCompanion toCompanion(bool nullToAbsent) {
    return MemoryEventsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      revisionId: revisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(revisionId),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory MemoryEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryEventRow(
      id: serializer.fromJson<int>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      revisionId: serializer.fromJson<String?>(json['revisionId']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'revisionId': serializer.toJson<String?>(revisionId),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  MemoryEventRow copyWith({
    int? id,
    String? memoryId,
    String? type,
    DateTime? occurredAt,
    Value<String?> revisionId = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
  }) => MemoryEventRow(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    revisionId: revisionId.present ? revisionId.value : this.revisionId,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  MemoryEventRow copyWithCompanion(MemoryEventsCompanion data) {
    return MemoryEventRow(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEventRow(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('revisionId: $revisionId, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, memoryId, type, occurredAt, revisionId, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryEventRow &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.revisionId == this.revisionId &&
          other.metadata == this.metadata);
}

class MemoryEventsCompanion extends UpdateCompanion<MemoryEventRow> {
  final Value<int> id;
  final Value<String> memoryId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String?> revisionId;
  final Value<String?> metadata;
  const MemoryEventsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  MemoryEventsCompanion.insert({
    this.id = const Value.absent(),
    required String memoryId,
    required String type,
    required DateTime occurredAt,
    this.revisionId = const Value.absent(),
    this.metadata = const Value.absent(),
  }) : memoryId = Value(memoryId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<MemoryEventRow> custom({
    Expression<int>? id,
    Expression<String>? memoryId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? revisionId,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (revisionId != null) 'revision_id': revisionId,
      if (metadata != null) 'metadata': metadata,
    });
  }

  MemoryEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? memoryId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String?>? revisionId,
    Value<String?>? metadata,
  }) {
    return MemoryEventsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      revisionId: revisionId ?? this.revisionId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEventsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('revisionId: $revisionId, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

class $MemoryJobsTable extends MemoryJobs
    with TableInfo<$MemoryJobsTable, MemoryJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retryAtMeta = const VerificationMeta(
    'retryAt',
  );
  @override
  late final GeneratedColumn<DateTime> retryAt = GeneratedColumn<DateTime>(
    'retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextSegmentMeta = const VerificationMeta(
    'nextSegment',
  );
  @override
  late final GeneratedColumn<int> nextSegment = GeneratedColumn<int>(
    'next_segment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revisionId,
    state,
    attempts,
    retryAt,
    lastError,
    nextSegment,
    modelVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('retry_at')) {
      context.handle(
        _retryAtMeta,
        retryAt.isAcceptableOrUnknown(data['retry_at']!, _retryAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_segment')) {
      context.handle(
        _nextSegmentMeta,
        nextSegment.isAcceptableOrUnknown(
          data['next_segment']!,
          _nextSegmentMeta,
        ),
      );
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {revisionId};
  @override
  MemoryJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryJobRow(
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      retryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextSegment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_segment'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
    );
  }

  @override
  $MemoryJobsTable createAlias(String alias) {
    return $MemoryJobsTable(attachedDatabase, alias);
  }
}

class MemoryJobRow extends DataClass implements Insertable<MemoryJobRow> {
  final String revisionId;
  final String state;
  final int attempts;
  final DateTime? retryAt;
  final String? lastError;
  final int nextSegment;
  final String? modelVersion;
  const MemoryJobRow({
    required this.revisionId,
    required this.state,
    required this.attempts,
    this.retryAt,
    this.lastError,
    required this.nextSegment,
    this.modelVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision_id'] = Variable<String>(revisionId);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || retryAt != null) {
      map['retry_at'] = Variable<DateTime>(retryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['next_segment'] = Variable<int>(nextSegment);
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    return map;
  }

  MemoryJobsCompanion toCompanion(bool nullToAbsent) {
    return MemoryJobsCompanion(
      revisionId: Value(revisionId),
      state: Value(state),
      attempts: Value(attempts),
      retryAt: retryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(retryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextSegment: Value(nextSegment),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
    );
  }

  factory MemoryJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryJobRow(
      revisionId: serializer.fromJson<String>(json['revisionId']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      retryAt: serializer.fromJson<DateTime?>(json['retryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextSegment: serializer.fromJson<int>(json['nextSegment']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revisionId': serializer.toJson<String>(revisionId),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'retryAt': serializer.toJson<DateTime?>(retryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'nextSegment': serializer.toJson<int>(nextSegment),
      'modelVersion': serializer.toJson<String?>(modelVersion),
    };
  }

  MemoryJobRow copyWith({
    String? revisionId,
    String? state,
    int? attempts,
    Value<DateTime?> retryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? nextSegment,
    Value<String?> modelVersion = const Value.absent(),
  }) => MemoryJobRow(
    revisionId: revisionId ?? this.revisionId,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    retryAt: retryAt.present ? retryAt.value : this.retryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextSegment: nextSegment ?? this.nextSegment,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
  );
  MemoryJobRow copyWithCompanion(MemoryJobsCompanion data) {
    return MemoryJobRow(
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      retryAt: data.retryAt.present ? data.retryAt.value : this.retryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextSegment: data.nextSegment.present
          ? data.nextSegment.value
          : this.nextSegment,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryJobRow(')
          ..write('revisionId: $revisionId, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('retryAt: $retryAt, ')
          ..write('lastError: $lastError, ')
          ..write('nextSegment: $nextSegment, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revisionId,
    state,
    attempts,
    retryAt,
    lastError,
    nextSegment,
    modelVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryJobRow &&
          other.revisionId == this.revisionId &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.retryAt == this.retryAt &&
          other.lastError == this.lastError &&
          other.nextSegment == this.nextSegment &&
          other.modelVersion == this.modelVersion);
}

class MemoryJobsCompanion extends UpdateCompanion<MemoryJobRow> {
  final Value<String> revisionId;
  final Value<String> state;
  final Value<int> attempts;
  final Value<DateTime?> retryAt;
  final Value<String?> lastError;
  final Value<int> nextSegment;
  final Value<String?> modelVersion;
  final Value<int> rowid;
  const MemoryJobsCompanion({
    this.revisionId = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.retryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextSegment = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryJobsCompanion.insert({
    required String revisionId,
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.retryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextSegment = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : revisionId = Value(revisionId);
  static Insertable<MemoryJobRow> custom({
    Expression<String>? revisionId,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<DateTime>? retryAt,
    Expression<String>? lastError,
    Expression<int>? nextSegment,
    Expression<String>? modelVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revisionId != null) 'revision_id': revisionId,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (retryAt != null) 'retry_at': retryAt,
      if (lastError != null) 'last_error': lastError,
      if (nextSegment != null) 'next_segment': nextSegment,
      if (modelVersion != null) 'model_version': modelVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryJobsCompanion copyWith({
    Value<String>? revisionId,
    Value<String>? state,
    Value<int>? attempts,
    Value<DateTime?>? retryAt,
    Value<String?>? lastError,
    Value<int>? nextSegment,
    Value<String?>? modelVersion,
    Value<int>? rowid,
  }) {
    return MemoryJobsCompanion(
      revisionId: revisionId ?? this.revisionId,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      retryAt: retryAt ?? this.retryAt,
      lastError: lastError ?? this.lastError,
      nextSegment: nextSegment ?? this.nextSegment,
      modelVersion: modelVersion ?? this.modelVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (retryAt.present) {
      map['retry_at'] = Variable<DateTime>(retryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextSegment.present) {
      map['next_segment'] = Variable<int>(nextSegment.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryJobsCompanion(')
          ..write('revisionId: $revisionId, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('retryAt: $retryAt, ')
          ..write('lastError: $lastError, ')
          ..write('nextSegment: $nextSegment, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryVectorsTable extends MemoryVectors
    with TableInfo<$MemoryVectorsTable, MemoryVectorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryVectorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _segmentMeta = const VerificationMeta(
    'segment',
  );
  @override
  late final GeneratedColumn<int> segment = GeneratedColumn<int>(
    'segment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<int> dimensions = GeneratedColumn<int>(
    'dimensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revisionId,
    segment,
    modelVersion,
    dimensions,
    vector,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_vectors';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryVectorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('segment')) {
      context.handle(
        _segmentMeta,
        segment.isAcceptableOrUnknown(data['segment']!, _segmentMeta),
      );
    } else if (isInserting) {
      context.missing(_segmentMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionsMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {revisionId, segment};
  @override
  MemoryVectorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryVectorRow(
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      )!,
      segment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimensions'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
    );
  }

  @override
  $MemoryVectorsTable createAlias(String alias) {
    return $MemoryVectorsTable(attachedDatabase, alias);
  }
}

class MemoryVectorRow extends DataClass implements Insertable<MemoryVectorRow> {
  final String revisionId;
  final int segment;
  final String modelVersion;
  final int dimensions;
  final Uint8List vector;
  const MemoryVectorRow({
    required this.revisionId,
    required this.segment,
    required this.modelVersion,
    required this.dimensions,
    required this.vector,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision_id'] = Variable<String>(revisionId);
    map['segment'] = Variable<int>(segment);
    map['model_version'] = Variable<String>(modelVersion);
    map['dimensions'] = Variable<int>(dimensions);
    map['vector'] = Variable<Uint8List>(vector);
    return map;
  }

  MemoryVectorsCompanion toCompanion(bool nullToAbsent) {
    return MemoryVectorsCompanion(
      revisionId: Value(revisionId),
      segment: Value(segment),
      modelVersion: Value(modelVersion),
      dimensions: Value(dimensions),
      vector: Value(vector),
    );
  }

  factory MemoryVectorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryVectorRow(
      revisionId: serializer.fromJson<String>(json['revisionId']),
      segment: serializer.fromJson<int>(json['segment']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      dimensions: serializer.fromJson<int>(json['dimensions']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revisionId': serializer.toJson<String>(revisionId),
      'segment': serializer.toJson<int>(segment),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'dimensions': serializer.toJson<int>(dimensions),
      'vector': serializer.toJson<Uint8List>(vector),
    };
  }

  MemoryVectorRow copyWith({
    String? revisionId,
    int? segment,
    String? modelVersion,
    int? dimensions,
    Uint8List? vector,
  }) => MemoryVectorRow(
    revisionId: revisionId ?? this.revisionId,
    segment: segment ?? this.segment,
    modelVersion: modelVersion ?? this.modelVersion,
    dimensions: dimensions ?? this.dimensions,
    vector: vector ?? this.vector,
  );
  MemoryVectorRow copyWithCompanion(MemoryVectorsCompanion data) {
    return MemoryVectorRow(
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      segment: data.segment.present ? data.segment.value : this.segment,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      vector: data.vector.present ? data.vector.value : this.vector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryVectorRow(')
          ..write('revisionId: $revisionId, ')
          ..write('segment: $segment, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    revisionId,
    segment,
    modelVersion,
    dimensions,
    $driftBlobEquality.hash(vector),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryVectorRow &&
          other.revisionId == this.revisionId &&
          other.segment == this.segment &&
          other.modelVersion == this.modelVersion &&
          other.dimensions == this.dimensions &&
          $driftBlobEquality.equals(other.vector, this.vector));
}

class MemoryVectorsCompanion extends UpdateCompanion<MemoryVectorRow> {
  final Value<String> revisionId;
  final Value<int> segment;
  final Value<String> modelVersion;
  final Value<int> dimensions;
  final Value<Uint8List> vector;
  final Value<int> rowid;
  const MemoryVectorsCompanion({
    this.revisionId = const Value.absent(),
    this.segment = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.vector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryVectorsCompanion.insert({
    required String revisionId,
    required int segment,
    required String modelVersion,
    required int dimensions,
    required Uint8List vector,
    this.rowid = const Value.absent(),
  }) : revisionId = Value(revisionId),
       segment = Value(segment),
       modelVersion = Value(modelVersion),
       dimensions = Value(dimensions),
       vector = Value(vector);
  static Insertable<MemoryVectorRow> custom({
    Expression<String>? revisionId,
    Expression<int>? segment,
    Expression<String>? modelVersion,
    Expression<int>? dimensions,
    Expression<Uint8List>? vector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revisionId != null) 'revision_id': revisionId,
      if (segment != null) 'segment': segment,
      if (modelVersion != null) 'model_version': modelVersion,
      if (dimensions != null) 'dimensions': dimensions,
      if (vector != null) 'vector': vector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryVectorsCompanion copyWith({
    Value<String>? revisionId,
    Value<int>? segment,
    Value<String>? modelVersion,
    Value<int>? dimensions,
    Value<Uint8List>? vector,
    Value<int>? rowid,
  }) {
    return MemoryVectorsCompanion(
      revisionId: revisionId ?? this.revisionId,
      segment: segment ?? this.segment,
      modelVersion: modelVersion ?? this.modelVersion,
      dimensions: dimensions ?? this.dimensions,
      vector: vector ?? this.vector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (segment.present) {
      map['segment'] = Variable<int>(segment.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<int>(dimensions.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryVectorsCompanion(')
          ..write('revisionId: $revisionId, ')
          ..write('segment: $segment, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryLinksTable extends MemoryLinks
    with TableInfo<$MemoryLinksTable, MemoryLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromRevisionMeta = const VerificationMeta(
    'fromRevision',
  );
  @override
  late final GeneratedColumn<String> fromRevision = GeneratedColumn<String>(
    'from_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toRevisionMeta = const VerificationMeta(
    'toRevision',
  );
  @override
  late final GeneratedColumn<String> toRevision = GeneratedColumn<String>(
    'to_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromRevision,
    toRevision,
    kind,
    provenance,
    state,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryLinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_revision')) {
      context.handle(
        _fromRevisionMeta,
        fromRevision.isAcceptableOrUnknown(
          data['from_revision']!,
          _fromRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromRevisionMeta);
    }
    if (data.containsKey('to_revision')) {
      context.handle(
        _toRevisionMeta,
        toRevision.isAcceptableOrUnknown(data['to_revision']!, _toRevisionMeta),
      );
    } else if (isInserting) {
      context.missing(_toRevisionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_provenanceMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fromRevision, toRevision, kind},
  ];
  @override
  MemoryLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryLinkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_revision'],
      )!,
      toRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_revision'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryLinksTable createAlias(String alias) {
    return $MemoryLinksTable(attachedDatabase, alias);
  }
}

class MemoryLinkRow extends DataClass implements Insertable<MemoryLinkRow> {
  final String id;
  final String fromRevision;
  final String toRevision;
  final String kind;
  final String provenance;
  final String state;
  final DateTime createdAt;
  const MemoryLinkRow({
    required this.id,
    required this.fromRevision,
    required this.toRevision,
    required this.kind,
    required this.provenance,
    required this.state,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_revision'] = Variable<String>(fromRevision);
    map['to_revision'] = Variable<String>(toRevision);
    map['kind'] = Variable<String>(kind);
    map['provenance'] = Variable<String>(provenance);
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryLinksCompanion toCompanion(bool nullToAbsent) {
    return MemoryLinksCompanion(
      id: Value(id),
      fromRevision: Value(fromRevision),
      toRevision: Value(toRevision),
      kind: Value(kind),
      provenance: Value(provenance),
      state: Value(state),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryLinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryLinkRow(
      id: serializer.fromJson<String>(json['id']),
      fromRevision: serializer.fromJson<String>(json['fromRevision']),
      toRevision: serializer.fromJson<String>(json['toRevision']),
      kind: serializer.fromJson<String>(json['kind']),
      provenance: serializer.fromJson<String>(json['provenance']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromRevision': serializer.toJson<String>(fromRevision),
      'toRevision': serializer.toJson<String>(toRevision),
      'kind': serializer.toJson<String>(kind),
      'provenance': serializer.toJson<String>(provenance),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryLinkRow copyWith({
    String? id,
    String? fromRevision,
    String? toRevision,
    String? kind,
    String? provenance,
    String? state,
    DateTime? createdAt,
  }) => MemoryLinkRow(
    id: id ?? this.id,
    fromRevision: fromRevision ?? this.fromRevision,
    toRevision: toRevision ?? this.toRevision,
    kind: kind ?? this.kind,
    provenance: provenance ?? this.provenance,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryLinkRow copyWithCompanion(MemoryLinksCompanion data) {
    return MemoryLinkRow(
      id: data.id.present ? data.id.value : this.id,
      fromRevision: data.fromRevision.present
          ? data.fromRevision.value
          : this.fromRevision,
      toRevision: data.toRevision.present
          ? data.toRevision.value
          : this.toRevision,
      kind: data.kind.present ? data.kind.value : this.kind,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryLinkRow(')
          ..write('id: $id, ')
          ..write('fromRevision: $fromRevision, ')
          ..write('toRevision: $toRevision, ')
          ..write('kind: $kind, ')
          ..write('provenance: $provenance, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromRevision,
    toRevision,
    kind,
    provenance,
    state,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryLinkRow &&
          other.id == this.id &&
          other.fromRevision == this.fromRevision &&
          other.toRevision == this.toRevision &&
          other.kind == this.kind &&
          other.provenance == this.provenance &&
          other.state == this.state &&
          other.createdAt == this.createdAt);
}

class MemoryLinksCompanion extends UpdateCompanion<MemoryLinkRow> {
  final Value<String> id;
  final Value<String> fromRevision;
  final Value<String> toRevision;
  final Value<String> kind;
  final Value<String> provenance;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemoryLinksCompanion({
    this.id = const Value.absent(),
    this.fromRevision = const Value.absent(),
    this.toRevision = const Value.absent(),
    this.kind = const Value.absent(),
    this.provenance = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryLinksCompanion.insert({
    required String id,
    required String fromRevision,
    required String toRevision,
    required String kind,
    required String provenance,
    required String state,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromRevision = Value(fromRevision),
       toRevision = Value(toRevision),
       kind = Value(kind),
       provenance = Value(provenance),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<MemoryLinkRow> custom({
    Expression<String>? id,
    Expression<String>? fromRevision,
    Expression<String>? toRevision,
    Expression<String>? kind,
    Expression<String>? provenance,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromRevision != null) 'from_revision': fromRevision,
      if (toRevision != null) 'to_revision': toRevision,
      if (kind != null) 'kind': kind,
      if (provenance != null) 'provenance': provenance,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? fromRevision,
    Value<String>? toRevision,
    Value<String>? kind,
    Value<String>? provenance,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemoryLinksCompanion(
      id: id ?? this.id,
      fromRevision: fromRevision ?? this.fromRevision,
      toRevision: toRevision ?? this.toRevision,
      kind: kind ?? this.kind,
      provenance: provenance ?? this.provenance,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromRevision.present) {
      map['from_revision'] = Variable<String>(fromRevision.value);
    }
    if (toRevision.present) {
      map['to_revision'] = Variable<String>(toRevision.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryLinksCompanion(')
          ..write('id: $id, ')
          ..write('fromRevision: $fromRevision, ')
          ..write('toRevision: $toRevision, ')
          ..write('kind: $kind, ')
          ..write('provenance: $provenance, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryAttachmentsTable extends MemoryAttachments
    with TableInfo<$MemoryAttachmentsTable, MemoryAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMillisMeta = const VerificationMeta(
    'durationMillis',
  );
  @override
  late final GeneratedColumn<int> durationMillis = GeneratedColumn<int>(
    'duration_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memoryId,
    fileName,
    sha256,
    byteLength,
    durationMillis,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('duration_millis')) {
      context.handle(
        _durationMillisMeta,
        durationMillis.isAcceptableOrUnknown(
          data['duration_millis']!,
          _durationMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMillisMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {memoryId},
  ];
  @override
  MemoryAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryAttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      durationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_millis'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $MemoryAttachmentsTable createAlias(String alias) {
    return $MemoryAttachmentsTable(attachedDatabase, alias);
  }
}

class MemoryAttachmentRow extends DataClass
    implements Insertable<MemoryAttachmentRow> {
  final String id;
  final String memoryId;
  final String fileName;
  final String sha256;
  final int byteLength;
  final int durationMillis;
  final DateTime capturedAt;
  const MemoryAttachmentRow({
    required this.id,
    required this.memoryId,
    required this.fileName,
    required this.sha256,
    required this.byteLength,
    required this.durationMillis,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['file_name'] = Variable<String>(fileName);
    map['sha256'] = Variable<String>(sha256);
    map['byte_length'] = Variable<int>(byteLength);
    map['duration_millis'] = Variable<int>(durationMillis);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  MemoryAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return MemoryAttachmentsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      fileName: Value(fileName),
      sha256: Value(sha256),
      byteLength: Value(byteLength),
      durationMillis: Value(durationMillis),
      capturedAt: Value(capturedAt),
    );
  }

  factory MemoryAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryAttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      sha256: serializer.fromJson<String>(json['sha256']),
      byteLength: serializer.fromJson<int>(json['byteLength']),
      durationMillis: serializer.fromJson<int>(json['durationMillis']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'fileName': serializer.toJson<String>(fileName),
      'sha256': serializer.toJson<String>(sha256),
      'byteLength': serializer.toJson<int>(byteLength),
      'durationMillis': serializer.toJson<int>(durationMillis),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  MemoryAttachmentRow copyWith({
    String? id,
    String? memoryId,
    String? fileName,
    String? sha256,
    int? byteLength,
    int? durationMillis,
    DateTime? capturedAt,
  }) => MemoryAttachmentRow(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    fileName: fileName ?? this.fileName,
    sha256: sha256 ?? this.sha256,
    byteLength: byteLength ?? this.byteLength,
    durationMillis: durationMillis ?? this.durationMillis,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  MemoryAttachmentRow copyWithCompanion(MemoryAttachmentsCompanion data) {
    return MemoryAttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      durationMillis: data.durationMillis.present
          ? data.durationMillis.value
          : this.durationMillis,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryAttachmentRow(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('fileName: $fileName, ')
          ..write('sha256: $sha256, ')
          ..write('byteLength: $byteLength, ')
          ..write('durationMillis: $durationMillis, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memoryId,
    fileName,
    sha256,
    byteLength,
    durationMillis,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryAttachmentRow &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.fileName == this.fileName &&
          other.sha256 == this.sha256 &&
          other.byteLength == this.byteLength &&
          other.durationMillis == this.durationMillis &&
          other.capturedAt == this.capturedAt);
}

class MemoryAttachmentsCompanion extends UpdateCompanion<MemoryAttachmentRow> {
  final Value<String> id;
  final Value<String> memoryId;
  final Value<String> fileName;
  final Value<String> sha256;
  final Value<int> byteLength;
  final Value<int> durationMillis;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const MemoryAttachmentsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.durationMillis = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryAttachmentsCompanion.insert({
    required String id,
    required String memoryId,
    required String fileName,
    required String sha256,
    required int byteLength,
    required int durationMillis,
    required DateTime capturedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memoryId = Value(memoryId),
       fileName = Value(fileName),
       sha256 = Value(sha256),
       byteLength = Value(byteLength),
       durationMillis = Value(durationMillis),
       capturedAt = Value(capturedAt);
  static Insertable<MemoryAttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<String>? fileName,
    Expression<String>? sha256,
    Expression<int>? byteLength,
    Expression<int>? durationMillis,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (fileName != null) 'file_name': fileName,
      if (sha256 != null) 'sha256': sha256,
      if (byteLength != null) 'byte_length': byteLength,
      if (durationMillis != null) 'duration_millis': durationMillis,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? memoryId,
    Value<String>? fileName,
    Value<String>? sha256,
    Value<int>? byteLength,
    Value<int>? durationMillis,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return MemoryAttachmentsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      fileName: fileName ?? this.fileName,
      sha256: sha256 ?? this.sha256,
      byteLength: byteLength ?? this.byteLength,
      durationMillis: durationMillis ?? this.durationMillis,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (durationMillis.present) {
      map['duration_millis'] = Variable<int>(durationMillis.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('fileName: $fileName, ')
          ..write('sha256: $sha256, ')
          ..write('byteLength: $byteLength, ')
          ..write('durationMillis: $durationMillis, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentCleanupTable extends AttachmentCleanup
    with TableInfo<$AttachmentCleanupTable, AttachmentCleanupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentCleanupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fileName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_cleanup';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentCleanupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileName};
  @override
  AttachmentCleanupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentCleanupRow(
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentCleanupTable createAlias(String alias) {
    return $AttachmentCleanupTable(attachedDatabase, alias);
  }
}

class AttachmentCleanupRow extends DataClass
    implements Insertable<AttachmentCleanupRow> {
  final String fileName;
  final DateTime createdAt;
  const AttachmentCleanupRow({required this.fileName, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentCleanupCompanion toCompanion(bool nullToAbsent) {
    return AttachmentCleanupCompanion(
      fileName: Value(fileName),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentCleanupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentCleanupRow(
      fileName: serializer.fromJson<String>(json['fileName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileName': serializer.toJson<String>(fileName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentCleanupRow copyWith({String? fileName, DateTime? createdAt}) =>
      AttachmentCleanupRow(
        fileName: fileName ?? this.fileName,
        createdAt: createdAt ?? this.createdAt,
      );
  AttachmentCleanupRow copyWithCompanion(AttachmentCleanupCompanion data) {
    return AttachmentCleanupRow(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentCleanupRow(')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentCleanupRow &&
          other.fileName == this.fileName &&
          other.createdAt == this.createdAt);
}

class AttachmentCleanupCompanion extends UpdateCompanion<AttachmentCleanupRow> {
  final Value<String> fileName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentCleanupCompanion({
    this.fileName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentCleanupCompanion.insert({
    required String fileName,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       createdAt = Value(createdAt);
  static Insertable<AttachmentCleanupRow> custom({
    Expression<String>? fileName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileName != null) 'file_name': fileName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentCleanupCompanion copyWith({
    Value<String>? fileName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentCleanupCompanion(
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentCleanupCompanion(')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, priority, startedAt, endedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final String id;
  final String priority;
  final DateTime startedAt;
  final DateTime? endedAt;
  const FocusSessionRow({
    required this.id,
    required this.priority,
    required this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['priority'] = Variable<String>(priority);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      priority: Value(priority),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory FocusSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      id: serializer.fromJson<String>(json['id']),
      priority: serializer.fromJson<String>(json['priority']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'priority': serializer.toJson<String>(priority),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  FocusSessionRow copyWith({
    String? id,
    String? priority,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => FocusSessionRow(
    id: id ?? this.id,
    priority: priority ?? this.priority,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
      id: data.id.present ? data.id.value : this.id,
      priority: data.priority.present ? data.priority.value : this.priority,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionRow(')
          ..write('id: $id, ')
          ..write('priority: $priority, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, priority, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionRow &&
          other.id == this.id &&
          other.priority == this.priority &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<String> id;
  final Value<String> priority;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.priority = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    required String id,
    required String priority,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       priority = Value(priority),
       startedAt = Value(startedAt);
  static Insertable<FocusSessionRow> custom({
    Expression<String>? id,
    Expression<String>? priority,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (priority != null) 'priority': priority,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? priority,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      priority: priority ?? this.priority,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('priority: $priority, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusEventsTable extends FocusEvents
    with TableInfo<$FocusEventsTable, FocusEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES focus_sessions (id) ON DELETE CASCADE',
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
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, type, occurredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $FocusEventsTable createAlias(String alias) {
    return $FocusEventsTable(attachedDatabase, alias);
  }
}

class FocusEventRow extends DataClass implements Insertable<FocusEventRow> {
  final int id;
  final String sessionId;
  final String type;
  final DateTime occurredAt;
  const FocusEventRow({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  FocusEventsCompanion toCompanion(bool nullToAbsent) {
    return FocusEventsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      occurredAt: Value(occurredAt),
    );
  }

  factory FocusEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusEventRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  FocusEventRow copyWith({
    int? id,
    String? sessionId,
    String? type,
    DateTime? occurredAt,
  }) => FocusEventRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  FocusEventRow copyWithCompanion(FocusEventsCompanion data) {
    return FocusEventRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusEventRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, type, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusEventRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt);
}

class FocusEventsCompanion extends UpdateCompanion<FocusEventRow> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  const FocusEventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  FocusEventsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String type,
    required DateTime occurredAt,
  }) : sessionId = Value(sessionId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<FocusEventRow> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  FocusEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
  }) {
    return FocusEventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $MemoryCollectionsTable extends MemoryCollections
    with TableInfo<$MemoryCollectionsTable, MemoryCollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryCollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_collections (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, kind, parentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryCollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryCollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryCollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryCollectionsTable createAlias(String alias) {
    return $MemoryCollectionsTable(attachedDatabase, alias);
  }
}

class MemoryCollectionRow extends DataClass
    implements Insertable<MemoryCollectionRow> {
  final String id;
  final String title;
  final String kind;
  final String? parentId;
  final DateTime createdAt;
  const MemoryCollectionRow({
    required this.id,
    required this.title,
    required this.kind,
    this.parentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryCollectionsCompanion toCompanion(bool nullToAbsent) {
    return MemoryCollectionsCompanion(
      id: Value(id),
      title: Value(title),
      kind: Value(kind),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryCollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryCollectionRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'parentId': serializer.toJson<String?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryCollectionRow copyWith({
    String? id,
    String? title,
    String? kind,
    Value<String?> parentId = const Value.absent(),
    DateTime? createdAt,
  }) => MemoryCollectionRow(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryCollectionRow copyWithCompanion(MemoryCollectionsCompanion data) {
    return MemoryCollectionRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryCollectionRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, kind, parentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryCollectionRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt);
}

class MemoryCollectionsCompanion extends UpdateCompanion<MemoryCollectionRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<String?> parentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemoryCollectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryCollectionsCompanion.insert({
    required String id,
    required String title,
    required String kind,
    this.parentId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<MemoryCollectionRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<String>? parentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryCollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? kind,
    Value<String?>? parentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemoryCollectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryCollectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionEventsTable extends CollectionEvents
    with TableInfo<$CollectionEventsTable, CollectionEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_collections (id) ON DELETE CASCADE',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    type,
    occurredAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
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
    } else if (isInserting) {
      context.missing(_metadataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
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
      )!,
    );
  }

  @override
  $CollectionEventsTable createAlias(String alias) {
    return $CollectionEventsTable(attachedDatabase, alias);
  }
}

class CollectionEventRow extends DataClass
    implements Insertable<CollectionEventRow> {
  final int id;
  final String collectionId;
  final String type;
  final DateTime occurredAt;
  final String metadata;
  const CollectionEventRow({
    required this.id,
    required this.collectionId,
    required this.type,
    required this.occurredAt,
    required this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  CollectionEventsCompanion toCompanion(bool nullToAbsent) {
    return CollectionEventsCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      metadata: Value(metadata),
    );
  }

  factory CollectionEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionEventRow(
      id: serializer.fromJson<int>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  CollectionEventRow copyWith({
    int? id,
    String? collectionId,
    String? type,
    DateTime? occurredAt,
    String? metadata,
  }) => CollectionEventRow(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    metadata: metadata ?? this.metadata,
  );
  CollectionEventRow copyWithCompanion(CollectionEventsCompanion data) {
    return CollectionEventRow(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionEventRow(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collectionId, type, occurredAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionEventRow &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.metadata == this.metadata);
}

class CollectionEventsCompanion extends UpdateCompanion<CollectionEventRow> {
  final Value<int> id;
  final Value<String> collectionId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String> metadata;
  const CollectionEventsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  CollectionEventsCompanion.insert({
    this.id = const Value.absent(),
    required String collectionId,
    required String type,
    required DateTime occurredAt,
    required String metadata,
  }) : collectionId = Value(collectionId),
       type = Value(type),
       occurredAt = Value(occurredAt),
       metadata = Value(metadata);
  static Insertable<CollectionEventRow> custom({
    Expression<int>? id,
    Expression<String>? collectionId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadata != null) 'metadata': metadata,
    });
  }

  CollectionEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? collectionId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String>? metadata,
  }) {
    return CollectionEventsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
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
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
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
    return (StringBuffer('CollectionEventsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

class $MemoryAssignmentsTable extends MemoryAssignments
    with TableInfo<$MemoryAssignmentsTable, MemoryAssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _intentionIdMeta = const VerificationMeta(
    'intentionId',
  );
  @override
  late final GeneratedColumn<int> intentionId = GeneratedColumn<int>(
    'intention_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES intentions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_collections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    revisionId,
    intentionId,
    collectionId,
    kind,
    context,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryAssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('intention_id')) {
      context.handle(
        _intentionIdMeta,
        intentionId.isAcceptableOrUnknown(
          data['intention_id']!,
          _intentionIdMeta,
        ),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {revisionId, intentionId},
    {revisionId, collectionId},
  ];
  @override
  MemoryAssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryAssignmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      )!,
      intentionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intention_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryAssignmentsTable createAlias(String alias) {
    return $MemoryAssignmentsTable(attachedDatabase, alias);
  }
}

class MemoryAssignmentRow extends DataClass
    implements Insertable<MemoryAssignmentRow> {
  final String id;
  final String revisionId;
  final int? intentionId;
  final String? collectionId;
  final String kind;
  final String context;
  final DateTime createdAt;
  const MemoryAssignmentRow({
    required this.id,
    required this.revisionId,
    this.intentionId,
    this.collectionId,
    required this.kind,
    required this.context,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['revision_id'] = Variable<String>(revisionId);
    if (!nullToAbsent || intentionId != null) {
      map['intention_id'] = Variable<int>(intentionId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    map['kind'] = Variable<String>(kind);
    map['context'] = Variable<String>(context);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return MemoryAssignmentsCompanion(
      id: Value(id),
      revisionId: Value(revisionId),
      intentionId: intentionId == null && nullToAbsent
          ? const Value.absent()
          : Value(intentionId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      kind: Value(kind),
      context: Value(context),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryAssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryAssignmentRow(
      id: serializer.fromJson<String>(json['id']),
      revisionId: serializer.fromJson<String>(json['revisionId']),
      intentionId: serializer.fromJson<int?>(json['intentionId']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      kind: serializer.fromJson<String>(json['kind']),
      context: serializer.fromJson<String>(json['context']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'revisionId': serializer.toJson<String>(revisionId),
      'intentionId': serializer.toJson<int?>(intentionId),
      'collectionId': serializer.toJson<String?>(collectionId),
      'kind': serializer.toJson<String>(kind),
      'context': serializer.toJson<String>(context),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryAssignmentRow copyWith({
    String? id,
    String? revisionId,
    Value<int?> intentionId = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
    String? kind,
    String? context,
    DateTime? createdAt,
  }) => MemoryAssignmentRow(
    id: id ?? this.id,
    revisionId: revisionId ?? this.revisionId,
    intentionId: intentionId.present ? intentionId.value : this.intentionId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    kind: kind ?? this.kind,
    context: context ?? this.context,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryAssignmentRow copyWithCompanion(MemoryAssignmentsCompanion data) {
    return MemoryAssignmentRow(
      id: data.id.present ? data.id.value : this.id,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      intentionId: data.intentionId.present
          ? data.intentionId.value
          : this.intentionId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      kind: data.kind.present ? data.kind.value : this.kind,
      context: data.context.present ? data.context.value : this.context,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryAssignmentRow(')
          ..write('id: $id, ')
          ..write('revisionId: $revisionId, ')
          ..write('intentionId: $intentionId, ')
          ..write('collectionId: $collectionId, ')
          ..write('kind: $kind, ')
          ..write('context: $context, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    revisionId,
    intentionId,
    collectionId,
    kind,
    context,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryAssignmentRow &&
          other.id == this.id &&
          other.revisionId == this.revisionId &&
          other.intentionId == this.intentionId &&
          other.collectionId == this.collectionId &&
          other.kind == this.kind &&
          other.context == this.context &&
          other.createdAt == this.createdAt);
}

class MemoryAssignmentsCompanion extends UpdateCompanion<MemoryAssignmentRow> {
  final Value<String> id;
  final Value<String> revisionId;
  final Value<int?> intentionId;
  final Value<String?> collectionId;
  final Value<String> kind;
  final Value<String> context;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemoryAssignmentsCompanion({
    this.id = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.intentionId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.kind = const Value.absent(),
    this.context = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryAssignmentsCompanion.insert({
    required String id,
    required String revisionId,
    this.intentionId = const Value.absent(),
    this.collectionId = const Value.absent(),
    required String kind,
    required String context,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       revisionId = Value(revisionId),
       kind = Value(kind),
       context = Value(context),
       createdAt = Value(createdAt);
  static Insertable<MemoryAssignmentRow> custom({
    Expression<String>? id,
    Expression<String>? revisionId,
    Expression<int>? intentionId,
    Expression<String>? collectionId,
    Expression<String>? kind,
    Expression<String>? context,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revisionId != null) 'revision_id': revisionId,
      if (intentionId != null) 'intention_id': intentionId,
      if (collectionId != null) 'collection_id': collectionId,
      if (kind != null) 'kind': kind,
      if (context != null) 'context': context,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryAssignmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? revisionId,
    Value<int?>? intentionId,
    Value<String?>? collectionId,
    Value<String>? kind,
    Value<String>? context,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemoryAssignmentsCompanion(
      id: id ?? this.id,
      revisionId: revisionId ?? this.revisionId,
      intentionId: intentionId ?? this.intentionId,
      collectionId: collectionId ?? this.collectionId,
      kind: kind ?? this.kind,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (intentionId.present) {
      map['intention_id'] = Variable<int>(intentionId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('revisionId: $revisionId, ')
          ..write('intentionId: $intentionId, ')
          ..write('collectionId: $collectionId, ')
          ..write('kind: $kind, ')
          ..write('context: $context, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentRevisionMeta = const VerificationMeta(
    'currentRevision',
  );
  @override
  late final GeneratedColumn<int> currentRevision = GeneratedColumn<int>(
    'current_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentRevision,
    position,
    paused,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('current_revision')) {
      context.handle(
        _currentRevisionMeta,
        currentRevision.isAcceptableOrUnknown(
          data['current_revision']!,
          _currentRevisionMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currentRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_revision'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paused'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final int currentRevision;
  final int position;
  final bool paused;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const RoutineRow({
    required this.id,
    required this.currentRevision,
    required this.position,
    required this.paused,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['current_revision'] = Variable<int>(currentRevision);
    map['position'] = Variable<int>(position);
    map['paused'] = Variable<bool>(paused);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      currentRevision: Value(currentRevision),
      position: Value(position),
      paused: Value(paused),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      currentRevision: serializer.fromJson<int>(json['currentRevision']),
      position: serializer.fromJson<int>(json['position']),
      paused: serializer.fromJson<bool>(json['paused']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currentRevision': serializer.toJson<int>(currentRevision),
      'position': serializer.toJson<int>(position),
      'paused': serializer.toJson<bool>(paused),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RoutineRow copyWith({
    String? id,
    int? currentRevision,
    int? position,
    bool? paused,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RoutineRow(
    id: id ?? this.id,
    currentRevision: currentRevision ?? this.currentRevision,
    position: position ?? this.position,
    paused: paused ?? this.paused,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      currentRevision: data.currentRevision.present
          ? data.currentRevision.value
          : this.currentRevision,
      position: data.position.present ? data.position.value : this.position,
      paused: data.paused.present ? data.paused.value : this.paused,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('currentRevision: $currentRevision, ')
          ..write('position: $position, ')
          ..write('paused: $paused, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentRevision,
    position,
    paused,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.currentRevision == this.currentRevision &&
          other.position == this.position &&
          other.paused == this.paused &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<int> currentRevision;
  final Value<int> position;
  final Value<bool> paused;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.currentRevision = const Value.absent(),
    this.position = const Value.absent(),
    this.paused = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    this.currentRevision = const Value.absent(),
    this.position = const Value.absent(),
    this.paused = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<int>? currentRevision,
    Expression<int>? position,
    Expression<bool>? paused,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentRevision != null) 'current_revision': currentRevision,
      if (position != null) 'position': position,
      if (paused != null) 'paused': paused,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<int>? currentRevision,
    Value<int>? position,
    Value<bool>? paused,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      currentRevision: currentRevision ?? this.currentRevision,
      position: position ?? this.position,
      paused: paused ?? this.paused,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currentRevision.present) {
      map['current_revision'] = Variable<int>(currentRevision.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('currentRevision: $currentRevision, ')
          ..write('position: $position, ')
          ..write('paused: $paused, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineRevisionsTable extends RoutineRevisions
    with TableInfo<$RoutineRevisionsTable, RoutineRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredStartMeta = const VerificationMeta(
    'preferredStart',
  );
  @override
  late final GeneratedColumn<int> preferredStart = GeneratedColumn<int>(
    'preferred_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredEndMeta = const VerificationMeta(
    'preferredEnd',
  );
  @override
  late final GeneratedColumn<int> preferredEnd = GeneratedColumn<int>(
    'preferred_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _fallbackMeta = const VerificationMeta(
    'fallback',
  );
  @override
  late final GeneratedColumn<String> fallback = GeneratedColumn<String>(
    'fallback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    revision,
    title,
    weekdays,
    preferredStart,
    preferredEnd,
    steps,
    fallback,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('preferred_start')) {
      context.handle(
        _preferredStartMeta,
        preferredStart.isAcceptableOrUnknown(
          data['preferred_start']!,
          _preferredStartMeta,
        ),
      );
    }
    if (data.containsKey('preferred_end')) {
      context.handle(
        _preferredEndMeta,
        preferredEnd.isAcceptableOrUnknown(
          data['preferred_end']!,
          _preferredEndMeta,
        ),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('fallback')) {
      context.handle(
        _fallbackMeta,
        fallback.isAcceptableOrUnknown(data['fallback']!, _fallbackMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routineId, revision},
  ];
  @override
  RoutineRevisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      ),
      preferredStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_start'],
      ),
      preferredEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_end'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      )!,
      fallback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fallback'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoutineRevisionsTable createAlias(String alias) {
    return $RoutineRevisionsTable(attachedDatabase, alias);
  }
}

class RoutineRevisionRow extends DataClass
    implements Insertable<RoutineRevisionRow> {
  final String id;
  final String routineId;
  final int revision;
  final String title;
  final int? weekdays;
  final int? preferredStart;
  final int? preferredEnd;
  final String steps;
  final String? fallback;
  final DateTime createdAt;
  const RoutineRevisionRow({
    required this.id,
    required this.routineId,
    required this.revision,
    required this.title,
    this.weekdays,
    this.preferredStart,
    this.preferredEnd,
    required this.steps,
    this.fallback,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['revision'] = Variable<int>(revision);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || weekdays != null) {
      map['weekdays'] = Variable<int>(weekdays);
    }
    if (!nullToAbsent || preferredStart != null) {
      map['preferred_start'] = Variable<int>(preferredStart);
    }
    if (!nullToAbsent || preferredEnd != null) {
      map['preferred_end'] = Variable<int>(preferredEnd);
    }
    map['steps'] = Variable<String>(steps);
    if (!nullToAbsent || fallback != null) {
      map['fallback'] = Variable<String>(fallback);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoutineRevisionsCompanion toCompanion(bool nullToAbsent) {
    return RoutineRevisionsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      revision: Value(revision),
      title: Value(title),
      weekdays: weekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdays),
      preferredStart: preferredStart == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredStart),
      preferredEnd: preferredEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredEnd),
      steps: Value(steps),
      fallback: fallback == null && nullToAbsent
          ? const Value.absent()
          : Value(fallback),
      createdAt: Value(createdAt),
    );
  }

  factory RoutineRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRevisionRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      revision: serializer.fromJson<int>(json['revision']),
      title: serializer.fromJson<String>(json['title']),
      weekdays: serializer.fromJson<int?>(json['weekdays']),
      preferredStart: serializer.fromJson<int?>(json['preferredStart']),
      preferredEnd: serializer.fromJson<int?>(json['preferredEnd']),
      steps: serializer.fromJson<String>(json['steps']),
      fallback: serializer.fromJson<String?>(json['fallback']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'revision': serializer.toJson<int>(revision),
      'title': serializer.toJson<String>(title),
      'weekdays': serializer.toJson<int?>(weekdays),
      'preferredStart': serializer.toJson<int?>(preferredStart),
      'preferredEnd': serializer.toJson<int?>(preferredEnd),
      'steps': serializer.toJson<String>(steps),
      'fallback': serializer.toJson<String?>(fallback),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RoutineRevisionRow copyWith({
    String? id,
    String? routineId,
    int? revision,
    String? title,
    Value<int?> weekdays = const Value.absent(),
    Value<int?> preferredStart = const Value.absent(),
    Value<int?> preferredEnd = const Value.absent(),
    String? steps,
    Value<String?> fallback = const Value.absent(),
    DateTime? createdAt,
  }) => RoutineRevisionRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    revision: revision ?? this.revision,
    title: title ?? this.title,
    weekdays: weekdays.present ? weekdays.value : this.weekdays,
    preferredStart: preferredStart.present
        ? preferredStart.value
        : this.preferredStart,
    preferredEnd: preferredEnd.present ? preferredEnd.value : this.preferredEnd,
    steps: steps ?? this.steps,
    fallback: fallback.present ? fallback.value : this.fallback,
    createdAt: createdAt ?? this.createdAt,
  );
  RoutineRevisionRow copyWithCompanion(RoutineRevisionsCompanion data) {
    return RoutineRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      revision: data.revision.present ? data.revision.value : this.revision,
      title: data.title.present ? data.title.value : this.title,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      preferredStart: data.preferredStart.present
          ? data.preferredStart.value
          : this.preferredStart,
      preferredEnd: data.preferredEnd.present
          ? data.preferredEnd.value
          : this.preferredEnd,
      steps: data.steps.present ? data.steps.value : this.steps,
      fallback: data.fallback.present ? data.fallback.value : this.fallback,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRevisionRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('revision: $revision, ')
          ..write('title: $title, ')
          ..write('weekdays: $weekdays, ')
          ..write('preferredStart: $preferredStart, ')
          ..write('preferredEnd: $preferredEnd, ')
          ..write('steps: $steps, ')
          ..write('fallback: $fallback, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    revision,
    title,
    weekdays,
    preferredStart,
    preferredEnd,
    steps,
    fallback,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRevisionRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.revision == this.revision &&
          other.title == this.title &&
          other.weekdays == this.weekdays &&
          other.preferredStart == this.preferredStart &&
          other.preferredEnd == this.preferredEnd &&
          other.steps == this.steps &&
          other.fallback == this.fallback &&
          other.createdAt == this.createdAt);
}

class RoutineRevisionsCompanion extends UpdateCompanion<RoutineRevisionRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<int> revision;
  final Value<String> title;
  final Value<int?> weekdays;
  final Value<int?> preferredStart;
  final Value<int?> preferredEnd;
  final Value<String> steps;
  final Value<String?> fallback;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RoutineRevisionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.revision = const Value.absent(),
    this.title = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.preferredStart = const Value.absent(),
    this.preferredEnd = const Value.absent(),
    this.steps = const Value.absent(),
    this.fallback = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineRevisionsCompanion.insert({
    required String id,
    required String routineId,
    required int revision,
    required String title,
    this.weekdays = const Value.absent(),
    this.preferredStart = const Value.absent(),
    this.preferredEnd = const Value.absent(),
    this.steps = const Value.absent(),
    this.fallback = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       revision = Value(revision),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<RoutineRevisionRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<int>? revision,
    Expression<String>? title,
    Expression<int>? weekdays,
    Expression<int>? preferredStart,
    Expression<int>? preferredEnd,
    Expression<String>? steps,
    Expression<String>? fallback,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (revision != null) 'revision': revision,
      if (title != null) 'title': title,
      if (weekdays != null) 'weekdays': weekdays,
      if (preferredStart != null) 'preferred_start': preferredStart,
      if (preferredEnd != null) 'preferred_end': preferredEnd,
      if (steps != null) 'steps': steps,
      if (fallback != null) 'fallback': fallback,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<int>? revision,
    Value<String>? title,
    Value<int?>? weekdays,
    Value<int?>? preferredStart,
    Value<int?>? preferredEnd,
    Value<String>? steps,
    Value<String?>? fallback,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RoutineRevisionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      revision: revision ?? this.revision,
      title: title ?? this.title,
      weekdays: weekdays ?? this.weekdays,
      preferredStart: preferredStart ?? this.preferredStart,
      preferredEnd: preferredEnd ?? this.preferredEnd,
      steps: steps ?? this.steps,
      fallback: fallback ?? this.fallback,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (preferredStart.present) {
      map['preferred_start'] = Variable<int>(preferredStart.value);
    }
    if (preferredEnd.present) {
      map['preferred_end'] = Variable<int>(preferredEnd.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (fallback.present) {
      map['fallback'] = Variable<String>(fallback.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('revision: $revision, ')
          ..write('title: $title, ')
          ..write('weekdays: $weekdays, ')
          ..write('preferredStart: $preferredStart, ')
          ..write('preferredEnd: $preferredEnd, ')
          ..write('steps: $steps, ')
          ..write('fallback: $fallback, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineEventsTable extends RoutineEvents
    with TableInfo<$RoutineEventsTable, RoutineEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_revisions (id) ON DELETE CASCADE',
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
    routineId,
    revisionId,
    type,
    occurredAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
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
  RoutineEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      ),
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
  $RoutineEventsTable createAlias(String alias) {
    return $RoutineEventsTable(attachedDatabase, alias);
  }
}

class RoutineEventRow extends DataClass implements Insertable<RoutineEventRow> {
  final int id;
  final String routineId;
  final String? revisionId;
  final String type;
  final DateTime occurredAt;
  final String? metadata;
  const RoutineEventRow({
    required this.id,
    required this.routineId,
    this.revisionId,
    required this.type,
    required this.occurredAt,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<String>(routineId);
    if (!nullToAbsent || revisionId != null) {
      map['revision_id'] = Variable<String>(revisionId);
    }
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  RoutineEventsCompanion toCompanion(bool nullToAbsent) {
    return RoutineEventsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      revisionId: revisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(revisionId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory RoutineEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineEventRow(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      revisionId: serializer.fromJson<String?>(json['revisionId']),
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
      'routineId': serializer.toJson<String>(routineId),
      'revisionId': serializer.toJson<String?>(revisionId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  RoutineEventRow copyWith({
    int? id,
    String? routineId,
    Value<String?> revisionId = const Value.absent(),
    String? type,
    DateTime? occurredAt,
    Value<String?> metadata = const Value.absent(),
  }) => RoutineEventRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    revisionId: revisionId.present ? revisionId.value : this.revisionId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  RoutineEventRow copyWithCompanion(RoutineEventsCompanion data) {
    return RoutineEventRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineEventRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('revisionId: $revisionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, routineId, revisionId, type, occurredAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineEventRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.revisionId == this.revisionId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.metadata == this.metadata);
}

class RoutineEventsCompanion extends UpdateCompanion<RoutineEventRow> {
  final Value<int> id;
  final Value<String> routineId;
  final Value<String?> revisionId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String?> metadata;
  const RoutineEventsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  RoutineEventsCompanion.insert({
    this.id = const Value.absent(),
    required String routineId,
    this.revisionId = const Value.absent(),
    required String type,
    required DateTime occurredAt,
    this.metadata = const Value.absent(),
  }) : routineId = Value(routineId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<RoutineEventRow> custom({
    Expression<int>? id,
    Expression<String>? routineId,
    Expression<String>? revisionId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (revisionId != null) 'revision_id': revisionId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadata != null) 'metadata': metadata,
    });
  }

  RoutineEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? routineId,
    Value<String?>? revisionId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String?>? metadata,
  }) {
    return RoutineEventsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      revisionId: revisionId ?? this.revisionId,
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
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
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
    return (StringBuffer('RoutineEventsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('revisionId: $revisionId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

class $RoutineOccurrencesTable extends RoutineOccurrences
    with TableInfo<$RoutineOccurrencesTable, RoutineOccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeVersionMeta = const VerificationMeta(
    'changeVersion',
  );
  @override
  late final GeneratedColumn<int> changeVersion = GeneratedColumn<int>(
    'change_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _selectedDayMeta = const VerificationMeta(
    'selectedDay',
  );
  @override
  late final GeneratedColumn<String> selectedDay = GeneratedColumn<String>(
    'selected_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDayMeta = const VerificationMeta(
    'targetDay',
  );
  @override
  late final GeneratedColumn<String> targetDay = GeneratedColumn<String>(
    'target_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredStartMeta = const VerificationMeta(
    'preferredStart',
  );
  @override
  late final GeneratedColumn<int> preferredStart = GeneratedColumn<int>(
    'preferred_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredEndMeta = const VerificationMeta(
    'preferredEnd',
  );
  @override
  late final GeneratedColumn<int> preferredEnd = GeneratedColumn<int>(
    'preferred_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedAtMeta = const VerificationMeta(
    'selectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> selectedAt = GeneratedColumn<DateTime>(
    'selected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    changeVersion,
    routineId,
    revisionId,
    selectedDay,
    targetDay,
    state,
    position,
    steps,
    preferredStart,
    preferredEnd,
    selectedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineOccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('change_version')) {
      context.handle(
        _changeVersionMeta,
        changeVersion.isAcceptableOrUnknown(
          data['change_version']!,
          _changeVersionMeta,
        ),
      );
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('selected_day')) {
      context.handle(
        _selectedDayMeta,
        selectedDay.isAcceptableOrUnknown(
          data['selected_day']!,
          _selectedDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedDayMeta);
    }
    if (data.containsKey('target_day')) {
      context.handle(
        _targetDayMeta,
        targetDay.isAcceptableOrUnknown(data['target_day']!, _targetDayMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDayMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('preferred_start')) {
      context.handle(
        _preferredStartMeta,
        preferredStart.isAcceptableOrUnknown(
          data['preferred_start']!,
          _preferredStartMeta,
        ),
      );
    }
    if (data.containsKey('preferred_end')) {
      context.handle(
        _preferredEndMeta,
        preferredEnd.isAcceptableOrUnknown(
          data['preferred_end']!,
          _preferredEndMeta,
        ),
      );
    }
    if (data.containsKey('selected_at')) {
      context.handle(
        _selectedAtMeta,
        selectedAt.isAcceptableOrUnknown(data['selected_at']!, _selectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_selectedAtMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routineId, selectedDay},
  ];
  @override
  RoutineOccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineOccurrenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      changeVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_version'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      )!,
      selectedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_day'],
      )!,
      targetDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_day'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      )!,
      preferredStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_start'],
      ),
      preferredEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_end'],
      ),
      selectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}selected_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutineOccurrencesTable createAlias(String alias) {
    return $RoutineOccurrencesTable(attachedDatabase, alias);
  }
}

class RoutineOccurrenceRow extends DataClass
    implements Insertable<RoutineOccurrenceRow> {
  final String id;
  final int changeVersion;
  final String routineId;
  final String revisionId;
  final String selectedDay;
  final String targetDay;
  final String state;
  final int position;
  final String steps;
  final int? preferredStart;
  final int? preferredEnd;
  final DateTime selectedAt;
  final DateTime updatedAt;
  const RoutineOccurrenceRow({
    required this.id,
    required this.changeVersion,
    required this.routineId,
    required this.revisionId,
    required this.selectedDay,
    required this.targetDay,
    required this.state,
    required this.position,
    required this.steps,
    this.preferredStart,
    this.preferredEnd,
    required this.selectedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['change_version'] = Variable<int>(changeVersion);
    map['routine_id'] = Variable<String>(routineId);
    map['revision_id'] = Variable<String>(revisionId);
    map['selected_day'] = Variable<String>(selectedDay);
    map['target_day'] = Variable<String>(targetDay);
    map['state'] = Variable<String>(state);
    map['position'] = Variable<int>(position);
    map['steps'] = Variable<String>(steps);
    if (!nullToAbsent || preferredStart != null) {
      map['preferred_start'] = Variable<int>(preferredStart);
    }
    if (!nullToAbsent || preferredEnd != null) {
      map['preferred_end'] = Variable<int>(preferredEnd);
    }
    map['selected_at'] = Variable<DateTime>(selectedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoutineOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return RoutineOccurrencesCompanion(
      id: Value(id),
      changeVersion: Value(changeVersion),
      routineId: Value(routineId),
      revisionId: Value(revisionId),
      selectedDay: Value(selectedDay),
      targetDay: Value(targetDay),
      state: Value(state),
      position: Value(position),
      steps: Value(steps),
      preferredStart: preferredStart == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredStart),
      preferredEnd: preferredEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredEnd),
      selectedAt: Value(selectedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineOccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineOccurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      changeVersion: serializer.fromJson<int>(json['changeVersion']),
      routineId: serializer.fromJson<String>(json['routineId']),
      revisionId: serializer.fromJson<String>(json['revisionId']),
      selectedDay: serializer.fromJson<String>(json['selectedDay']),
      targetDay: serializer.fromJson<String>(json['targetDay']),
      state: serializer.fromJson<String>(json['state']),
      position: serializer.fromJson<int>(json['position']),
      steps: serializer.fromJson<String>(json['steps']),
      preferredStart: serializer.fromJson<int?>(json['preferredStart']),
      preferredEnd: serializer.fromJson<int?>(json['preferredEnd']),
      selectedAt: serializer.fromJson<DateTime>(json['selectedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'changeVersion': serializer.toJson<int>(changeVersion),
      'routineId': serializer.toJson<String>(routineId),
      'revisionId': serializer.toJson<String>(revisionId),
      'selectedDay': serializer.toJson<String>(selectedDay),
      'targetDay': serializer.toJson<String>(targetDay),
      'state': serializer.toJson<String>(state),
      'position': serializer.toJson<int>(position),
      'steps': serializer.toJson<String>(steps),
      'preferredStart': serializer.toJson<int?>(preferredStart),
      'preferredEnd': serializer.toJson<int?>(preferredEnd),
      'selectedAt': serializer.toJson<DateTime>(selectedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RoutineOccurrenceRow copyWith({
    String? id,
    int? changeVersion,
    String? routineId,
    String? revisionId,
    String? selectedDay,
    String? targetDay,
    String? state,
    int? position,
    String? steps,
    Value<int?> preferredStart = const Value.absent(),
    Value<int?> preferredEnd = const Value.absent(),
    DateTime? selectedAt,
    DateTime? updatedAt,
  }) => RoutineOccurrenceRow(
    id: id ?? this.id,
    changeVersion: changeVersion ?? this.changeVersion,
    routineId: routineId ?? this.routineId,
    revisionId: revisionId ?? this.revisionId,
    selectedDay: selectedDay ?? this.selectedDay,
    targetDay: targetDay ?? this.targetDay,
    state: state ?? this.state,
    position: position ?? this.position,
    steps: steps ?? this.steps,
    preferredStart: preferredStart.present
        ? preferredStart.value
        : this.preferredStart,
    preferredEnd: preferredEnd.present ? preferredEnd.value : this.preferredEnd,
    selectedAt: selectedAt ?? this.selectedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineOccurrenceRow copyWithCompanion(RoutineOccurrencesCompanion data) {
    return RoutineOccurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      changeVersion: data.changeVersion.present
          ? data.changeVersion.value
          : this.changeVersion,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      selectedDay: data.selectedDay.present
          ? data.selectedDay.value
          : this.selectedDay,
      targetDay: data.targetDay.present ? data.targetDay.value : this.targetDay,
      state: data.state.present ? data.state.value : this.state,
      position: data.position.present ? data.position.value : this.position,
      steps: data.steps.present ? data.steps.value : this.steps,
      preferredStart: data.preferredStart.present
          ? data.preferredStart.value
          : this.preferredStart,
      preferredEnd: data.preferredEnd.present
          ? data.preferredEnd.value
          : this.preferredEnd,
      selectedAt: data.selectedAt.present
          ? data.selectedAt.value
          : this.selectedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineOccurrenceRow(')
          ..write('id: $id, ')
          ..write('changeVersion: $changeVersion, ')
          ..write('routineId: $routineId, ')
          ..write('revisionId: $revisionId, ')
          ..write('selectedDay: $selectedDay, ')
          ..write('targetDay: $targetDay, ')
          ..write('state: $state, ')
          ..write('position: $position, ')
          ..write('steps: $steps, ')
          ..write('preferredStart: $preferredStart, ')
          ..write('preferredEnd: $preferredEnd, ')
          ..write('selectedAt: $selectedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    changeVersion,
    routineId,
    revisionId,
    selectedDay,
    targetDay,
    state,
    position,
    steps,
    preferredStart,
    preferredEnd,
    selectedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineOccurrenceRow &&
          other.id == this.id &&
          other.changeVersion == this.changeVersion &&
          other.routineId == this.routineId &&
          other.revisionId == this.revisionId &&
          other.selectedDay == this.selectedDay &&
          other.targetDay == this.targetDay &&
          other.state == this.state &&
          other.position == this.position &&
          other.steps == this.steps &&
          other.preferredStart == this.preferredStart &&
          other.preferredEnd == this.preferredEnd &&
          other.selectedAt == this.selectedAt &&
          other.updatedAt == this.updatedAt);
}

class RoutineOccurrencesCompanion
    extends UpdateCompanion<RoutineOccurrenceRow> {
  final Value<String> id;
  final Value<int> changeVersion;
  final Value<String> routineId;
  final Value<String> revisionId;
  final Value<String> selectedDay;
  final Value<String> targetDay;
  final Value<String> state;
  final Value<int> position;
  final Value<String> steps;
  final Value<int?> preferredStart;
  final Value<int?> preferredEnd;
  final Value<DateTime> selectedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoutineOccurrencesCompanion({
    this.id = const Value.absent(),
    this.changeVersion = const Value.absent(),
    this.routineId = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.selectedDay = const Value.absent(),
    this.targetDay = const Value.absent(),
    this.state = const Value.absent(),
    this.position = const Value.absent(),
    this.steps = const Value.absent(),
    this.preferredStart = const Value.absent(),
    this.preferredEnd = const Value.absent(),
    this.selectedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineOccurrencesCompanion.insert({
    required String id,
    this.changeVersion = const Value.absent(),
    required String routineId,
    required String revisionId,
    required String selectedDay,
    required String targetDay,
    this.state = const Value.absent(),
    this.position = const Value.absent(),
    required String steps,
    this.preferredStart = const Value.absent(),
    this.preferredEnd = const Value.absent(),
    required DateTime selectedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       revisionId = Value(revisionId),
       selectedDay = Value(selectedDay),
       targetDay = Value(targetDay),
       steps = Value(steps),
       selectedAt = Value(selectedAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineOccurrenceRow> custom({
    Expression<String>? id,
    Expression<int>? changeVersion,
    Expression<String>? routineId,
    Expression<String>? revisionId,
    Expression<String>? selectedDay,
    Expression<String>? targetDay,
    Expression<String>? state,
    Expression<int>? position,
    Expression<String>? steps,
    Expression<int>? preferredStart,
    Expression<int>? preferredEnd,
    Expression<DateTime>? selectedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (changeVersion != null) 'change_version': changeVersion,
      if (routineId != null) 'routine_id': routineId,
      if (revisionId != null) 'revision_id': revisionId,
      if (selectedDay != null) 'selected_day': selectedDay,
      if (targetDay != null) 'target_day': targetDay,
      if (state != null) 'state': state,
      if (position != null) 'position': position,
      if (steps != null) 'steps': steps,
      if (preferredStart != null) 'preferred_start': preferredStart,
      if (preferredEnd != null) 'preferred_end': preferredEnd,
      if (selectedAt != null) 'selected_at': selectedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<int>? changeVersion,
    Value<String>? routineId,
    Value<String>? revisionId,
    Value<String>? selectedDay,
    Value<String>? targetDay,
    Value<String>? state,
    Value<int>? position,
    Value<String>? steps,
    Value<int?>? preferredStart,
    Value<int?>? preferredEnd,
    Value<DateTime>? selectedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutineOccurrencesCompanion(
      id: id ?? this.id,
      changeVersion: changeVersion ?? this.changeVersion,
      routineId: routineId ?? this.routineId,
      revisionId: revisionId ?? this.revisionId,
      selectedDay: selectedDay ?? this.selectedDay,
      targetDay: targetDay ?? this.targetDay,
      state: state ?? this.state,
      position: position ?? this.position,
      steps: steps ?? this.steps,
      preferredStart: preferredStart ?? this.preferredStart,
      preferredEnd: preferredEnd ?? this.preferredEnd,
      selectedAt: selectedAt ?? this.selectedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (changeVersion.present) {
      map['change_version'] = Variable<int>(changeVersion.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (selectedDay.present) {
      map['selected_day'] = Variable<String>(selectedDay.value);
    }
    if (targetDay.present) {
      map['target_day'] = Variable<String>(targetDay.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (preferredStart.present) {
      map['preferred_start'] = Variable<int>(preferredStart.value);
    }
    if (preferredEnd.present) {
      map['preferred_end'] = Variable<int>(preferredEnd.value);
    }
    if (selectedAt.present) {
      map['selected_at'] = Variable<DateTime>(selectedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('changeVersion: $changeVersion, ')
          ..write('routineId: $routineId, ')
          ..write('revisionId: $revisionId, ')
          ..write('selectedDay: $selectedDay, ')
          ..write('targetDay: $targetDay, ')
          ..write('state: $state, ')
          ..write('position: $position, ')
          ..write('steps: $steps, ')
          ..write('preferredStart: $preferredStart, ')
          ..write('preferredEnd: $preferredEnd, ')
          ..write('selectedAt: $selectedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineOccurrenceEventsTable extends RoutineOccurrenceEvents
    with TableInfo<$RoutineOccurrenceEventsTable, RoutineOccurrenceEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineOccurrenceEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_occurrences (id) ON DELETE CASCADE',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    occurrenceId,
    type,
    occurredAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_occurrence_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineOccurrenceEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceIdMeta);
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
    } else if (isInserting) {
      context.missing(_metadataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineOccurrenceEventRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineOccurrenceEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
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
      )!,
    );
  }

  @override
  $RoutineOccurrenceEventsTable createAlias(String alias) {
    return $RoutineOccurrenceEventsTable(attachedDatabase, alias);
  }
}

class RoutineOccurrenceEventRow extends DataClass
    implements Insertable<RoutineOccurrenceEventRow> {
  final int id;
  final String occurrenceId;
  final String type;
  final DateTime occurredAt;
  final String metadata;
  const RoutineOccurrenceEventRow({
    required this.id,
    required this.occurrenceId,
    required this.type,
    required this.occurredAt,
    required this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['occurrence_id'] = Variable<String>(occurrenceId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  RoutineOccurrenceEventsCompanion toCompanion(bool nullToAbsent) {
    return RoutineOccurrenceEventsCompanion(
      id: Value(id),
      occurrenceId: Value(occurrenceId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      metadata: Value(metadata),
    );
  }

  factory RoutineOccurrenceEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineOccurrenceEventRow(
      id: serializer.fromJson<int>(json['id']),
      occurrenceId: serializer.fromJson<String>(json['occurrenceId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'occurrenceId': serializer.toJson<String>(occurrenceId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  RoutineOccurrenceEventRow copyWith({
    int? id,
    String? occurrenceId,
    String? type,
    DateTime? occurredAt,
    String? metadata,
  }) => RoutineOccurrenceEventRow(
    id: id ?? this.id,
    occurrenceId: occurrenceId ?? this.occurrenceId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    metadata: metadata ?? this.metadata,
  );
  RoutineOccurrenceEventRow copyWithCompanion(
    RoutineOccurrenceEventsCompanion data,
  ) {
    return RoutineOccurrenceEventRow(
      id: data.id.present ? data.id.value : this.id,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineOccurrenceEventRow(')
          ..write('id: $id, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, occurrenceId, type, occurredAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineOccurrenceEventRow &&
          other.id == this.id &&
          other.occurrenceId == this.occurrenceId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.metadata == this.metadata);
}

class RoutineOccurrenceEventsCompanion
    extends UpdateCompanion<RoutineOccurrenceEventRow> {
  final Value<int> id;
  final Value<String> occurrenceId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String> metadata;
  const RoutineOccurrenceEventsCompanion({
    this.id = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  RoutineOccurrenceEventsCompanion.insert({
    this.id = const Value.absent(),
    required String occurrenceId,
    required String type,
    required DateTime occurredAt,
    required String metadata,
  }) : occurrenceId = Value(occurrenceId),
       type = Value(type),
       occurredAt = Value(occurredAt),
       metadata = Value(metadata);
  static Insertable<RoutineOccurrenceEventRow> custom({
    Expression<int>? id,
    Expression<String>? occurrenceId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadata != null) 'metadata': metadata,
    });
  }

  RoutineOccurrenceEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? occurrenceId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String>? metadata,
  }) {
    return RoutineOccurrenceEventsCompanion(
      id: id ?? this.id,
      occurrenceId: occurrenceId ?? this.occurrenceId,
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
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
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
    return (StringBuffer('RoutineOccurrenceEventsCompanion(')
          ..write('id: $id, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

class $LocalReviewsTable extends LocalReviews
    with TableInfo<$LocalReviewsTable, LocalReviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES memories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    origin,
    dayKey,
    period,
    memoryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {period, dayKey, origin},
  ];
  @override
  LocalReviewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReviewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalReviewsTable createAlias(String alias) {
    return $LocalReviewsTable(attachedDatabase, alias);
  }
}

class LocalReviewRow extends DataClass implements Insertable<LocalReviewRow> {
  final String id;

  /// Imported copies retain their own slot and never replace this day's local note.
  final String origin;
  final String dayKey;
  final String period;
  final String memoryId;
  final DateTime createdAt;
  const LocalReviewRow({
    required this.id,
    required this.origin,
    required this.dayKey,
    required this.period,
    required this.memoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['origin'] = Variable<String>(origin);
    map['day_key'] = Variable<String>(dayKey);
    map['period'] = Variable<String>(period);
    map['memory_id'] = Variable<String>(memoryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalReviewsCompanion toCompanion(bool nullToAbsent) {
    return LocalReviewsCompanion(
      id: Value(id),
      origin: Value(origin),
      dayKey: Value(dayKey),
      period: Value(period),
      memoryId: Value(memoryId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalReviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReviewRow(
      id: serializer.fromJson<String>(json['id']),
      origin: serializer.fromJson<String>(json['origin']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      period: serializer.fromJson<String>(json['period']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'origin': serializer.toJson<String>(origin),
      'dayKey': serializer.toJson<String>(dayKey),
      'period': serializer.toJson<String>(period),
      'memoryId': serializer.toJson<String>(memoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalReviewRow copyWith({
    String? id,
    String? origin,
    String? dayKey,
    String? period,
    String? memoryId,
    DateTime? createdAt,
  }) => LocalReviewRow(
    id: id ?? this.id,
    origin: origin ?? this.origin,
    dayKey: dayKey ?? this.dayKey,
    period: period ?? this.period,
    memoryId: memoryId ?? this.memoryId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalReviewRow copyWithCompanion(LocalReviewsCompanion data) {
    return LocalReviewRow(
      id: data.id.present ? data.id.value : this.id,
      origin: data.origin.present ? data.origin.value : this.origin,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      period: data.period.present ? data.period.value : this.period,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReviewRow(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('dayKey: $dayKey, ')
          ..write('period: $period, ')
          ..write('memoryId: $memoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, origin, dayKey, period, memoryId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReviewRow &&
          other.id == this.id &&
          other.origin == this.origin &&
          other.dayKey == this.dayKey &&
          other.period == this.period &&
          other.memoryId == this.memoryId &&
          other.createdAt == this.createdAt);
}

class LocalReviewsCompanion extends UpdateCompanion<LocalReviewRow> {
  final Value<String> id;
  final Value<String> origin;
  final Value<String> dayKey;
  final Value<String> period;
  final Value<String> memoryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalReviewsCompanion({
    this.id = const Value.absent(),
    this.origin = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.period = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalReviewsCompanion.insert({
    required String id,
    this.origin = const Value.absent(),
    required String dayKey,
    required String period,
    required String memoryId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayKey = Value(dayKey),
       period = Value(period),
       memoryId = Value(memoryId),
       createdAt = Value(createdAt);
  static Insertable<LocalReviewRow> custom({
    Expression<String>? id,
    Expression<String>? origin,
    Expression<String>? dayKey,
    Expression<String>? period,
    Expression<String>? memoryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origin != null) 'origin': origin,
      if (dayKey != null) 'day_key': dayKey,
      if (period != null) 'period': period,
      if (memoryId != null) 'memory_id': memoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalReviewsCompanion copyWith({
    Value<String>? id,
    Value<String>? origin,
    Value<String>? dayKey,
    Value<String>? period,
    Value<String>? memoryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalReviewsCompanion(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      dayKey: dayKey ?? this.dayKey,
      period: period ?? this.period,
      memoryId: memoryId ?? this.memoryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalReviewsCompanion(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('dayKey: $dayKey, ')
          ..write('period: $period, ')
          ..write('memoryId: $memoryId, ')
          ..write('createdAt: $createdAt, ')
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
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $MemoryRevisionsTable memoryRevisions = $MemoryRevisionsTable(
    this,
  );
  late final $MemoryEventsTable memoryEvents = $MemoryEventsTable(this);
  late final $MemoryJobsTable memoryJobs = $MemoryJobsTable(this);
  late final $MemoryVectorsTable memoryVectors = $MemoryVectorsTable(this);
  late final $MemoryLinksTable memoryLinks = $MemoryLinksTable(this);
  late final $MemoryAttachmentsTable memoryAttachments =
      $MemoryAttachmentsTable(this);
  late final $AttachmentCleanupTable attachmentCleanup =
      $AttachmentCleanupTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $FocusEventsTable focusEvents = $FocusEventsTable(this);
  late final $MemoryCollectionsTable memoryCollections =
      $MemoryCollectionsTable(this);
  late final $CollectionEventsTable collectionEvents = $CollectionEventsTable(
    this,
  );
  late final $MemoryAssignmentsTable memoryAssignments =
      $MemoryAssignmentsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineRevisionsTable routineRevisions = $RoutineRevisionsTable(
    this,
  );
  late final $RoutineEventsTable routineEvents = $RoutineEventsTable(this);
  late final $RoutineOccurrencesTable routineOccurrences =
      $RoutineOccurrencesTable(this);
  late final $RoutineOccurrenceEventsTable routineOccurrenceEvents =
      $RoutineOccurrenceEventsTable(this);
  late final $LocalReviewsTable localReviews = $LocalReviewsTable(this);
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
    memories,
    memoryRevisions,
    memoryEvents,
    memoryJobs,
    memoryVectors,
    memoryLinks,
    memoryAttachments,
    attachmentCleanup,
    focusSessions,
    focusEvents,
    memoryCollections,
    collectionEvents,
    memoryAssignments,
    routines,
    routineRevisions,
    routineEvents,
    routineOccurrences,
    routineOccurrenceEvents,
    localReviews,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_revisions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_jobs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_vectors', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'focus_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('focus_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_collections', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_assignments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'intentions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_assignments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_assignments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_revisions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_occurrences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_occurrences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_occurrences',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('routine_occurrence_events', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_reviews', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$IntentionsTableCreateCompanionBuilder =
    IntentionsCompanion Function({
      Value<int> id,
      required String sourceApp,
      Value<String?> sourcePackage,
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
      Value<String?> sourcePackage,
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

  static MultiTypedResultKey<$MemoryAssignmentsTable, List<MemoryAssignmentRow>>
  _memoryAssignmentsRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryAssignments,
        aliasName: 'intentions__id__memory_assignments__intention_id',
      );

  $$MemoryAssignmentsTableProcessedTableManager get memoryAssignmentsRefs {
    final manager = $$MemoryAssignmentsTableTableManager(
      $_db,
      $_db.memoryAssignments,
    ).filter((f) => f.intentionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryAssignmentsRefsTable($_db),
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

  ColumnFilters<String> get sourcePackage => $composableBuilder(
    column: $table.sourcePackage,
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

  Expression<bool> memoryAssignmentsRefs(
    Expression<bool> Function($$MemoryAssignmentsTableFilterComposer f) f,
  ) {
    final $$MemoryAssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryAssignments,
      getReferencedColumn: (t) => t.intentionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryAssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.memoryAssignments,
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

  ColumnOrderings<String> get sourcePackage => $composableBuilder(
    column: $table.sourcePackage,
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

  GeneratedColumn<String> get sourcePackage => $composableBuilder(
    column: $table.sourcePackage,
    builder: (column) => column,
  );

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

  Expression<T> memoryAssignmentsRefs<T extends Object>(
    Expression<T> Function($$MemoryAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$MemoryAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memoryAssignments,
          getReferencedColumn: (t) => t.intentionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryAssignments,
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
          PrefetchHooks Function({
            bool intentionEventsRefs,
            bool memoryAssignmentsRefs,
          })
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
                Value<String?> sourcePackage = const Value.absent(),
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
                sourcePackage: sourcePackage,
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
                Value<String?> sourcePackage = const Value.absent(),
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
                sourcePackage: sourcePackage,
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
          prefetchHooksCallback:
              ({intentionEventsRefs = false, memoryAssignmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (intentionEventsRefs) db.intentionEvents,
                    if (memoryAssignmentsRefs) db.memoryAssignments,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.intentionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryAssignmentsRefs)
                        await $_getPrefetchedData<
                          IntentionRow,
                          $IntentionsTable,
                          MemoryAssignmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$IntentionsTableReferences
                              ._memoryAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IntentionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
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
      PrefetchHooks Function({
        bool intentionEventsRefs,
        bool memoryAssignmentsRefs,
      })
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
typedef $$MemoriesTableCreateCompanionBuilder =
    MemoriesCompanion Function({
      required String id,
      Value<String> kind,
      Value<String> source,
      required DateTime capturedAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$MemoriesTableUpdateCompanionBuilder =
    MemoriesCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> source,
      Value<DateTime> capturedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$MemoriesTableReferences
    extends BaseReferences<_$CyaDatabase, $MemoriesTable, MemoryRow> {
  $$MemoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MemoryRevisionsTable, List<MemoryRevisionRow>>
  _memoryRevisionsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryRevisions,
    aliasName: 'memories__id__memory_revisions__memory_id',
  );

  $$MemoryRevisionsTableProcessedTableManager get memoryRevisionsRefs {
    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryEventsTable, List<MemoryEventRow>>
  _memoryEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryEvents,
    aliasName: 'memories__id__memory_events__memory_id',
  );

  $$MemoryEventsTableProcessedTableManager get memoryEventsRefs {
    final manager = $$MemoryEventsTableTableManager(
      $_db,
      $_db.memoryEvents,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryAttachmentsTable, List<MemoryAttachmentRow>>
  _memoryAttachmentsRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryAttachments,
        aliasName: 'memories__id__memory_attachments__memory_id',
      );

  $$MemoryAttachmentsTableProcessedTableManager get memoryAttachmentsRefs {
    final manager = $$MemoryAttachmentsTableTableManager(
      $_db,
      $_db.memoryAttachments,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocalReviewsTable, List<LocalReviewRow>>
  _localReviewsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.localReviews,
    aliasName: 'memories__id__local_reviews__memory_id',
  );

  $$LocalReviewsTableProcessedTableManager get localReviewsRefs {
    final manager = $$LocalReviewsTableTableManager(
      $_db,
      $_db.localReviews,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localReviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoriesTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> memoryRevisionsRefs(
    Expression<bool> Function($$MemoryRevisionsTableFilterComposer f) f,
  ) {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryEventsRefs(
    Expression<bool> Function($$MemoryEventsTableFilterComposer f) f,
  ) {
    final $$MemoryEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEvents,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEventsTableFilterComposer(
            $db: $db,
            $table: $db.memoryEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryAttachmentsRefs(
    Expression<bool> Function($$MemoryAttachmentsTableFilterComposer f) f,
  ) {
    final $$MemoryAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryAttachments,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.memoryAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localReviewsRefs(
    Expression<bool> Function($$LocalReviewsTableFilterComposer f) f,
  ) {
    final $$LocalReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localReviews,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalReviewsTableFilterComposer(
            $db: $db,
            $table: $db.localReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoriesTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoriesTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoriesTable> {
  $$MemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> memoryRevisionsRefs<T extends Object>(
    Expression<T> Function($$MemoryRevisionsTableAnnotationComposer a) f,
  ) {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryEventsRefs<T extends Object>(
    Expression<T> Function($$MemoryEventsTableAnnotationComposer a) f,
  ) {
    final $$MemoryEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEvents,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryAttachmentsRefs<T extends Object>(
    Expression<T> Function($$MemoryAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$MemoryAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memoryAttachments,
          getReferencedColumn: (t) => t.memoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localReviewsRefs<T extends Object>(
    Expression<T> Function($$LocalReviewsTableAnnotationComposer a) f,
  ) {
    final $$LocalReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localReviews,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.localReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoriesTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoriesTable,
          MemoryRow,
          $$MemoriesTableFilterComposer,
          $$MemoriesTableOrderingComposer,
          $$MemoriesTableAnnotationComposer,
          $$MemoriesTableCreateCompanionBuilder,
          $$MemoriesTableUpdateCompanionBuilder,
          (MemoryRow, $$MemoriesTableReferences),
          MemoryRow,
          PrefetchHooks Function({
            bool memoryRevisionsRefs,
            bool memoryEventsRefs,
            bool memoryAttachmentsRefs,
            bool localReviewsRefs,
          })
        > {
  $$MemoriesTableTableManager(_$CyaDatabase db, $MemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion(
                id: id,
                kind: kind,
                source: source,
                capturedAt: capturedAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> kind = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime capturedAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion.insert(
                id: id,
                kind: kind,
                source: source,
                capturedAt: capturedAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                memoryRevisionsRefs = false,
                memoryEventsRefs = false,
                memoryAttachmentsRefs = false,
                localReviewsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (memoryRevisionsRefs) db.memoryRevisions,
                    if (memoryEventsRefs) db.memoryEvents,
                    if (memoryAttachmentsRefs) db.memoryAttachments,
                    if (localReviewsRefs) db.localReviews,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (memoryRevisionsRefs)
                        await $_getPrefetchedData<
                          MemoryRow,
                          $MemoriesTable,
                          MemoryRevisionRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoriesTableReferences
                              ._memoryRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryEventsRefs)
                        await $_getPrefetchedData<
                          MemoryRow,
                          $MemoriesTable,
                          MemoryEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoriesTableReferences
                              ._memoryEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryAttachmentsRefs)
                        await $_getPrefetchedData<
                          MemoryRow,
                          $MemoriesTable,
                          MemoryAttachmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoriesTableReferences
                              ._memoryAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localReviewsRefs)
                        await $_getPrefetchedData<
                          MemoryRow,
                          $MemoriesTable,
                          LocalReviewRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoriesTableReferences
                              ._localReviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).localReviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memoryId == item.id,
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

typedef $$MemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoriesTable,
      MemoryRow,
      $$MemoriesTableFilterComposer,
      $$MemoriesTableOrderingComposer,
      $$MemoriesTableAnnotationComposer,
      $$MemoriesTableCreateCompanionBuilder,
      $$MemoriesTableUpdateCompanionBuilder,
      (MemoryRow, $$MemoriesTableReferences),
      MemoryRow,
      PrefetchHooks Function({
        bool memoryRevisionsRefs,
        bool memoryEventsRefs,
        bool memoryAttachmentsRefs,
        bool localReviewsRefs,
      })
    >;
typedef $$MemoryRevisionsTableCreateCompanionBuilder =
    MemoryRevisionsCompanion Function({
      required String id,
      required String memoryId,
      required int revision,
      required String body,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MemoryRevisionsTableUpdateCompanionBuilder =
    MemoryRevisionsCompanion Function({
      Value<String> id,
      Value<String> memoryId,
      Value<int> revision,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MemoryRevisionsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $MemoryRevisionsTable,
          MemoryRevisionRow
        > {
  $$MemoryRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoriesTable _memoryIdTable(_$CyaDatabase db) =>
      db.memories.createAlias('memory_revisions__memory_id__memories__id');

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager(
      $_db,
      $_db.memories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MemoryEventsTable, List<MemoryEventRow>>
  _memoryEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryEvents,
    aliasName: 'memory_revisions__id__memory_events__revision_id',
  );

  $$MemoryEventsTableProcessedTableManager get memoryEventsRefs {
    final manager = $$MemoryEventsTableTableManager(
      $_db,
      $_db.memoryEvents,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryJobsTable, List<MemoryJobRow>>
  _memoryJobsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryJobs,
    aliasName: 'memory_revisions__id__memory_jobs__revision_id',
  );

  $$MemoryJobsTableProcessedTableManager get memoryJobsRefs {
    final manager = $$MemoryJobsTableTableManager(
      $_db,
      $_db.memoryJobs,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryVectorsTable, List<MemoryVectorRow>>
  _memoryVectorsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryVectors,
    aliasName: 'memory_revisions__id__memory_vectors__revision_id',
  );

  $$MemoryVectorsTableProcessedTableManager get memoryVectorsRefs {
    final manager = $$MemoryVectorsTableTableManager(
      $_db,
      $_db.memoryVectors,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryVectorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryAssignmentsTable, List<MemoryAssignmentRow>>
  _memoryAssignmentsRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryAssignments,
        aliasName: 'memory_revisions__id__memory_assignments__revision_id',
      );

  $$MemoryAssignmentsTableProcessedTableManager get memoryAssignmentsRefs {
    final manager = $$MemoryAssignmentsTableTableManager(
      $_db,
      $_db.memoryAssignments,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryRevisionsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryRevisionsTable> {
  $$MemoryRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableFilterComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> memoryEventsRefs(
    Expression<bool> Function($$MemoryEventsTableFilterComposer f) f,
  ) {
    final $$MemoryEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEvents,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEventsTableFilterComposer(
            $db: $db,
            $table: $db.memoryEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryJobsRefs(
    Expression<bool> Function($$MemoryJobsTableFilterComposer f) f,
  ) {
    final $$MemoryJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryJobs,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryJobsTableFilterComposer(
            $db: $db,
            $table: $db.memoryJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryVectorsRefs(
    Expression<bool> Function($$MemoryVectorsTableFilterComposer f) f,
  ) {
    final $$MemoryVectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryVectors,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVectorsTableFilterComposer(
            $db: $db,
            $table: $db.memoryVectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryAssignmentsRefs(
    Expression<bool> Function($$MemoryAssignmentsTableFilterComposer f) f,
  ) {
    final $$MemoryAssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryAssignments,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryAssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.memoryAssignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryRevisionsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryRevisionsTable> {
  $$MemoryRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableOrderingComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryRevisionsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryRevisionsTable> {
  $$MemoryRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> memoryEventsRefs<T extends Object>(
    Expression<T> Function($$MemoryEventsTableAnnotationComposer a) f,
  ) {
    final $$MemoryEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEvents,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryJobsRefs<T extends Object>(
    Expression<T> Function($$MemoryJobsTableAnnotationComposer a) f,
  ) {
    final $$MemoryJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryJobs,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryVectorsRefs<T extends Object>(
    Expression<T> Function($$MemoryVectorsTableAnnotationComposer a) f,
  ) {
    final $$MemoryVectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryVectors,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryVectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryAssignmentsRefs<T extends Object>(
    Expression<T> Function($$MemoryAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$MemoryAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memoryAssignments,
          getReferencedColumn: (t) => t.revisionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MemoryRevisionsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryRevisionsTable,
          MemoryRevisionRow,
          $$MemoryRevisionsTableFilterComposer,
          $$MemoryRevisionsTableOrderingComposer,
          $$MemoryRevisionsTableAnnotationComposer,
          $$MemoryRevisionsTableCreateCompanionBuilder,
          $$MemoryRevisionsTableUpdateCompanionBuilder,
          (MemoryRevisionRow, $$MemoryRevisionsTableReferences),
          MemoryRevisionRow,
          PrefetchHooks Function({
            bool memoryId,
            bool memoryEventsRefs,
            bool memoryJobsRefs,
            bool memoryVectorsRefs,
            bool memoryAssignmentsRefs,
          })
        > {
  $$MemoryRevisionsTableTableManager(
    _$CyaDatabase db,
    $MemoryRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryRevisionsCompanion(
                id: id,
                memoryId: memoryId,
                revision: revision,
                body: body,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memoryId,
                required int revision,
                required String body,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryRevisionsCompanion.insert(
                id: id,
                memoryId: memoryId,
                revision: revision,
                body: body,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                memoryId = false,
                memoryEventsRefs = false,
                memoryJobsRefs = false,
                memoryVectorsRefs = false,
                memoryAssignmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (memoryEventsRefs) db.memoryEvents,
                    if (memoryJobsRefs) db.memoryJobs,
                    if (memoryVectorsRefs) db.memoryVectors,
                    if (memoryAssignmentsRefs) db.memoryAssignments,
                  ],
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
                        if (memoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.memoryId,
                                    referencedTable:
                                        $$MemoryRevisionsTableReferences
                                            ._memoryIdTable(db),
                                    referencedColumn:
                                        $$MemoryRevisionsTableReferences
                                            ._memoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (memoryEventsRefs)
                        await $_getPrefetchedData<
                          MemoryRevisionRow,
                          $MemoryRevisionsTable,
                          MemoryEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryRevisionsTableReferences
                              ._memoryEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryJobsRefs)
                        await $_getPrefetchedData<
                          MemoryRevisionRow,
                          $MemoryRevisionsTable,
                          MemoryJobRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryRevisionsTableReferences
                              ._memoryJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryVectorsRefs)
                        await $_getPrefetchedData<
                          MemoryRevisionRow,
                          $MemoryRevisionsTable,
                          MemoryVectorRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryRevisionsTableReferences
                              ._memoryVectorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryVectorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryAssignmentsRefs)
                        await $_getPrefetchedData<
                          MemoryRevisionRow,
                          $MemoryRevisionsTable,
                          MemoryAssignmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryRevisionsTableReferences
                              ._memoryAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
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

typedef $$MemoryRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryRevisionsTable,
      MemoryRevisionRow,
      $$MemoryRevisionsTableFilterComposer,
      $$MemoryRevisionsTableOrderingComposer,
      $$MemoryRevisionsTableAnnotationComposer,
      $$MemoryRevisionsTableCreateCompanionBuilder,
      $$MemoryRevisionsTableUpdateCompanionBuilder,
      (MemoryRevisionRow, $$MemoryRevisionsTableReferences),
      MemoryRevisionRow,
      PrefetchHooks Function({
        bool memoryId,
        bool memoryEventsRefs,
        bool memoryJobsRefs,
        bool memoryVectorsRefs,
        bool memoryAssignmentsRefs,
      })
    >;
typedef $$MemoryEventsTableCreateCompanionBuilder =
    MemoryEventsCompanion Function({
      Value<int> id,
      required String memoryId,
      required String type,
      required DateTime occurredAt,
      Value<String?> revisionId,
      Value<String?> metadata,
    });
typedef $$MemoryEventsTableUpdateCompanionBuilder =
    MemoryEventsCompanion Function({
      Value<int> id,
      Value<String> memoryId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String?> revisionId,
      Value<String?> metadata,
    });

final class $$MemoryEventsTableReferences
    extends BaseReferences<_$CyaDatabase, $MemoryEventsTable, MemoryEventRow> {
  $$MemoryEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoriesTable _memoryIdTable(_$CyaDatabase db) =>
      db.memories.createAlias('memory_events__memory_id__memories__id');

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager(
      $_db,
      $_db.memories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MemoryRevisionsTable _revisionIdTable(_$CyaDatabase db) => db
      .memoryRevisions
      .createAlias('memory_events__revision_id__memory_revisions__id');

  $$MemoryRevisionsTableProcessedTableManager? get revisionId {
    final $_column = $_itemColumn<String>('revision_id');
    if ($_column == null) return null;
    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryEventsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryEventsTable> {
  $$MemoryEventsTableFilterComposer({
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

  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableFilterComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryRevisionsTableFilterComposer get revisionId {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryEventsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryEventsTable> {
  $$MemoryEventsTableOrderingComposer({
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

  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableOrderingComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryRevisionsTableOrderingComposer get revisionId {
    final $$MemoryRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryEventsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryEventsTable> {
  $$MemoryEventsTableAnnotationComposer({
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

  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryRevisionsTableAnnotationComposer get revisionId {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryEventsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryEventsTable,
          MemoryEventRow,
          $$MemoryEventsTableFilterComposer,
          $$MemoryEventsTableOrderingComposer,
          $$MemoryEventsTableAnnotationComposer,
          $$MemoryEventsTableCreateCompanionBuilder,
          $$MemoryEventsTableUpdateCompanionBuilder,
          (MemoryEventRow, $$MemoryEventsTableReferences),
          MemoryEventRow,
          PrefetchHooks Function({bool memoryId, bool revisionId})
        > {
  $$MemoryEventsTableTableManager(_$CyaDatabase db, $MemoryEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> revisionId = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
              }) => MemoryEventsCompanion(
                id: id,
                memoryId: memoryId,
                type: type,
                occurredAt: occurredAt,
                revisionId: revisionId,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String memoryId,
                required String type,
                required DateTime occurredAt,
                Value<String?> revisionId = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
              }) => MemoryEventsCompanion.insert(
                id: id,
                memoryId: memoryId,
                type: type,
                occurredAt: occurredAt,
                revisionId: revisionId,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoryId = false, revisionId = false}) {
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
                    if (memoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memoryId,
                                referencedTable: $$MemoryEventsTableReferences
                                    ._memoryIdTable(db),
                                referencedColumn: $$MemoryEventsTableReferences
                                    ._memoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (revisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.revisionId,
                                referencedTable: $$MemoryEventsTableReferences
                                    ._revisionIdTable(db),
                                referencedColumn: $$MemoryEventsTableReferences
                                    ._revisionIdTable(db)
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

typedef $$MemoryEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryEventsTable,
      MemoryEventRow,
      $$MemoryEventsTableFilterComposer,
      $$MemoryEventsTableOrderingComposer,
      $$MemoryEventsTableAnnotationComposer,
      $$MemoryEventsTableCreateCompanionBuilder,
      $$MemoryEventsTableUpdateCompanionBuilder,
      (MemoryEventRow, $$MemoryEventsTableReferences),
      MemoryEventRow,
      PrefetchHooks Function({bool memoryId, bool revisionId})
    >;
typedef $$MemoryJobsTableCreateCompanionBuilder =
    MemoryJobsCompanion Function({
      required String revisionId,
      Value<String> state,
      Value<int> attempts,
      Value<DateTime?> retryAt,
      Value<String?> lastError,
      Value<int> nextSegment,
      Value<String?> modelVersion,
      Value<int> rowid,
    });
typedef $$MemoryJobsTableUpdateCompanionBuilder =
    MemoryJobsCompanion Function({
      Value<String> revisionId,
      Value<String> state,
      Value<int> attempts,
      Value<DateTime?> retryAt,
      Value<String?> lastError,
      Value<int> nextSegment,
      Value<String?> modelVersion,
      Value<int> rowid,
    });

final class $$MemoryJobsTableReferences
    extends BaseReferences<_$CyaDatabase, $MemoryJobsTable, MemoryJobRow> {
  $$MemoryJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryRevisionsTable _revisionIdTable(_$CyaDatabase db) => db
      .memoryRevisions
      .createAlias('memory_jobs__revision_id__memory_revisions__id');

  $$MemoryRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<String>('revision_id')!;

    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryJobsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryJobsTable> {
  $$MemoryJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retryAt => $composableBuilder(
    column: $table.retryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextSegment => $composableBuilder(
    column: $table.nextSegment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryRevisionsTableFilterComposer get revisionId {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryJobsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryJobsTable> {
  $$MemoryJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retryAt => $composableBuilder(
    column: $table.retryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextSegment => $composableBuilder(
    column: $table.nextSegment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryRevisionsTableOrderingComposer get revisionId {
    final $$MemoryRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryJobsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryJobsTable> {
  $$MemoryJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get retryAt =>
      $composableBuilder(column: $table.retryAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get nextSegment => $composableBuilder(
    column: $table.nextSegment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  $$MemoryRevisionsTableAnnotationComposer get revisionId {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryJobsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryJobsTable,
          MemoryJobRow,
          $$MemoryJobsTableFilterComposer,
          $$MemoryJobsTableOrderingComposer,
          $$MemoryJobsTableAnnotationComposer,
          $$MemoryJobsTableCreateCompanionBuilder,
          $$MemoryJobsTableUpdateCompanionBuilder,
          (MemoryJobRow, $$MemoryJobsTableReferences),
          MemoryJobRow,
          PrefetchHooks Function({bool revisionId})
        > {
  $$MemoryJobsTableTableManager(_$CyaDatabase db, $MemoryJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> revisionId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> retryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> nextSegment = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryJobsCompanion(
                revisionId: revisionId,
                state: state,
                attempts: attempts,
                retryAt: retryAt,
                lastError: lastError,
                nextSegment: nextSegment,
                modelVersion: modelVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String revisionId,
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> retryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> nextSegment = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryJobsCompanion.insert(
                revisionId: revisionId,
                state: state,
                attempts: attempts,
                retryAt: retryAt,
                lastError: lastError,
                nextSegment: nextSegment,
                modelVersion: modelVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({revisionId = false}) {
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
                    if (revisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.revisionId,
                                referencedTable: $$MemoryJobsTableReferences
                                    ._revisionIdTable(db),
                                referencedColumn: $$MemoryJobsTableReferences
                                    ._revisionIdTable(db)
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

typedef $$MemoryJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryJobsTable,
      MemoryJobRow,
      $$MemoryJobsTableFilterComposer,
      $$MemoryJobsTableOrderingComposer,
      $$MemoryJobsTableAnnotationComposer,
      $$MemoryJobsTableCreateCompanionBuilder,
      $$MemoryJobsTableUpdateCompanionBuilder,
      (MemoryJobRow, $$MemoryJobsTableReferences),
      MemoryJobRow,
      PrefetchHooks Function({bool revisionId})
    >;
typedef $$MemoryVectorsTableCreateCompanionBuilder =
    MemoryVectorsCompanion Function({
      required String revisionId,
      required int segment,
      required String modelVersion,
      required int dimensions,
      required Uint8List vector,
      Value<int> rowid,
    });
typedef $$MemoryVectorsTableUpdateCompanionBuilder =
    MemoryVectorsCompanion Function({
      Value<String> revisionId,
      Value<int> segment,
      Value<String> modelVersion,
      Value<int> dimensions,
      Value<Uint8List> vector,
      Value<int> rowid,
    });

final class $$MemoryVectorsTableReferences
    extends
        BaseReferences<_$CyaDatabase, $MemoryVectorsTable, MemoryVectorRow> {
  $$MemoryVectorsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoryRevisionsTable _revisionIdTable(_$CyaDatabase db) => db
      .memoryRevisions
      .createAlias('memory_vectors__revision_id__memory_revisions__id');

  $$MemoryRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<String>('revision_id')!;

    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryVectorsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryVectorsTable> {
  $$MemoryVectorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryRevisionsTableFilterComposer get revisionId {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryVectorsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryVectorsTable> {
  $$MemoryVectorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryRevisionsTableOrderingComposer get revisionId {
    final $$MemoryRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryVectorsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryVectorsTable> {
  $$MemoryVectorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get segment =>
      $composableBuilder(column: $table.segment, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  $$MemoryRevisionsTableAnnotationComposer get revisionId {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryVectorsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryVectorsTable,
          MemoryVectorRow,
          $$MemoryVectorsTableFilterComposer,
          $$MemoryVectorsTableOrderingComposer,
          $$MemoryVectorsTableAnnotationComposer,
          $$MemoryVectorsTableCreateCompanionBuilder,
          $$MemoryVectorsTableUpdateCompanionBuilder,
          (MemoryVectorRow, $$MemoryVectorsTableReferences),
          MemoryVectorRow,
          PrefetchHooks Function({bool revisionId})
        > {
  $$MemoryVectorsTableTableManager(_$CyaDatabase db, $MemoryVectorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryVectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryVectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryVectorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> revisionId = const Value.absent(),
                Value<int> segment = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<int> dimensions = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryVectorsCompanion(
                revisionId: revisionId,
                segment: segment,
                modelVersion: modelVersion,
                dimensions: dimensions,
                vector: vector,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String revisionId,
                required int segment,
                required String modelVersion,
                required int dimensions,
                required Uint8List vector,
                Value<int> rowid = const Value.absent(),
              }) => MemoryVectorsCompanion.insert(
                revisionId: revisionId,
                segment: segment,
                modelVersion: modelVersion,
                dimensions: dimensions,
                vector: vector,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryVectorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({revisionId = false}) {
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
                    if (revisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.revisionId,
                                referencedTable: $$MemoryVectorsTableReferences
                                    ._revisionIdTable(db),
                                referencedColumn: $$MemoryVectorsTableReferences
                                    ._revisionIdTable(db)
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

typedef $$MemoryVectorsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryVectorsTable,
      MemoryVectorRow,
      $$MemoryVectorsTableFilterComposer,
      $$MemoryVectorsTableOrderingComposer,
      $$MemoryVectorsTableAnnotationComposer,
      $$MemoryVectorsTableCreateCompanionBuilder,
      $$MemoryVectorsTableUpdateCompanionBuilder,
      (MemoryVectorRow, $$MemoryVectorsTableReferences),
      MemoryVectorRow,
      PrefetchHooks Function({bool revisionId})
    >;
typedef $$MemoryLinksTableCreateCompanionBuilder =
    MemoryLinksCompanion Function({
      required String id,
      required String fromRevision,
      required String toRevision,
      required String kind,
      required String provenance,
      required String state,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MemoryLinksTableUpdateCompanionBuilder =
    MemoryLinksCompanion Function({
      Value<String> id,
      Value<String> fromRevision,
      Value<String> toRevision,
      Value<String> kind,
      Value<String> provenance,
      Value<String> state,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MemoryLinksTableReferences
    extends BaseReferences<_$CyaDatabase, $MemoryLinksTable, MemoryLinkRow> {
  $$MemoryLinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryRevisionsTable _fromRevisionTable(_$CyaDatabase db) => db
      .memoryRevisions
      .createAlias('memory_links__from_revision__memory_revisions__id');

  $$MemoryRevisionsTableProcessedTableManager get fromRevision {
    final $_column = $_itemColumn<String>('from_revision')!;

    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromRevisionTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MemoryRevisionsTable _toRevisionTable(_$CyaDatabase db) => db
      .memoryRevisions
      .createAlias('memory_links__to_revision__memory_revisions__id');

  $$MemoryRevisionsTableProcessedTableManager get toRevision {
    final $_column = $_itemColumn<String>('to_revision')!;

    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toRevisionTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryLinksTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryLinksTable> {
  $$MemoryLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryRevisionsTableFilterComposer get fromRevision {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromRevision,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryRevisionsTableFilterComposer get toRevision {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toRevision,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryLinksTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryLinksTable> {
  $$MemoryLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryRevisionsTableOrderingComposer get fromRevision {
    final $$MemoryRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromRevision,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryRevisionsTableOrderingComposer get toRevision {
    final $$MemoryRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toRevision,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryLinksTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryLinksTable> {
  $$MemoryLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MemoryRevisionsTableAnnotationComposer get fromRevision {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromRevision,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryRevisionsTableAnnotationComposer get toRevision {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toRevision,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryLinksTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryLinksTable,
          MemoryLinkRow,
          $$MemoryLinksTableFilterComposer,
          $$MemoryLinksTableOrderingComposer,
          $$MemoryLinksTableAnnotationComposer,
          $$MemoryLinksTableCreateCompanionBuilder,
          $$MemoryLinksTableUpdateCompanionBuilder,
          (MemoryLinkRow, $$MemoryLinksTableReferences),
          MemoryLinkRow,
          PrefetchHooks Function({bool fromRevision, bool toRevision})
        > {
  $$MemoryLinksTableTableManager(_$CyaDatabase db, $MemoryLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromRevision = const Value.absent(),
                Value<String> toRevision = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryLinksCompanion(
                id: id,
                fromRevision: fromRevision,
                toRevision: toRevision,
                kind: kind,
                provenance: provenance,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromRevision,
                required String toRevision,
                required String kind,
                required String provenance,
                required String state,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryLinksCompanion.insert(
                id: id,
                fromRevision: fromRevision,
                toRevision: toRevision,
                kind: kind,
                provenance: provenance,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromRevision = false, toRevision = false}) {
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
                    if (fromRevision) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fromRevision,
                                referencedTable: $$MemoryLinksTableReferences
                                    ._fromRevisionTable(db),
                                referencedColumn: $$MemoryLinksTableReferences
                                    ._fromRevisionTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (toRevision) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.toRevision,
                                referencedTable: $$MemoryLinksTableReferences
                                    ._toRevisionTable(db),
                                referencedColumn: $$MemoryLinksTableReferences
                                    ._toRevisionTable(db)
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

typedef $$MemoryLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryLinksTable,
      MemoryLinkRow,
      $$MemoryLinksTableFilterComposer,
      $$MemoryLinksTableOrderingComposer,
      $$MemoryLinksTableAnnotationComposer,
      $$MemoryLinksTableCreateCompanionBuilder,
      $$MemoryLinksTableUpdateCompanionBuilder,
      (MemoryLinkRow, $$MemoryLinksTableReferences),
      MemoryLinkRow,
      PrefetchHooks Function({bool fromRevision, bool toRevision})
    >;
typedef $$MemoryAttachmentsTableCreateCompanionBuilder =
    MemoryAttachmentsCompanion Function({
      required String id,
      required String memoryId,
      required String fileName,
      required String sha256,
      required int byteLength,
      required int durationMillis,
      required DateTime capturedAt,
      Value<int> rowid,
    });
typedef $$MemoryAttachmentsTableUpdateCompanionBuilder =
    MemoryAttachmentsCompanion Function({
      Value<String> id,
      Value<String> memoryId,
      Value<String> fileName,
      Value<String> sha256,
      Value<int> byteLength,
      Value<int> durationMillis,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });

final class $$MemoryAttachmentsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $MemoryAttachmentsTable,
          MemoryAttachmentRow
        > {
  $$MemoryAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoriesTable _memoryIdTable(_$CyaDatabase db) =>
      db.memories.createAlias('memory_attachments__memory_id__memories__id');

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager(
      $_db,
      $_db.memories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryAttachmentsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryAttachmentsTable> {
  $$MemoryAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMillis => $composableBuilder(
    column: $table.durationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableFilterComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryAttachmentsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryAttachmentsTable> {
  $$MemoryAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMillis => $composableBuilder(
    column: $table.durationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableOrderingComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryAttachmentsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryAttachmentsTable> {
  $$MemoryAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMillis => $composableBuilder(
    column: $table.durationMillis,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryAttachmentsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryAttachmentsTable,
          MemoryAttachmentRow,
          $$MemoryAttachmentsTableFilterComposer,
          $$MemoryAttachmentsTableOrderingComposer,
          $$MemoryAttachmentsTableAnnotationComposer,
          $$MemoryAttachmentsTableCreateCompanionBuilder,
          $$MemoryAttachmentsTableUpdateCompanionBuilder,
          (MemoryAttachmentRow, $$MemoryAttachmentsTableReferences),
          MemoryAttachmentRow,
          PrefetchHooks Function({bool memoryId})
        > {
  $$MemoryAttachmentsTableTableManager(
    _$CyaDatabase db,
    $MemoryAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> byteLength = const Value.absent(),
                Value<int> durationMillis = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryAttachmentsCompanion(
                id: id,
                memoryId: memoryId,
                fileName: fileName,
                sha256: sha256,
                byteLength: byteLength,
                durationMillis: durationMillis,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memoryId,
                required String fileName,
                required String sha256,
                required int byteLength,
                required int durationMillis,
                required DateTime capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryAttachmentsCompanion.insert(
                id: id,
                memoryId: memoryId,
                fileName: fileName,
                sha256: sha256,
                byteLength: byteLength,
                durationMillis: durationMillis,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoryId = false}) {
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
                    if (memoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memoryId,
                                referencedTable:
                                    $$MemoryAttachmentsTableReferences
                                        ._memoryIdTable(db),
                                referencedColumn:
                                    $$MemoryAttachmentsTableReferences
                                        ._memoryIdTable(db)
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

typedef $$MemoryAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryAttachmentsTable,
      MemoryAttachmentRow,
      $$MemoryAttachmentsTableFilterComposer,
      $$MemoryAttachmentsTableOrderingComposer,
      $$MemoryAttachmentsTableAnnotationComposer,
      $$MemoryAttachmentsTableCreateCompanionBuilder,
      $$MemoryAttachmentsTableUpdateCompanionBuilder,
      (MemoryAttachmentRow, $$MemoryAttachmentsTableReferences),
      MemoryAttachmentRow,
      PrefetchHooks Function({bool memoryId})
    >;
typedef $$AttachmentCleanupTableCreateCompanionBuilder =
    AttachmentCleanupCompanion Function({
      required String fileName,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentCleanupTableUpdateCompanionBuilder =
    AttachmentCleanupCompanion Function({
      Value<String> fileName,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentCleanupTableFilterComposer
    extends Composer<_$CyaDatabase, $AttachmentCleanupTable> {
  $$AttachmentCleanupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentCleanupTableOrderingComposer
    extends Composer<_$CyaDatabase, $AttachmentCleanupTable> {
  $$AttachmentCleanupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentCleanupTableAnnotationComposer
    extends Composer<_$CyaDatabase, $AttachmentCleanupTable> {
  $$AttachmentCleanupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentCleanupTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $AttachmentCleanupTable,
          AttachmentCleanupRow,
          $$AttachmentCleanupTableFilterComposer,
          $$AttachmentCleanupTableOrderingComposer,
          $$AttachmentCleanupTableAnnotationComposer,
          $$AttachmentCleanupTableCreateCompanionBuilder,
          $$AttachmentCleanupTableUpdateCompanionBuilder,
          (
            AttachmentCleanupRow,
            BaseReferences<
              _$CyaDatabase,
              $AttachmentCleanupTable,
              AttachmentCleanupRow
            >,
          ),
          AttachmentCleanupRow,
          PrefetchHooks Function()
        > {
  $$AttachmentCleanupTableTableManager(
    _$CyaDatabase db,
    $AttachmentCleanupTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentCleanupTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentCleanupTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentCleanupTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentCleanupCompanion(
                fileName: fileName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentCleanupCompanion.insert(
                fileName: fileName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentCleanupTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $AttachmentCleanupTable,
      AttachmentCleanupRow,
      $$AttachmentCleanupTableFilterComposer,
      $$AttachmentCleanupTableOrderingComposer,
      $$AttachmentCleanupTableAnnotationComposer,
      $$AttachmentCleanupTableCreateCompanionBuilder,
      $$AttachmentCleanupTableUpdateCompanionBuilder,
      (
        AttachmentCleanupRow,
        BaseReferences<
          _$CyaDatabase,
          $AttachmentCleanupTable,
          AttachmentCleanupRow
        >,
      ),
      AttachmentCleanupRow,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      required String id,
      required String priority,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<String> id,
      Value<String> priority,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

final class $$FocusSessionsTableReferences
    extends
        BaseReferences<_$CyaDatabase, $FocusSessionsTable, FocusSessionRow> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FocusEventsTable, List<FocusEventRow>>
  _focusEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.focusEvents,
    aliasName: 'focus_sessions__id__focus_events__session_id',
  );

  $$FocusEventsTableProcessedTableManager get focusEventsRefs {
    final manager = $$FocusEventsTableTableManager(
      $_db,
      $_db.focusEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$CyaDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> focusEventsRefs(
    Expression<bool> Function($$FocusEventsTableFilterComposer f) f,
  ) {
    final $$FocusEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusEventsTableFilterComposer(
            $db: $db,
            $table: $db.focusEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$CyaDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  Expression<T> focusEventsRefs<T extends Object>(
    Expression<T> Function($$FocusEventsTableAnnotationComposer a) f,
  ) {
    final $$FocusEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $FocusSessionsTable,
          FocusSessionRow,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSessionRow, $$FocusSessionsTableReferences),
          FocusSessionRow,
          PrefetchHooks Function({bool focusEventsRefs})
        > {
  $$FocusSessionsTableTableManager(_$CyaDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                priority: priority,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String priority,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                priority: priority,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FocusSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({focusEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (focusEventsRefs) db.focusEvents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (focusEventsRefs)
                    await $_getPrefetchedData<
                      FocusSessionRow,
                      $FocusSessionsTable,
                      FocusEventRow
                    >(
                      currentTable: table,
                      referencedTable: $$FocusSessionsTableReferences
                          ._focusEventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FocusSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).focusEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $FocusSessionsTable,
      FocusSessionRow,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSessionRow, $$FocusSessionsTableReferences),
      FocusSessionRow,
      PrefetchHooks Function({bool focusEventsRefs})
    >;
typedef $$FocusEventsTableCreateCompanionBuilder =
    FocusEventsCompanion Function({
      Value<int> id,
      required String sessionId,
      required String type,
      required DateTime occurredAt,
    });
typedef $$FocusEventsTableUpdateCompanionBuilder =
    FocusEventsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> type,
      Value<DateTime> occurredAt,
    });

final class $$FocusEventsTableReferences
    extends BaseReferences<_$CyaDatabase, $FocusEventsTable, FocusEventRow> {
  $$FocusEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FocusSessionsTable _sessionIdTable(_$CyaDatabase db) => db
      .focusSessions
      .createAlias('focus_events__session_id__focus_sessions__id');

  $$FocusSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusEventsTableFilterComposer
    extends Composer<_$CyaDatabase, $FocusEventsTable> {
  $$FocusEventsTableFilterComposer({
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

  $$FocusSessionsTableFilterComposer get sessionId {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusEventsTableOrderingComposer
    extends Composer<_$CyaDatabase, $FocusEventsTable> {
  $$FocusEventsTableOrderingComposer({
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

  $$FocusSessionsTableOrderingComposer get sessionId {
    final $$FocusSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusEventsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $FocusEventsTable> {
  $$FocusEventsTableAnnotationComposer({
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

  $$FocusSessionsTableAnnotationComposer get sessionId {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusEventsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $FocusEventsTable,
          FocusEventRow,
          $$FocusEventsTableFilterComposer,
          $$FocusEventsTableOrderingComposer,
          $$FocusEventsTableAnnotationComposer,
          $$FocusEventsTableCreateCompanionBuilder,
          $$FocusEventsTableUpdateCompanionBuilder,
          (FocusEventRow, $$FocusEventsTableReferences),
          FocusEventRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$FocusEventsTableTableManager(_$CyaDatabase db, $FocusEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => FocusEventsCompanion(
                id: id,
                sessionId: sessionId,
                type: type,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String type,
                required DateTime occurredAt,
              }) => FocusEventsCompanion.insert(
                id: id,
                sessionId: sessionId,
                type: type,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FocusEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$FocusEventsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$FocusEventsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$FocusEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $FocusEventsTable,
      FocusEventRow,
      $$FocusEventsTableFilterComposer,
      $$FocusEventsTableOrderingComposer,
      $$FocusEventsTableAnnotationComposer,
      $$FocusEventsTableCreateCompanionBuilder,
      $$FocusEventsTableUpdateCompanionBuilder,
      (FocusEventRow, $$FocusEventsTableReferences),
      FocusEventRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MemoryCollectionsTableCreateCompanionBuilder =
    MemoryCollectionsCompanion Function({
      required String id,
      required String title,
      required String kind,
      Value<String?> parentId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MemoryCollectionsTableUpdateCompanionBuilder =
    MemoryCollectionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> kind,
      Value<String?> parentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MemoryCollectionsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $MemoryCollectionsTable,
          MemoryCollectionRow
        > {
  $$MemoryCollectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoryCollectionsTable _parentIdTable(_$CyaDatabase db) => db
      .memoryCollections
      .createAlias('memory_collections__parent_id__memory_collections__id');

  $$MemoryCollectionsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$MemoryCollectionsTableTableManager(
      $_db,
      $_db.memoryCollections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CollectionEventsTable, List<CollectionEventRow>>
  _collectionEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionEvents,
    aliasName: 'memory_collections__id__collection_events__collection_id',
  );

  $$CollectionEventsTableProcessedTableManager get collectionEventsRefs {
    final manager = $$CollectionEventsTableTableManager(
      $_db,
      $_db.collectionEvents,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryAssignmentsTable, List<MemoryAssignmentRow>>
  _memoryAssignmentsRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryAssignments,
        aliasName: 'memory_collections__id__memory_assignments__collection_id',
      );

  $$MemoryAssignmentsTableProcessedTableManager get memoryAssignmentsRefs {
    final manager = $$MemoryAssignmentsTableTableManager(
      $_db,
      $_db.memoryAssignments,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryCollectionsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryCollectionsTable> {
  $$MemoryCollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryCollectionsTableFilterComposer get parentId {
    final $$MemoryCollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.memoryCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCollectionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> collectionEventsRefs(
    Expression<bool> Function($$CollectionEventsTableFilterComposer f) f,
  ) {
    final $$CollectionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionEvents,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionEventsTableFilterComposer(
            $db: $db,
            $table: $db.collectionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryAssignmentsRefs(
    Expression<bool> Function($$MemoryAssignmentsTableFilterComposer f) f,
  ) {
    final $$MemoryAssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryAssignments,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryAssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.memoryAssignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryCollectionsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryCollectionsTable> {
  $$MemoryCollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryCollectionsTableOrderingComposer get parentId {
    final $$MemoryCollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.memoryCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryCollectionsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryCollectionsTable> {
  $$MemoryCollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MemoryCollectionsTableAnnotationComposer get parentId {
    final $$MemoryCollectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.parentId,
          referencedTable: $db.memoryCollections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryCollectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryCollections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> collectionEventsRefs<T extends Object>(
    Expression<T> Function($$CollectionEventsTableAnnotationComposer a) f,
  ) {
    final $$CollectionEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionEvents,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryAssignmentsRefs<T extends Object>(
    Expression<T> Function($$MemoryAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$MemoryAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memoryAssignments,
          getReferencedColumn: (t) => t.collectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MemoryCollectionsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryCollectionsTable,
          MemoryCollectionRow,
          $$MemoryCollectionsTableFilterComposer,
          $$MemoryCollectionsTableOrderingComposer,
          $$MemoryCollectionsTableAnnotationComposer,
          $$MemoryCollectionsTableCreateCompanionBuilder,
          $$MemoryCollectionsTableUpdateCompanionBuilder,
          (MemoryCollectionRow, $$MemoryCollectionsTableReferences),
          MemoryCollectionRow,
          PrefetchHooks Function({
            bool parentId,
            bool collectionEventsRefs,
            bool memoryAssignmentsRefs,
          })
        > {
  $$MemoryCollectionsTableTableManager(
    _$CyaDatabase db,
    $MemoryCollectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryCollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryCollectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryCollectionsCompanion(
                id: id,
                title: title,
                kind: kind,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String kind,
                Value<String?> parentId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryCollectionsCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryCollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                collectionEventsRefs = false,
                memoryAssignmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (collectionEventsRefs) db.collectionEvents,
                    if (memoryAssignmentsRefs) db.memoryAssignments,
                  ],
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
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable:
                                        $$MemoryCollectionsTableReferences
                                            ._parentIdTable(db),
                                    referencedColumn:
                                        $$MemoryCollectionsTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (collectionEventsRefs)
                        await $_getPrefetchedData<
                          MemoryCollectionRow,
                          $MemoryCollectionsTable,
                          CollectionEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryCollectionsTableReferences
                              ._collectionEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryCollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryAssignmentsRefs)
                        await $_getPrefetchedData<
                          MemoryCollectionRow,
                          $MemoryCollectionsTable,
                          MemoryAssignmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryCollectionsTableReferences
                              ._memoryAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryCollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
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

typedef $$MemoryCollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryCollectionsTable,
      MemoryCollectionRow,
      $$MemoryCollectionsTableFilterComposer,
      $$MemoryCollectionsTableOrderingComposer,
      $$MemoryCollectionsTableAnnotationComposer,
      $$MemoryCollectionsTableCreateCompanionBuilder,
      $$MemoryCollectionsTableUpdateCompanionBuilder,
      (MemoryCollectionRow, $$MemoryCollectionsTableReferences),
      MemoryCollectionRow,
      PrefetchHooks Function({
        bool parentId,
        bool collectionEventsRefs,
        bool memoryAssignmentsRefs,
      })
    >;
typedef $$CollectionEventsTableCreateCompanionBuilder =
    CollectionEventsCompanion Function({
      Value<int> id,
      required String collectionId,
      required String type,
      required DateTime occurredAt,
      required String metadata,
    });
typedef $$CollectionEventsTableUpdateCompanionBuilder =
    CollectionEventsCompanion Function({
      Value<int> id,
      Value<String> collectionId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String> metadata,
    });

final class $$CollectionEventsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $CollectionEventsTable,
          CollectionEventRow
        > {
  $$CollectionEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoryCollectionsTable _collectionIdTable(_$CyaDatabase db) => db
      .memoryCollections
      .createAlias('collection_events__collection_id__memory_collections__id');

  $$MemoryCollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $$MemoryCollectionsTableTableManager(
      $_db,
      $_db.memoryCollections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionEventsTableFilterComposer
    extends Composer<_$CyaDatabase, $CollectionEventsTable> {
  $$CollectionEventsTableFilterComposer({
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

  $$MemoryCollectionsTableFilterComposer get collectionId {
    final $$MemoryCollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.memoryCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCollectionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionEventsTableOrderingComposer
    extends Composer<_$CyaDatabase, $CollectionEventsTable> {
  $$CollectionEventsTableOrderingComposer({
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

  $$MemoryCollectionsTableOrderingComposer get collectionId {
    final $$MemoryCollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.memoryCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionEventsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $CollectionEventsTable> {
  $$CollectionEventsTableAnnotationComposer({
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

  $$MemoryCollectionsTableAnnotationComposer get collectionId {
    final $$MemoryCollectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.collectionId,
          referencedTable: $db.memoryCollections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryCollectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryCollections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CollectionEventsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $CollectionEventsTable,
          CollectionEventRow,
          $$CollectionEventsTableFilterComposer,
          $$CollectionEventsTableOrderingComposer,
          $$CollectionEventsTableAnnotationComposer,
          $$CollectionEventsTableCreateCompanionBuilder,
          $$CollectionEventsTableUpdateCompanionBuilder,
          (CollectionEventRow, $$CollectionEventsTableReferences),
          CollectionEventRow,
          PrefetchHooks Function({bool collectionId})
        > {
  $$CollectionEventsTableTableManager(
    _$CyaDatabase db,
    $CollectionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
              }) => CollectionEventsCompanion(
                id: id,
                collectionId: collectionId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String collectionId,
                required String type,
                required DateTime occurredAt,
                required String metadata,
              }) => CollectionEventsCompanion.insert(
                id: id,
                collectionId: collectionId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
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
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable:
                                    $$CollectionEventsTableReferences
                                        ._collectionIdTable(db),
                                referencedColumn:
                                    $$CollectionEventsTableReferences
                                        ._collectionIdTable(db)
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

typedef $$CollectionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $CollectionEventsTable,
      CollectionEventRow,
      $$CollectionEventsTableFilterComposer,
      $$CollectionEventsTableOrderingComposer,
      $$CollectionEventsTableAnnotationComposer,
      $$CollectionEventsTableCreateCompanionBuilder,
      $$CollectionEventsTableUpdateCompanionBuilder,
      (CollectionEventRow, $$CollectionEventsTableReferences),
      CollectionEventRow,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$MemoryAssignmentsTableCreateCompanionBuilder =
    MemoryAssignmentsCompanion Function({
      required String id,
      required String revisionId,
      Value<int?> intentionId,
      Value<String?> collectionId,
      required String kind,
      required String context,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MemoryAssignmentsTableUpdateCompanionBuilder =
    MemoryAssignmentsCompanion Function({
      Value<String> id,
      Value<String> revisionId,
      Value<int?> intentionId,
      Value<String?> collectionId,
      Value<String> kind,
      Value<String> context,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MemoryAssignmentsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $MemoryAssignmentsTable,
          MemoryAssignmentRow
        > {
  $$MemoryAssignmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoryRevisionsTable _revisionIdTable(_$CyaDatabase db) => db
      .memoryRevisions
      .createAlias('memory_assignments__revision_id__memory_revisions__id');

  $$MemoryRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<String>('revision_id')!;

    final manager = $$MemoryRevisionsTableTableManager(
      $_db,
      $_db.memoryRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IntentionsTable _intentionIdTable(_$CyaDatabase db) => db.intentions
      .createAlias('memory_assignments__intention_id__intentions__id');

  $$IntentionsTableProcessedTableManager? get intentionId {
    final $_column = $_itemColumn<int>('intention_id');
    if ($_column == null) return null;
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

  static $MemoryCollectionsTable _collectionIdTable(_$CyaDatabase db) => db
      .memoryCollections
      .createAlias('memory_assignments__collection_id__memory_collections__id');

  $$MemoryCollectionsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<String>('collection_id');
    if ($_column == null) return null;
    final manager = $$MemoryCollectionsTableTableManager(
      $_db,
      $_db.memoryCollections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryAssignmentsTableFilterComposer
    extends Composer<_$CyaDatabase, $MemoryAssignmentsTable> {
  $$MemoryAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryRevisionsTableFilterComposer get revisionId {
    final $$MemoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$MemoryCollectionsTableFilterComposer get collectionId {
    final $$MemoryCollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.memoryCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCollectionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryAssignmentsTableOrderingComposer
    extends Composer<_$CyaDatabase, $MemoryAssignmentsTable> {
  $$MemoryAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryRevisionsTableOrderingComposer get revisionId {
    final $$MemoryRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$MemoryCollectionsTableOrderingComposer get collectionId {
    final $$MemoryCollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.memoryCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryAssignmentsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $MemoryAssignmentsTable> {
  $$MemoryAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MemoryRevisionsTableAnnotationComposer get revisionId {
    final $$MemoryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.memoryRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$MemoryCollectionsTableAnnotationComposer get collectionId {
    final $$MemoryCollectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.collectionId,
          referencedTable: $db.memoryCollections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryCollectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryCollections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MemoryAssignmentsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $MemoryAssignmentsTable,
          MemoryAssignmentRow,
          $$MemoryAssignmentsTableFilterComposer,
          $$MemoryAssignmentsTableOrderingComposer,
          $$MemoryAssignmentsTableAnnotationComposer,
          $$MemoryAssignmentsTableCreateCompanionBuilder,
          $$MemoryAssignmentsTableUpdateCompanionBuilder,
          (MemoryAssignmentRow, $$MemoryAssignmentsTableReferences),
          MemoryAssignmentRow,
          PrefetchHooks Function({
            bool revisionId,
            bool intentionId,
            bool collectionId,
          })
        > {
  $$MemoryAssignmentsTableTableManager(
    _$CyaDatabase db,
    $MemoryAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> revisionId = const Value.absent(),
                Value<int?> intentionId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryAssignmentsCompanion(
                id: id,
                revisionId: revisionId,
                intentionId: intentionId,
                collectionId: collectionId,
                kind: kind,
                context: context,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String revisionId,
                Value<int?> intentionId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                required String kind,
                required String context,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryAssignmentsCompanion.insert(
                id: id,
                revisionId: revisionId,
                intentionId: intentionId,
                collectionId: collectionId,
                kind: kind,
                context: context,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryAssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                revisionId = false,
                intentionId = false,
                collectionId = false,
              }) {
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
                        if (revisionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.revisionId,
                                    referencedTable:
                                        $$MemoryAssignmentsTableReferences
                                            ._revisionIdTable(db),
                                    referencedColumn:
                                        $$MemoryAssignmentsTableReferences
                                            ._revisionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (intentionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.intentionId,
                                    referencedTable:
                                        $$MemoryAssignmentsTableReferences
                                            ._intentionIdTable(db),
                                    referencedColumn:
                                        $$MemoryAssignmentsTableReferences
                                            ._intentionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable:
                                        $$MemoryAssignmentsTableReferences
                                            ._collectionIdTable(db),
                                    referencedColumn:
                                        $$MemoryAssignmentsTableReferences
                                            ._collectionIdTable(db)
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

typedef $$MemoryAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $MemoryAssignmentsTable,
      MemoryAssignmentRow,
      $$MemoryAssignmentsTableFilterComposer,
      $$MemoryAssignmentsTableOrderingComposer,
      $$MemoryAssignmentsTableAnnotationComposer,
      $$MemoryAssignmentsTableCreateCompanionBuilder,
      $$MemoryAssignmentsTableUpdateCompanionBuilder,
      (MemoryAssignmentRow, $$MemoryAssignmentsTableReferences),
      MemoryAssignmentRow,
      PrefetchHooks Function({
        bool revisionId,
        bool intentionId,
        bool collectionId,
      })
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      required String id,
      Value<int> currentRevision,
      Value<int> position,
      Value<bool> paused,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<String> id,
      Value<int> currentRevision,
      Value<int> position,
      Value<bool> paused,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$RoutinesTableReferences
    extends BaseReferences<_$CyaDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineRevisionsTable, List<RoutineRevisionRow>>
  _routineRevisionsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.routineRevisions,
    aliasName: 'routines__id__routine_revisions__routine_id',
  );

  $$RoutineRevisionsTableProcessedTableManager get routineRevisionsRefs {
    final manager = $$RoutineRevisionsTableTableManager(
      $_db,
      $_db.routineRevisions,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutineEventsTable, List<RoutineEventRow>>
  _routineEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.routineEvents,
    aliasName: 'routines__id__routine_events__routine_id',
  );

  $$RoutineEventsTableProcessedTableManager get routineEventsRefs {
    final manager = $$RoutineEventsTableTableManager(
      $_db,
      $_db.routineEvents,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RoutineOccurrencesTable,
    List<RoutineOccurrenceRow>
  >
  _routineOccurrencesRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineOccurrences,
        aliasName: 'routines__id__routine_occurrences__routine_id',
      );

  $$RoutineOccurrencesTableProcessedTableManager get routineOccurrencesRefs {
    final manager = $$RoutineOccurrencesTableTableManager(
      $_db,
      $_db.routineOccurrences,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$CyaDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentRevision => $composableBuilder(
    column: $table.currentRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineRevisionsRefs(
    Expression<bool> Function($$RoutineRevisionsTableFilterComposer f) f,
  ) {
    final $$RoutineRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineEventsRefs(
    Expression<bool> Function($$RoutineEventsTableFilterComposer f) f,
  ) {
    final $$RoutineEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineEvents,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineEventsTableFilterComposer(
            $db: $db,
            $table: $db.routineEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineOccurrencesRefs(
    Expression<bool> Function($$RoutineOccurrencesTableFilterComposer f) f,
  ) {
    final $$RoutineOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineOccurrences,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.routineOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$CyaDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentRevision => $composableBuilder(
    column: $table.currentRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$CyaDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentRevision => $composableBuilder(
    column: $table.currentRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> routineRevisionsRefs<T extends Object>(
    Expression<T> Function($$RoutineRevisionsTableAnnotationComposer a) f,
  ) {
    final $$RoutineRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineEventsRefs<T extends Object>(
    Expression<T> Function($$RoutineEventsTableAnnotationComposer a) f,
  ) {
    final $$RoutineEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineEvents,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineOccurrencesRefs<T extends Object>(
    Expression<T> Function($$RoutineOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$RoutineOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineOccurrences,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.routineOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableReferences),
          RoutineRow,
          PrefetchHooks Function({
            bool routineRevisionsRefs,
            bool routineEventsRefs,
            bool routineOccurrencesRefs,
          })
        > {
  $$RoutinesTableTableManager(_$CyaDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> currentRevision = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                currentRevision: currentRevision,
                position: position,
                paused: paused,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> currentRevision = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                currentRevision: currentRevision,
                position: position,
                paused: paused,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineRevisionsRefs = false,
                routineEventsRefs = false,
                routineOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineRevisionsRefs) db.routineRevisions,
                    if (routineEventsRefs) db.routineEvents,
                    if (routineOccurrencesRefs) db.routineOccurrences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineRevisionsRefs)
                        await $_getPrefetchedData<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineRevisionRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routineEventsRefs)
                        await $_getPrefetchedData<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routineOccurrencesRefs)
                        await $_getPrefetchedData<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineOccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
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

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableReferences),
      RoutineRow,
      PrefetchHooks Function({
        bool routineRevisionsRefs,
        bool routineEventsRefs,
        bool routineOccurrencesRefs,
      })
    >;
typedef $$RoutineRevisionsTableCreateCompanionBuilder =
    RoutineRevisionsCompanion Function({
      required String id,
      required String routineId,
      required int revision,
      required String title,
      Value<int?> weekdays,
      Value<int?> preferredStart,
      Value<int?> preferredEnd,
      Value<String> steps,
      Value<String?> fallback,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RoutineRevisionsTableUpdateCompanionBuilder =
    RoutineRevisionsCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<int> revision,
      Value<String> title,
      Value<int?> weekdays,
      Value<int?> preferredStart,
      Value<int?> preferredEnd,
      Value<String> steps,
      Value<String?> fallback,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$RoutineRevisionsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $RoutineRevisionsTable,
          RoutineRevisionRow
        > {
  $$RoutineRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$CyaDatabase db) =>
      db.routines.createAlias('routine_revisions__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineEventsTable, List<RoutineEventRow>>
  _routineEventsRefsTable(_$CyaDatabase db) => MultiTypedResultKey.fromTable(
    db.routineEvents,
    aliasName: 'routine_revisions__id__routine_events__revision_id',
  );

  $$RoutineEventsTableProcessedTableManager get routineEventsRefs {
    final manager = $$RoutineEventsTableTableManager(
      $_db,
      $_db.routineEvents,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RoutineOccurrencesTable,
    List<RoutineOccurrenceRow>
  >
  _routineOccurrencesRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineOccurrences,
        aliasName: 'routine_revisions__id__routine_occurrences__revision_id',
      );

  $$RoutineOccurrencesTableProcessedTableManager get routineOccurrencesRefs {
    final manager = $$RoutineOccurrencesTableTableManager(
      $_db,
      $_db.routineOccurrences,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineRevisionsTableFilterComposer
    extends Composer<_$CyaDatabase, $RoutineRevisionsTable> {
  $$RoutineRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredStart => $composableBuilder(
    column: $table.preferredStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredEnd => $composableBuilder(
    column: $table.preferredEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fallback => $composableBuilder(
    column: $table.fallback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineEventsRefs(
    Expression<bool> Function($$RoutineEventsTableFilterComposer f) f,
  ) {
    final $$RoutineEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineEvents,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineEventsTableFilterComposer(
            $db: $db,
            $table: $db.routineEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineOccurrencesRefs(
    Expression<bool> Function($$RoutineOccurrencesTableFilterComposer f) f,
  ) {
    final $$RoutineOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineOccurrences,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.routineOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineRevisionsTableOrderingComposer
    extends Composer<_$CyaDatabase, $RoutineRevisionsTable> {
  $$RoutineRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredStart => $composableBuilder(
    column: $table.preferredStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredEnd => $composableBuilder(
    column: $table.preferredEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fallback => $composableBuilder(
    column: $table.fallback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineRevisionsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $RoutineRevisionsTable> {
  $$RoutineRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<int> get preferredStart => $composableBuilder(
    column: $table.preferredStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferredEnd => $composableBuilder(
    column: $table.preferredEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get fallback =>
      $composableBuilder(column: $table.fallback, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineEventsRefs<T extends Object>(
    Expression<T> Function($$RoutineEventsTableAnnotationComposer a) f,
  ) {
    final $$RoutineEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineEvents,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineOccurrencesRefs<T extends Object>(
    Expression<T> Function($$RoutineOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$RoutineOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineOccurrences,
          getReferencedColumn: (t) => t.revisionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.routineOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineRevisionsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $RoutineRevisionsTable,
          RoutineRevisionRow,
          $$RoutineRevisionsTableFilterComposer,
          $$RoutineRevisionsTableOrderingComposer,
          $$RoutineRevisionsTableAnnotationComposer,
          $$RoutineRevisionsTableCreateCompanionBuilder,
          $$RoutineRevisionsTableUpdateCompanionBuilder,
          (RoutineRevisionRow, $$RoutineRevisionsTableReferences),
          RoutineRevisionRow,
          PrefetchHooks Function({
            bool routineId,
            bool routineEventsRefs,
            bool routineOccurrencesRefs,
          })
        > {
  $$RoutineRevisionsTableTableManager(
    _$CyaDatabase db,
    $RoutineRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> weekdays = const Value.absent(),
                Value<int?> preferredStart = const Value.absent(),
                Value<int?> preferredEnd = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<String?> fallback = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineRevisionsCompanion(
                id: id,
                routineId: routineId,
                revision: revision,
                title: title,
                weekdays: weekdays,
                preferredStart: preferredStart,
                preferredEnd: preferredEnd,
                steps: steps,
                fallback: fallback,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                required int revision,
                required String title,
                Value<int?> weekdays = const Value.absent(),
                Value<int?> preferredStart = const Value.absent(),
                Value<int?> preferredEnd = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<String?> fallback = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineRevisionsCompanion.insert(
                id: id,
                routineId: routineId,
                revision: revision,
                title: title,
                weekdays: weekdays,
                preferredStart: preferredStart,
                preferredEnd: preferredEnd,
                steps: steps,
                fallback: fallback,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineId = false,
                routineEventsRefs = false,
                routineOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineEventsRefs) db.routineEvents,
                    if (routineOccurrencesRefs) db.routineOccurrences,
                  ],
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
                        if (routineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routineId,
                                    referencedTable:
                                        $$RoutineRevisionsTableReferences
                                            ._routineIdTable(db),
                                    referencedColumn:
                                        $$RoutineRevisionsTableReferences
                                            ._routineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineEventsRefs)
                        await $_getPrefetchedData<
                          RoutineRevisionRow,
                          $RoutineRevisionsTable,
                          RoutineEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineRevisionsTableReferences
                              ._routineEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).routineEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routineOccurrencesRefs)
                        await $_getPrefetchedData<
                          RoutineRevisionRow,
                          $RoutineRevisionsTable,
                          RoutineOccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineRevisionsTableReferences
                              ._routineOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).routineOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
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

typedef $$RoutineRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $RoutineRevisionsTable,
      RoutineRevisionRow,
      $$RoutineRevisionsTableFilterComposer,
      $$RoutineRevisionsTableOrderingComposer,
      $$RoutineRevisionsTableAnnotationComposer,
      $$RoutineRevisionsTableCreateCompanionBuilder,
      $$RoutineRevisionsTableUpdateCompanionBuilder,
      (RoutineRevisionRow, $$RoutineRevisionsTableReferences),
      RoutineRevisionRow,
      PrefetchHooks Function({
        bool routineId,
        bool routineEventsRefs,
        bool routineOccurrencesRefs,
      })
    >;
typedef $$RoutineEventsTableCreateCompanionBuilder =
    RoutineEventsCompanion Function({
      Value<int> id,
      required String routineId,
      Value<String?> revisionId,
      required String type,
      required DateTime occurredAt,
      Value<String?> metadata,
    });
typedef $$RoutineEventsTableUpdateCompanionBuilder =
    RoutineEventsCompanion Function({
      Value<int> id,
      Value<String> routineId,
      Value<String?> revisionId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String?> metadata,
    });

final class $$RoutineEventsTableReferences
    extends
        BaseReferences<_$CyaDatabase, $RoutineEventsTable, RoutineEventRow> {
  $$RoutineEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$CyaDatabase db) =>
      db.routines.createAlias('routine_events__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutineRevisionsTable _revisionIdTable(_$CyaDatabase db) => db
      .routineRevisions
      .createAlias('routine_events__revision_id__routine_revisions__id');

  $$RoutineRevisionsTableProcessedTableManager? get revisionId {
    final $_column = $_itemColumn<String>('revision_id');
    if ($_column == null) return null;
    final manager = $$RoutineRevisionsTableTableManager(
      $_db,
      $_db.routineRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineEventsTableFilterComposer
    extends Composer<_$CyaDatabase, $RoutineEventsTable> {
  $$RoutineEventsTableFilterComposer({
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

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineRevisionsTableFilterComposer get revisionId {
    final $$RoutineRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineEventsTableOrderingComposer
    extends Composer<_$CyaDatabase, $RoutineEventsTable> {
  $$RoutineEventsTableOrderingComposer({
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

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineRevisionsTableOrderingComposer get revisionId {
    final $$RoutineRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineEventsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $RoutineEventsTable> {
  $$RoutineEventsTableAnnotationComposer({
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

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineRevisionsTableAnnotationComposer get revisionId {
    final $$RoutineRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineEventsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $RoutineEventsTable,
          RoutineEventRow,
          $$RoutineEventsTableFilterComposer,
          $$RoutineEventsTableOrderingComposer,
          $$RoutineEventsTableAnnotationComposer,
          $$RoutineEventsTableCreateCompanionBuilder,
          $$RoutineEventsTableUpdateCompanionBuilder,
          (RoutineEventRow, $$RoutineEventsTableReferences),
          RoutineEventRow,
          PrefetchHooks Function({bool routineId, bool revisionId})
        > {
  $$RoutineEventsTableTableManager(_$CyaDatabase db, $RoutineEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String?> revisionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
              }) => RoutineEventsCompanion(
                id: id,
                routineId: routineId,
                revisionId: revisionId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String routineId,
                Value<String?> revisionId = const Value.absent(),
                required String type,
                required DateTime occurredAt,
                Value<String?> metadata = const Value.absent(),
              }) => RoutineEventsCompanion.insert(
                id: id,
                routineId: routineId,
                revisionId: revisionId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false, revisionId = false}) {
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
                    if (routineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routineId,
                                referencedTable: $$RoutineEventsTableReferences
                                    ._routineIdTable(db),
                                referencedColumn: $$RoutineEventsTableReferences
                                    ._routineIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (revisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.revisionId,
                                referencedTable: $$RoutineEventsTableReferences
                                    ._revisionIdTable(db),
                                referencedColumn: $$RoutineEventsTableReferences
                                    ._revisionIdTable(db)
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

typedef $$RoutineEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $RoutineEventsTable,
      RoutineEventRow,
      $$RoutineEventsTableFilterComposer,
      $$RoutineEventsTableOrderingComposer,
      $$RoutineEventsTableAnnotationComposer,
      $$RoutineEventsTableCreateCompanionBuilder,
      $$RoutineEventsTableUpdateCompanionBuilder,
      (RoutineEventRow, $$RoutineEventsTableReferences),
      RoutineEventRow,
      PrefetchHooks Function({bool routineId, bool revisionId})
    >;
typedef $$RoutineOccurrencesTableCreateCompanionBuilder =
    RoutineOccurrencesCompanion Function({
      required String id,
      Value<int> changeVersion,
      required String routineId,
      required String revisionId,
      required String selectedDay,
      required String targetDay,
      Value<String> state,
      Value<int> position,
      required String steps,
      Value<int?> preferredStart,
      Value<int?> preferredEnd,
      required DateTime selectedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RoutineOccurrencesTableUpdateCompanionBuilder =
    RoutineOccurrencesCompanion Function({
      Value<String> id,
      Value<int> changeVersion,
      Value<String> routineId,
      Value<String> revisionId,
      Value<String> selectedDay,
      Value<String> targetDay,
      Value<String> state,
      Value<int> position,
      Value<String> steps,
      Value<int?> preferredStart,
      Value<int?> preferredEnd,
      Value<DateTime> selectedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$RoutineOccurrencesTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $RoutineOccurrencesTable,
          RoutineOccurrenceRow
        > {
  $$RoutineOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$CyaDatabase db) =>
      db.routines.createAlias('routine_occurrences__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutineRevisionsTable _revisionIdTable(_$CyaDatabase db) => db
      .routineRevisions
      .createAlias('routine_occurrences__revision_id__routine_revisions__id');

  $$RoutineRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<String>('revision_id')!;

    final manager = $$RoutineRevisionsTableTableManager(
      $_db,
      $_db.routineRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $RoutineOccurrenceEventsTable,
    List<RoutineOccurrenceEventRow>
  >
  _routineOccurrenceEventsRefsTable(_$CyaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineOccurrenceEvents,
        aliasName:
            'routine_occurrences__id__routine_occurrence_events__occurrence_id',
      );

  $$RoutineOccurrenceEventsTableProcessedTableManager
  get routineOccurrenceEventsRefs {
    final manager = $$RoutineOccurrenceEventsTableTableManager(
      $_db,
      $_db.routineOccurrenceEvents,
    ).filter((f) => f.occurrenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineOccurrenceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineOccurrencesTableFilterComposer
    extends Composer<_$CyaDatabase, $RoutineOccurrencesTable> {
  $$RoutineOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeVersion => $composableBuilder(
    column: $table.changeVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedDay => $composableBuilder(
    column: $table.selectedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDay => $composableBuilder(
    column: $table.targetDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredStart => $composableBuilder(
    column: $table.preferredStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredEnd => $composableBuilder(
    column: $table.preferredEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineRevisionsTableFilterComposer get revisionId {
    final $$RoutineRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineOccurrenceEventsRefs(
    Expression<bool> Function($$RoutineOccurrenceEventsTableFilterComposer f) f,
  ) {
    final $$RoutineOccurrenceEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineOccurrenceEvents,
          getReferencedColumn: (t) => t.occurrenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineOccurrenceEventsTableFilterComposer(
                $db: $db,
                $table: $db.routineOccurrenceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineOccurrencesTableOrderingComposer
    extends Composer<_$CyaDatabase, $RoutineOccurrencesTable> {
  $$RoutineOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeVersion => $composableBuilder(
    column: $table.changeVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedDay => $composableBuilder(
    column: $table.selectedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDay => $composableBuilder(
    column: $table.targetDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredStart => $composableBuilder(
    column: $table.preferredStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredEnd => $composableBuilder(
    column: $table.preferredEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineRevisionsTableOrderingComposer get revisionId {
    final $$RoutineRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineOccurrencesTableAnnotationComposer
    extends Composer<_$CyaDatabase, $RoutineOccurrencesTable> {
  $$RoutineOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get changeVersion => $composableBuilder(
    column: $table.changeVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedDay => $composableBuilder(
    column: $table.selectedDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetDay =>
      $composableBuilder(column: $table.targetDay, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get preferredStart => $composableBuilder(
    column: $table.preferredStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferredEnd => $composableBuilder(
    column: $table.preferredEnd,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineRevisionsTableAnnotationComposer get revisionId {
    final $$RoutineRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.routineRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineOccurrenceEventsRefs<T extends Object>(
    Expression<T> Function($$RoutineOccurrenceEventsTableAnnotationComposer a)
    f,
  ) {
    final $$RoutineOccurrenceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineOccurrenceEvents,
          getReferencedColumn: (t) => t.occurrenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineOccurrenceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.routineOccurrenceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineOccurrencesTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $RoutineOccurrencesTable,
          RoutineOccurrenceRow,
          $$RoutineOccurrencesTableFilterComposer,
          $$RoutineOccurrencesTableOrderingComposer,
          $$RoutineOccurrencesTableAnnotationComposer,
          $$RoutineOccurrencesTableCreateCompanionBuilder,
          $$RoutineOccurrencesTableUpdateCompanionBuilder,
          (RoutineOccurrenceRow, $$RoutineOccurrencesTableReferences),
          RoutineOccurrenceRow,
          PrefetchHooks Function({
            bool routineId,
            bool revisionId,
            bool routineOccurrenceEventsRefs,
          })
        > {
  $$RoutineOccurrencesTableTableManager(
    _$CyaDatabase db,
    $RoutineOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> changeVersion = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> revisionId = const Value.absent(),
                Value<String> selectedDay = const Value.absent(),
                Value<String> targetDay = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<int?> preferredStart = const Value.absent(),
                Value<int?> preferredEnd = const Value.absent(),
                Value<DateTime> selectedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineOccurrencesCompanion(
                id: id,
                changeVersion: changeVersion,
                routineId: routineId,
                revisionId: revisionId,
                selectedDay: selectedDay,
                targetDay: targetDay,
                state: state,
                position: position,
                steps: steps,
                preferredStart: preferredStart,
                preferredEnd: preferredEnd,
                selectedAt: selectedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> changeVersion = const Value.absent(),
                required String routineId,
                required String revisionId,
                required String selectedDay,
                required String targetDay,
                Value<String> state = const Value.absent(),
                Value<int> position = const Value.absent(),
                required String steps,
                Value<int?> preferredStart = const Value.absent(),
                Value<int?> preferredEnd = const Value.absent(),
                required DateTime selectedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineOccurrencesCompanion.insert(
                id: id,
                changeVersion: changeVersion,
                routineId: routineId,
                revisionId: revisionId,
                selectedDay: selectedDay,
                targetDay: targetDay,
                state: state,
                position: position,
                steps: steps,
                preferredStart: preferredStart,
                preferredEnd: preferredEnd,
                selectedAt: selectedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineId = false,
                revisionId = false,
                routineOccurrenceEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineOccurrenceEventsRefs) db.routineOccurrenceEvents,
                  ],
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
                        if (routineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routineId,
                                    referencedTable:
                                        $$RoutineOccurrencesTableReferences
                                            ._routineIdTable(db),
                                    referencedColumn:
                                        $$RoutineOccurrencesTableReferences
                                            ._routineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (revisionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.revisionId,
                                    referencedTable:
                                        $$RoutineOccurrencesTableReferences
                                            ._revisionIdTable(db),
                                    referencedColumn:
                                        $$RoutineOccurrencesTableReferences
                                            ._revisionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineOccurrenceEventsRefs)
                        await $_getPrefetchedData<
                          RoutineOccurrenceRow,
                          $RoutineOccurrencesTable,
                          RoutineOccurrenceEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineOccurrencesTableReferences
                              ._routineOccurrenceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineOccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineOccurrenceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.occurrenceId == item.id,
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

typedef $$RoutineOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $RoutineOccurrencesTable,
      RoutineOccurrenceRow,
      $$RoutineOccurrencesTableFilterComposer,
      $$RoutineOccurrencesTableOrderingComposer,
      $$RoutineOccurrencesTableAnnotationComposer,
      $$RoutineOccurrencesTableCreateCompanionBuilder,
      $$RoutineOccurrencesTableUpdateCompanionBuilder,
      (RoutineOccurrenceRow, $$RoutineOccurrencesTableReferences),
      RoutineOccurrenceRow,
      PrefetchHooks Function({
        bool routineId,
        bool revisionId,
        bool routineOccurrenceEventsRefs,
      })
    >;
typedef $$RoutineOccurrenceEventsTableCreateCompanionBuilder =
    RoutineOccurrenceEventsCompanion Function({
      Value<int> id,
      required String occurrenceId,
      required String type,
      required DateTime occurredAt,
      required String metadata,
    });
typedef $$RoutineOccurrenceEventsTableUpdateCompanionBuilder =
    RoutineOccurrenceEventsCompanion Function({
      Value<int> id,
      Value<String> occurrenceId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String> metadata,
    });

final class $$RoutineOccurrenceEventsTableReferences
    extends
        BaseReferences<
          _$CyaDatabase,
          $RoutineOccurrenceEventsTable,
          RoutineOccurrenceEventRow
        > {
  $$RoutineOccurrenceEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineOccurrencesTable _occurrenceIdTable(_$CyaDatabase db) =>
      db.routineOccurrences.createAlias(
        'routine_occurrence_events__occurrence_id__routine_occurrences__id',
      );

  $$RoutineOccurrencesTableProcessedTableManager get occurrenceId {
    final $_column = $_itemColumn<String>('occurrence_id')!;

    final manager = $$RoutineOccurrencesTableTableManager(
      $_db,
      $_db.routineOccurrences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_occurrenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineOccurrenceEventsTableFilterComposer
    extends Composer<_$CyaDatabase, $RoutineOccurrenceEventsTable> {
  $$RoutineOccurrenceEventsTableFilterComposer({
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

  $$RoutineOccurrencesTableFilterComposer get occurrenceId {
    final $$RoutineOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.routineOccurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.routineOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineOccurrenceEventsTableOrderingComposer
    extends Composer<_$CyaDatabase, $RoutineOccurrenceEventsTable> {
  $$RoutineOccurrenceEventsTableOrderingComposer({
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

  $$RoutineOccurrencesTableOrderingComposer get occurrenceId {
    final $$RoutineOccurrencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.routineOccurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineOccurrencesTableOrderingComposer(
            $db: $db,
            $table: $db.routineOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineOccurrenceEventsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $RoutineOccurrenceEventsTable> {
  $$RoutineOccurrenceEventsTableAnnotationComposer({
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

  $$RoutineOccurrencesTableAnnotationComposer get occurrenceId {
    final $$RoutineOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.occurrenceId,
          referencedTable: $db.routineOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.routineOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RoutineOccurrenceEventsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $RoutineOccurrenceEventsTable,
          RoutineOccurrenceEventRow,
          $$RoutineOccurrenceEventsTableFilterComposer,
          $$RoutineOccurrenceEventsTableOrderingComposer,
          $$RoutineOccurrenceEventsTableAnnotationComposer,
          $$RoutineOccurrenceEventsTableCreateCompanionBuilder,
          $$RoutineOccurrenceEventsTableUpdateCompanionBuilder,
          (RoutineOccurrenceEventRow, $$RoutineOccurrenceEventsTableReferences),
          RoutineOccurrenceEventRow,
          PrefetchHooks Function({bool occurrenceId})
        > {
  $$RoutineOccurrenceEventsTableTableManager(
    _$CyaDatabase db,
    $RoutineOccurrenceEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineOccurrenceEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RoutineOccurrenceEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoutineOccurrenceEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> occurrenceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
              }) => RoutineOccurrenceEventsCompanion(
                id: id,
                occurrenceId: occurrenceId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String occurrenceId,
                required String type,
                required DateTime occurredAt,
                required String metadata,
              }) => RoutineOccurrenceEventsCompanion.insert(
                id: id,
                occurrenceId: occurrenceId,
                type: type,
                occurredAt: occurredAt,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineOccurrenceEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({occurrenceId = false}) {
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
                    if (occurrenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.occurrenceId,
                                referencedTable:
                                    $$RoutineOccurrenceEventsTableReferences
                                        ._occurrenceIdTable(db),
                                referencedColumn:
                                    $$RoutineOccurrenceEventsTableReferences
                                        ._occurrenceIdTable(db)
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

typedef $$RoutineOccurrenceEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $RoutineOccurrenceEventsTable,
      RoutineOccurrenceEventRow,
      $$RoutineOccurrenceEventsTableFilterComposer,
      $$RoutineOccurrenceEventsTableOrderingComposer,
      $$RoutineOccurrenceEventsTableAnnotationComposer,
      $$RoutineOccurrenceEventsTableCreateCompanionBuilder,
      $$RoutineOccurrenceEventsTableUpdateCompanionBuilder,
      (RoutineOccurrenceEventRow, $$RoutineOccurrenceEventsTableReferences),
      RoutineOccurrenceEventRow,
      PrefetchHooks Function({bool occurrenceId})
    >;
typedef $$LocalReviewsTableCreateCompanionBuilder =
    LocalReviewsCompanion Function({
      required String id,
      Value<String> origin,
      required String dayKey,
      required String period,
      required String memoryId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalReviewsTableUpdateCompanionBuilder =
    LocalReviewsCompanion Function({
      Value<String> id,
      Value<String> origin,
      Value<String> dayKey,
      Value<String> period,
      Value<String> memoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$LocalReviewsTableReferences
    extends BaseReferences<_$CyaDatabase, $LocalReviewsTable, LocalReviewRow> {
  $$LocalReviewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoriesTable _memoryIdTable(_$CyaDatabase db) =>
      db.memories.createAlias('local_reviews__memory_id__memories__id');

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager(
      $_db,
      $_db.memories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalReviewsTableFilterComposer
    extends Composer<_$CyaDatabase, $LocalReviewsTable> {
  $$LocalReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableFilterComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalReviewsTableOrderingComposer
    extends Composer<_$CyaDatabase, $LocalReviewsTable> {
  $$LocalReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableOrderingComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalReviewsTableAnnotationComposer
    extends Composer<_$CyaDatabase, $LocalReviewsTable> {
  $$LocalReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.memories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalReviewsTableTableManager
    extends
        RootTableManager<
          _$CyaDatabase,
          $LocalReviewsTable,
          LocalReviewRow,
          $$LocalReviewsTableFilterComposer,
          $$LocalReviewsTableOrderingComposer,
          $$LocalReviewsTableAnnotationComposer,
          $$LocalReviewsTableCreateCompanionBuilder,
          $$LocalReviewsTableUpdateCompanionBuilder,
          (LocalReviewRow, $$LocalReviewsTableReferences),
          LocalReviewRow,
          PrefetchHooks Function({bool memoryId})
        > {
  $$LocalReviewsTableTableManager(_$CyaDatabase db, $LocalReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalReviewsCompanion(
                id: id,
                origin: origin,
                dayKey: dayKey,
                period: period,
                memoryId: memoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> origin = const Value.absent(),
                required String dayKey,
                required String period,
                required String memoryId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalReviewsCompanion.insert(
                id: id,
                origin: origin,
                dayKey: dayKey,
                period: period,
                memoryId: memoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoryId = false}) {
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
                    if (memoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memoryId,
                                referencedTable: $$LocalReviewsTableReferences
                                    ._memoryIdTable(db),
                                referencedColumn: $$LocalReviewsTableReferences
                                    ._memoryIdTable(db)
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

typedef $$LocalReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$CyaDatabase,
      $LocalReviewsTable,
      LocalReviewRow,
      $$LocalReviewsTableFilterComposer,
      $$LocalReviewsTableOrderingComposer,
      $$LocalReviewsTableAnnotationComposer,
      $$LocalReviewsTableCreateCompanionBuilder,
      $$LocalReviewsTableUpdateCompanionBuilder,
      (LocalReviewRow, $$LocalReviewsTableReferences),
      LocalReviewRow,
      PrefetchHooks Function({bool memoryId})
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
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$MemoryRevisionsTableTableManager get memoryRevisions =>
      $$MemoryRevisionsTableTableManager(_db, _db.memoryRevisions);
  $$MemoryEventsTableTableManager get memoryEvents =>
      $$MemoryEventsTableTableManager(_db, _db.memoryEvents);
  $$MemoryJobsTableTableManager get memoryJobs =>
      $$MemoryJobsTableTableManager(_db, _db.memoryJobs);
  $$MemoryVectorsTableTableManager get memoryVectors =>
      $$MemoryVectorsTableTableManager(_db, _db.memoryVectors);
  $$MemoryLinksTableTableManager get memoryLinks =>
      $$MemoryLinksTableTableManager(_db, _db.memoryLinks);
  $$MemoryAttachmentsTableTableManager get memoryAttachments =>
      $$MemoryAttachmentsTableTableManager(_db, _db.memoryAttachments);
  $$AttachmentCleanupTableTableManager get attachmentCleanup =>
      $$AttachmentCleanupTableTableManager(_db, _db.attachmentCleanup);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$FocusEventsTableTableManager get focusEvents =>
      $$FocusEventsTableTableManager(_db, _db.focusEvents);
  $$MemoryCollectionsTableTableManager get memoryCollections =>
      $$MemoryCollectionsTableTableManager(_db, _db.memoryCollections);
  $$CollectionEventsTableTableManager get collectionEvents =>
      $$CollectionEventsTableTableManager(_db, _db.collectionEvents);
  $$MemoryAssignmentsTableTableManager get memoryAssignments =>
      $$MemoryAssignmentsTableTableManager(_db, _db.memoryAssignments);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineRevisionsTableTableManager get routineRevisions =>
      $$RoutineRevisionsTableTableManager(_db, _db.routineRevisions);
  $$RoutineEventsTableTableManager get routineEvents =>
      $$RoutineEventsTableTableManager(_db, _db.routineEvents);
  $$RoutineOccurrencesTableTableManager get routineOccurrences =>
      $$RoutineOccurrencesTableTableManager(_db, _db.routineOccurrences);
  $$RoutineOccurrenceEventsTableTableManager get routineOccurrenceEvents =>
      $$RoutineOccurrenceEventsTableTableManager(
        _db,
        _db.routineOccurrenceEvents,
      );
  $$LocalReviewsTableTableManager get localReviews =>
      $$LocalReviewsTableTableManager(_db, _db.localReviews);
}
