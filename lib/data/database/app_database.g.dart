// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prefsMeta = const VerificationMeta('prefs');
  @override
  late final GeneratedColumn<String> prefs = GeneratedColumn<String>(
    'prefs',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consentOnlineMeta = const VerificationMeta(
    'consentOnline',
  );
  @override
  late final GeneratedColumn<bool> consentOnline = GeneratedColumn<bool>(
    'consent_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("consent_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    createdAt,
    prefs,
    consentOnline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('prefs')) {
      context.handle(
        _prefsMeta,
        prefs.isAcceptableOrUnknown(data['prefs']!, _prefsMeta),
      );
    }
    if (data.containsKey('consent_online')) {
      context.handle(
        _consentOnlineMeta,
        consentOnline.isAcceptableOrUnknown(
          data['consent_online']!,
          _consentOnlineMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      prefs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prefs'],
      ),
      consentOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}consent_online'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String deviceId;
  final int createdAt;
  final String? prefs;
  final bool consentOnline;
  const User({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    this.prefs,
    required this.consentOnline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || prefs != null) {
      map['prefs'] = Variable<String>(prefs);
    }
    map['consent_online'] = Variable<bool>(consentOnline);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      prefs: prefs == null && nullToAbsent
          ? const Value.absent()
          : Value(prefs),
      consentOnline: Value(consentOnline),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      prefs: serializer.fromJson<String?>(json['prefs']),
      consentOnline: serializer.fromJson<bool>(json['consentOnline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
      'prefs': serializer.toJson<String?>(prefs),
      'consentOnline': serializer.toJson<bool>(consentOnline),
    };
  }

  User copyWith({
    String? id,
    String? deviceId,
    int? createdAt,
    Value<String?> prefs = const Value.absent(),
    bool? consentOnline,
  }) => User(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    prefs: prefs.present ? prefs.value : this.prefs,
    consentOnline: consentOnline ?? this.consentOnline,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      prefs: data.prefs.present ? data.prefs.value : this.prefs,
      consentOnline: data.consentOnline.present
          ? data.consentOnline.value
          : this.consentOnline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('prefs: $prefs, ')
          ..write('consentOnline: $consentOnline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, createdAt, prefs, consentOnline);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.prefs == this.prefs &&
          other.consentOnline == this.consentOnline);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<int> createdAt;
  final Value<String?> prefs;
  final Value<bool> consentOnline;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.prefs = const Value.absent(),
    this.consentOnline = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String deviceId,
    required int createdAt,
    this.prefs = const Value.absent(),
    this.consentOnline = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<String>? prefs,
    Expression<bool>? consentOnline,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (prefs != null) 'prefs': prefs,
      if (consentOnline != null) 'consent_online': consentOnline,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<int>? createdAt,
    Value<String?>? prefs,
    Value<bool>? consentOnline,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      prefs: prefs ?? this.prefs,
      consentOnline: consentOnline ?? this.consentOnline,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (prefs.present) {
      map['prefs'] = Variable<String>(prefs.value);
    }
    if (consentOnline.present) {
      map['consent_online'] = Variable<bool>(consentOnline.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('prefs: $prefs, ')
          ..write('consentOnline: $consentOnline, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentItemsTable extends ContentItems
    with TableInfo<$ContentItemsTable, ContentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyLevelMeta = const VerificationMeta(
    'difficultyLevel',
  );
  @override
  late final GeneratedColumn<int> difficultyLevel = GeneratedColumn<int>(
    'difficulty_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _topicTagsMeta = const VerificationMeta(
    'topicTags',
  );
  @override
  late final GeneratedColumn<String> topicTags = GeneratedColumn<String>(
    'topic_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    filePath,
    difficultyLevel,
    topicTags,
    subject,
    language,
    fileSize,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentItem> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
        _difficultyLevelMeta,
        difficultyLevel.isAcceptableOrUnknown(
          data['difficulty_level']!,
          _difficultyLevelMeta,
        ),
      );
    }
    if (data.containsKey('topic_tags')) {
      context.handle(
        _topicTagsMeta,
        topicTags.isAcceptableOrUnknown(data['topic_tags']!, _topicTagsMeta),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      difficultyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_level'],
      )!,
      topicTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_tags'],
      ),
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $ContentItemsTable createAlias(String alias) {
    return $ContentItemsTable(attachedDatabase, alias);
  }
}

class ContentItem extends DataClass implements Insertable<ContentItem> {
  final String id;
  final String title;
  final String type;
  final String filePath;
  final int difficultyLevel;
  final String? topicTags;
  final String? subject;
  final String language;
  final int? fileSize;
  final int addedAt;
  const ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.filePath,
    required this.difficultyLevel,
    this.topicTags,
    this.subject,
    required this.language,
    this.fileSize,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['file_path'] = Variable<String>(filePath);
    map['difficulty_level'] = Variable<int>(difficultyLevel);
    if (!nullToAbsent || topicTags != null) {
      map['topic_tags'] = Variable<String>(topicTags);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  ContentItemsCompanion toCompanion(bool nullToAbsent) {
    return ContentItemsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      filePath: Value(filePath),
      difficultyLevel: Value(difficultyLevel),
      topicTags: topicTags == null && nullToAbsent
          ? const Value.absent()
          : Value(topicTags),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      language: Value(language),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      addedAt: Value(addedAt),
    );
  }

  factory ContentItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentItem(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String>(json['filePath']),
      difficultyLevel: serializer.fromJson<int>(json['difficultyLevel']),
      topicTags: serializer.fromJson<String?>(json['topicTags']),
      subject: serializer.fromJson<String?>(json['subject']),
      language: serializer.fromJson<String>(json['language']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String>(filePath),
      'difficultyLevel': serializer.toJson<int>(difficultyLevel),
      'topicTags': serializer.toJson<String?>(topicTags),
      'subject': serializer.toJson<String?>(subject),
      'language': serializer.toJson<String>(language),
      'fileSize': serializer.toJson<int?>(fileSize),
      'addedAt': serializer.toJson<int>(addedAt),
    };
  }

  ContentItem copyWith({
    String? id,
    String? title,
    String? type,
    String? filePath,
    int? difficultyLevel,
    Value<String?> topicTags = const Value.absent(),
    Value<String?> subject = const Value.absent(),
    String? language,
    Value<int?> fileSize = const Value.absent(),
    int? addedAt,
  }) => ContentItem(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    filePath: filePath ?? this.filePath,
    difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    topicTags: topicTags.present ? topicTags.value : this.topicTags,
    subject: subject.present ? subject.value : this.subject,
    language: language ?? this.language,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    addedAt: addedAt ?? this.addedAt,
  );
  ContentItem copyWithCompanion(ContentItemsCompanion data) {
    return ContentItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      topicTags: data.topicTags.present ? data.topicTags.value : this.topicTags,
      subject: data.subject.present ? data.subject.value : this.subject,
      language: data.language.present ? data.language.value : this.language,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('topicTags: $topicTags, ')
          ..write('subject: $subject, ')
          ..write('language: $language, ')
          ..write('fileSize: $fileSize, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    filePath,
    difficultyLevel,
    topicTags,
    subject,
    language,
    fileSize,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.difficultyLevel == this.difficultyLevel &&
          other.topicTags == this.topicTags &&
          other.subject == this.subject &&
          other.language == this.language &&
          other.fileSize == this.fileSize &&
          other.addedAt == this.addedAt);
}

class ContentItemsCompanion extends UpdateCompanion<ContentItem> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> type;
  final Value<String> filePath;
  final Value<int> difficultyLevel;
  final Value<String?> topicTags;
  final Value<String?> subject;
  final Value<String> language;
  final Value<int?> fileSize;
  final Value<int> addedAt;
  final Value<int> rowid;
  const ContentItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.topicTags = const Value.absent(),
    this.subject = const Value.absent(),
    this.language = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentItemsCompanion.insert({
    required String id,
    required String title,
    required String type,
    required String filePath,
    this.difficultyLevel = const Value.absent(),
    this.topicTags = const Value.absent(),
    this.subject = const Value.absent(),
    this.language = const Value.absent(),
    this.fileSize = const Value.absent(),
    required int addedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       filePath = Value(filePath),
       addedAt = Value(addedAt);
  static Insertable<ContentItem> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<int>? difficultyLevel,
    Expression<String>? topicTags,
    Expression<String>? subject,
    Expression<String>? language,
    Expression<int>? fileSize,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (topicTags != null) 'topic_tags': topicTags,
      if (subject != null) 'subject': subject,
      if (language != null) 'language': language,
      if (fileSize != null) 'file_size': fileSize,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? type,
    Value<String>? filePath,
    Value<int>? difficultyLevel,
    Value<String?>? topicTags,
    Value<String?>? subject,
    Value<String>? language,
    Value<int?>? fileSize,
    Value<int>? addedAt,
    Value<int>? rowid,
  }) {
    return ContentItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      topicTags: topicTags ?? this.topicTags,
      subject: subject ?? this.subject,
      language: language ?? this.language,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<int>(difficultyLevel.value);
    }
    if (topicTags.present) {
      map['topic_tags'] = Variable<String>(topicTags.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('topicTags: $topicTags, ')
          ..write('subject: $subject, ')
          ..write('language: $language, ')
          ..write('fileSize: $fileSize, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptsTable extends Transcripts
    with TableInfo<$TranscriptsTable, Transcript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textChunkMeta = const VerificationMeta(
    'textChunk',
  );
  @override
  late final GeneratedColumn<String> textChunk = GeneratedColumn<String>(
    'text_chunk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<double> startTime = GeneratedColumn<double>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<double> endTime = GeneratedColumn<double>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    videoId,
    textChunk,
    startTime,
    endTime,
    language,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transcript> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('text_chunk')) {
      context.handle(
        _textChunkMeta,
        textChunk.isAcceptableOrUnknown(data['text_chunk']!, _textChunkMeta),
      );
    } else if (isInserting) {
      context.missing(_textChunkMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transcript map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transcript(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      textChunk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_chunk'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_time'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
    );
  }

  @override
  $TranscriptsTable createAlias(String alias) {
    return $TranscriptsTable(attachedDatabase, alias);
  }
}

class Transcript extends DataClass implements Insertable<Transcript> {
  final String id;
  final String videoId;
  final String textChunk;
  final double startTime;
  final double endTime;
  final String language;
  const Transcript({
    required this.id,
    required this.videoId,
    required this.textChunk,
    required this.startTime,
    required this.endTime,
    required this.language,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['video_id'] = Variable<String>(videoId);
    map['text_chunk'] = Variable<String>(textChunk);
    map['start_time'] = Variable<double>(startTime);
    map['end_time'] = Variable<double>(endTime);
    map['language'] = Variable<String>(language);
    return map;
  }

  TranscriptsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptsCompanion(
      id: Value(id),
      videoId: Value(videoId),
      textChunk: Value(textChunk),
      startTime: Value(startTime),
      endTime: Value(endTime),
      language: Value(language),
    );
  }

  factory Transcript.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transcript(
      id: serializer.fromJson<String>(json['id']),
      videoId: serializer.fromJson<String>(json['videoId']),
      textChunk: serializer.fromJson<String>(json['textChunk']),
      startTime: serializer.fromJson<double>(json['startTime']),
      endTime: serializer.fromJson<double>(json['endTime']),
      language: serializer.fromJson<String>(json['language']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'videoId': serializer.toJson<String>(videoId),
      'textChunk': serializer.toJson<String>(textChunk),
      'startTime': serializer.toJson<double>(startTime),
      'endTime': serializer.toJson<double>(endTime),
      'language': serializer.toJson<String>(language),
    };
  }

  Transcript copyWith({
    String? id,
    String? videoId,
    String? textChunk,
    double? startTime,
    double? endTime,
    String? language,
  }) => Transcript(
    id: id ?? this.id,
    videoId: videoId ?? this.videoId,
    textChunk: textChunk ?? this.textChunk,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    language: language ?? this.language,
  );
  Transcript copyWithCompanion(TranscriptsCompanion data) {
    return Transcript(
      id: data.id.present ? data.id.value : this.id,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      textChunk: data.textChunk.present ? data.textChunk.value : this.textChunk,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      language: data.language.present ? data.language.value : this.language,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transcript(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('textChunk: $textChunk, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, videoId, textChunk, startTime, endTime, language);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transcript &&
          other.id == this.id &&
          other.videoId == this.videoId &&
          other.textChunk == this.textChunk &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.language == this.language);
}

class TranscriptsCompanion extends UpdateCompanion<Transcript> {
  final Value<String> id;
  final Value<String> videoId;
  final Value<String> textChunk;
  final Value<double> startTime;
  final Value<double> endTime;
  final Value<String> language;
  final Value<int> rowid;
  const TranscriptsCompanion({
    this.id = const Value.absent(),
    this.videoId = const Value.absent(),
    this.textChunk = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptsCompanion.insert({
    required String id,
    required String videoId,
    required String textChunk,
    required double startTime,
    required double endTime,
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       videoId = Value(videoId),
       textChunk = Value(textChunk),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<Transcript> custom({
    Expression<String>? id,
    Expression<String>? videoId,
    Expression<String>? textChunk,
    Expression<double>? startTime,
    Expression<double>? endTime,
    Expression<String>? language,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoId != null) 'video_id': videoId,
      if (textChunk != null) 'text_chunk': textChunk,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (language != null) 'language': language,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptsCompanion copyWith({
    Value<String>? id,
    Value<String>? videoId,
    Value<String>? textChunk,
    Value<double>? startTime,
    Value<double>? endTime,
    Value<String>? language,
    Value<int>? rowid,
  }) {
    return TranscriptsCompanion(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      textChunk: textChunk ?? this.textChunk,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      language: language ?? this.language,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (textChunk.present) {
      map['text_chunk'] = Variable<String>(textChunk.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<double>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<double>(endTime.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptsCompanion(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('textChunk: $textChunk, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('language: $language, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageInsightsTable extends ImageInsights
    with TableInfo<$ImageInsightsTable, ImageInsight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageInsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageTypeMeta = const VerificationMeta(
    'imageType',
  );
  @override
  late final GeneratedColumn<String> imageType = GeneratedColumn<String>(
    'image_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedConceptsMeta = const VerificationMeta(
    'extractedConcepts',
  );
  @override
  late final GeneratedColumn<String> extractedConcepts =
      GeneratedColumn<String>(
        'extracted_concepts',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<int> processedAt = GeneratedColumn<int>(
    'processed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentId,
    imageType,
    caption,
    extractedConcepts,
    ocrText,
    processedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageInsight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('image_type')) {
      context.handle(
        _imageTypeMeta,
        imageType.isAcceptableOrUnknown(data['image_type']!, _imageTypeMeta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('extracted_concepts')) {
      context.handle(
        _extractedConceptsMeta,
        extractedConcepts.isAcceptableOrUnknown(
          data['extracted_concepts']!,
          _extractedConceptsMeta,
        ),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageInsight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageInsight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      imageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_type'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      extractedConcepts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_concepts'],
      ),
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      ),
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processed_at'],
      )!,
    );
  }

  @override
  $ImageInsightsTable createAlias(String alias) {
    return $ImageInsightsTable(attachedDatabase, alias);
  }
}

class ImageInsight extends DataClass implements Insertable<ImageInsight> {
  final String id;
  final String contentId;
  final String? imageType;
  final String? caption;
  final String? extractedConcepts;
  final String? ocrText;
  final int processedAt;
  const ImageInsight({
    required this.id,
    required this.contentId,
    this.imageType,
    this.caption,
    this.extractedConcepts,
    this.ocrText,
    required this.processedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content_id'] = Variable<String>(contentId);
    if (!nullToAbsent || imageType != null) {
      map['image_type'] = Variable<String>(imageType);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    if (!nullToAbsent || extractedConcepts != null) {
      map['extracted_concepts'] = Variable<String>(extractedConcepts);
    }
    if (!nullToAbsent || ocrText != null) {
      map['ocr_text'] = Variable<String>(ocrText);
    }
    map['processed_at'] = Variable<int>(processedAt);
    return map;
  }

  ImageInsightsCompanion toCompanion(bool nullToAbsent) {
    return ImageInsightsCompanion(
      id: Value(id),
      contentId: Value(contentId),
      imageType: imageType == null && nullToAbsent
          ? const Value.absent()
          : Value(imageType),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      extractedConcepts: extractedConcepts == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedConcepts),
      ocrText: ocrText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrText),
      processedAt: Value(processedAt),
    );
  }

  factory ImageInsight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageInsight(
      id: serializer.fromJson<String>(json['id']),
      contentId: serializer.fromJson<String>(json['contentId']),
      imageType: serializer.fromJson<String?>(json['imageType']),
      caption: serializer.fromJson<String?>(json['caption']),
      extractedConcepts: serializer.fromJson<String?>(
        json['extractedConcepts'],
      ),
      ocrText: serializer.fromJson<String?>(json['ocrText']),
      processedAt: serializer.fromJson<int>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentId': serializer.toJson<String>(contentId),
      'imageType': serializer.toJson<String?>(imageType),
      'caption': serializer.toJson<String?>(caption),
      'extractedConcepts': serializer.toJson<String?>(extractedConcepts),
      'ocrText': serializer.toJson<String?>(ocrText),
      'processedAt': serializer.toJson<int>(processedAt),
    };
  }

  ImageInsight copyWith({
    String? id,
    String? contentId,
    Value<String?> imageType = const Value.absent(),
    Value<String?> caption = const Value.absent(),
    Value<String?> extractedConcepts = const Value.absent(),
    Value<String?> ocrText = const Value.absent(),
    int? processedAt,
  }) => ImageInsight(
    id: id ?? this.id,
    contentId: contentId ?? this.contentId,
    imageType: imageType.present ? imageType.value : this.imageType,
    caption: caption.present ? caption.value : this.caption,
    extractedConcepts: extractedConcepts.present
        ? extractedConcepts.value
        : this.extractedConcepts,
    ocrText: ocrText.present ? ocrText.value : this.ocrText,
    processedAt: processedAt ?? this.processedAt,
  );
  ImageInsight copyWithCompanion(ImageInsightsCompanion data) {
    return ImageInsight(
      id: data.id.present ? data.id.value : this.id,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      imageType: data.imageType.present ? data.imageType.value : this.imageType,
      caption: data.caption.present ? data.caption.value : this.caption,
      extractedConcepts: data.extractedConcepts.present
          ? data.extractedConcepts.value
          : this.extractedConcepts,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageInsight(')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('imageType: $imageType, ')
          ..write('caption: $caption, ')
          ..write('extractedConcepts: $extractedConcepts, ')
          ..write('ocrText: $ocrText, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentId,
    imageType,
    caption,
    extractedConcepts,
    ocrText,
    processedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageInsight &&
          other.id == this.id &&
          other.contentId == this.contentId &&
          other.imageType == this.imageType &&
          other.caption == this.caption &&
          other.extractedConcepts == this.extractedConcepts &&
          other.ocrText == this.ocrText &&
          other.processedAt == this.processedAt);
}

class ImageInsightsCompanion extends UpdateCompanion<ImageInsight> {
  final Value<String> id;
  final Value<String> contentId;
  final Value<String?> imageType;
  final Value<String?> caption;
  final Value<String?> extractedConcepts;
  final Value<String?> ocrText;
  final Value<int> processedAt;
  final Value<int> rowid;
  const ImageInsightsCompanion({
    this.id = const Value.absent(),
    this.contentId = const Value.absent(),
    this.imageType = const Value.absent(),
    this.caption = const Value.absent(),
    this.extractedConcepts = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageInsightsCompanion.insert({
    required String id,
    required String contentId,
    this.imageType = const Value.absent(),
    this.caption = const Value.absent(),
    this.extractedConcepts = const Value.absent(),
    this.ocrText = const Value.absent(),
    required int processedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentId = Value(contentId),
       processedAt = Value(processedAt);
  static Insertable<ImageInsight> custom({
    Expression<String>? id,
    Expression<String>? contentId,
    Expression<String>? imageType,
    Expression<String>? caption,
    Expression<String>? extractedConcepts,
    Expression<String>? ocrText,
    Expression<int>? processedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (imageType != null) 'image_type': imageType,
      if (caption != null) 'caption': caption,
      if (extractedConcepts != null) 'extracted_concepts': extractedConcepts,
      if (ocrText != null) 'ocr_text': ocrText,
      if (processedAt != null) 'processed_at': processedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageInsightsCompanion copyWith({
    Value<String>? id,
    Value<String>? contentId,
    Value<String?>? imageType,
    Value<String?>? caption,
    Value<String?>? extractedConcepts,
    Value<String?>? ocrText,
    Value<int>? processedAt,
    Value<int>? rowid,
  }) {
    return ImageInsightsCompanion(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      imageType: imageType ?? this.imageType,
      caption: caption ?? this.caption,
      extractedConcepts: extractedConcepts ?? this.extractedConcepts,
      ocrText: ocrText ?? this.ocrText,
      processedAt: processedAt ?? this.processedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (imageType.present) {
      map['image_type'] = Variable<String>(imageType.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (extractedConcepts.present) {
      map['extracted_concepts'] = Variable<String>(extractedConcepts.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<int>(processedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageInsightsCompanion(')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('imageType: $imageType, ')
          ..write('caption: $caption, ')
          ..write('extractedConcepts: $extractedConcepts, ')
          ..write('ocrText: $ocrText, ')
          ..write('processedAt: $processedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmbeddingsTable extends Embeddings
    with TableInfo<$EmbeddingsTable, Embedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkIndexMeta = const VerificationMeta(
    'chunkIndex',
  );
  @override
  late final GeneratedColumn<int> chunkIndex = GeneratedColumn<int>(
    'chunk_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkTextMeta = const VerificationMeta(
    'chunkText',
  );
  @override
  late final GeneratedColumn<String> chunkText = GeneratedColumn<String>(
    'chunk_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
    'embedding',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('minilm-l6-v2'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentId,
    chunkIndex,
    chunkText,
    embedding,
    model,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Embedding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('chunk_index')) {
      context.handle(
        _chunkIndexMeta,
        chunkIndex.isAcceptableOrUnknown(data['chunk_index']!, _chunkIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIndexMeta);
    }
    if (data.containsKey('chunk_text')) {
      context.handle(
        _chunkTextMeta,
        chunkText.isAcceptableOrUnknown(data['chunk_text']!, _chunkTextMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkTextMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Embedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Embedding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      chunkIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_index'],
      )!,
      chunkText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chunk_text'],
      )!,
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}embedding'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
    );
  }

  @override
  $EmbeddingsTable createAlias(String alias) {
    return $EmbeddingsTable(attachedDatabase, alias);
  }
}

class Embedding extends DataClass implements Insertable<Embedding> {
  final String id;
  final String contentId;
  final int chunkIndex;
  final String chunkText;
  final Uint8List embedding;
  final String model;
  const Embedding({
    required this.id,
    required this.contentId,
    required this.chunkIndex,
    required this.chunkText,
    required this.embedding,
    required this.model,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content_id'] = Variable<String>(contentId);
    map['chunk_index'] = Variable<int>(chunkIndex);
    map['chunk_text'] = Variable<String>(chunkText);
    map['embedding'] = Variable<Uint8List>(embedding);
    map['model'] = Variable<String>(model);
    return map;
  }

  EmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return EmbeddingsCompanion(
      id: Value(id),
      contentId: Value(contentId),
      chunkIndex: Value(chunkIndex),
      chunkText: Value(chunkText),
      embedding: Value(embedding),
      model: Value(model),
    );
  }

  factory Embedding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Embedding(
      id: serializer.fromJson<String>(json['id']),
      contentId: serializer.fromJson<String>(json['contentId']),
      chunkIndex: serializer.fromJson<int>(json['chunkIndex']),
      chunkText: serializer.fromJson<String>(json['chunkText']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      model: serializer.fromJson<String>(json['model']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentId': serializer.toJson<String>(contentId),
      'chunkIndex': serializer.toJson<int>(chunkIndex),
      'chunkText': serializer.toJson<String>(chunkText),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'model': serializer.toJson<String>(model),
    };
  }

  Embedding copyWith({
    String? id,
    String? contentId,
    int? chunkIndex,
    String? chunkText,
    Uint8List? embedding,
    String? model,
  }) => Embedding(
    id: id ?? this.id,
    contentId: contentId ?? this.contentId,
    chunkIndex: chunkIndex ?? this.chunkIndex,
    chunkText: chunkText ?? this.chunkText,
    embedding: embedding ?? this.embedding,
    model: model ?? this.model,
  );
  Embedding copyWithCompanion(EmbeddingsCompanion data) {
    return Embedding(
      id: data.id.present ? data.id.value : this.id,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      chunkIndex: data.chunkIndex.present
          ? data.chunkIndex.value
          : this.chunkIndex,
      chunkText: data.chunkText.present ? data.chunkText.value : this.chunkText,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      model: data.model.present ? data.model.value : this.model,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Embedding(')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('chunkText: $chunkText, ')
          ..write('embedding: $embedding, ')
          ..write('model: $model')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentId,
    chunkIndex,
    chunkText,
    $driftBlobEquality.hash(embedding),
    model,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Embedding &&
          other.id == this.id &&
          other.contentId == this.contentId &&
          other.chunkIndex == this.chunkIndex &&
          other.chunkText == this.chunkText &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.model == this.model);
}

class EmbeddingsCompanion extends UpdateCompanion<Embedding> {
  final Value<String> id;
  final Value<String> contentId;
  final Value<int> chunkIndex;
  final Value<String> chunkText;
  final Value<Uint8List> embedding;
  final Value<String> model;
  final Value<int> rowid;
  const EmbeddingsCompanion({
    this.id = const Value.absent(),
    this.contentId = const Value.absent(),
    this.chunkIndex = const Value.absent(),
    this.chunkText = const Value.absent(),
    this.embedding = const Value.absent(),
    this.model = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmbeddingsCompanion.insert({
    required String id,
    required String contentId,
    required int chunkIndex,
    required String chunkText,
    required Uint8List embedding,
    this.model = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentId = Value(contentId),
       chunkIndex = Value(chunkIndex),
       chunkText = Value(chunkText),
       embedding = Value(embedding);
  static Insertable<Embedding> custom({
    Expression<String>? id,
    Expression<String>? contentId,
    Expression<int>? chunkIndex,
    Expression<String>? chunkText,
    Expression<Uint8List>? embedding,
    Expression<String>? model,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (chunkIndex != null) 'chunk_index': chunkIndex,
      if (chunkText != null) 'chunk_text': chunkText,
      if (embedding != null) 'embedding': embedding,
      if (model != null) 'model': model,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmbeddingsCompanion copyWith({
    Value<String>? id,
    Value<String>? contentId,
    Value<int>? chunkIndex,
    Value<String>? chunkText,
    Value<Uint8List>? embedding,
    Value<String>? model,
    Value<int>? rowid,
  }) {
    return EmbeddingsCompanion(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      chunkText: chunkText ?? this.chunkText,
      embedding: embedding ?? this.embedding,
      model: model ?? this.model,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (chunkIndex.present) {
      map['chunk_index'] = Variable<int>(chunkIndex.value);
    }
    if (chunkText.present) {
      map['chunk_text'] = Variable<String>(chunkText.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('chunkText: $chunkText, ')
          ..write('embedding: $embedding, ')
          ..write('model: $model, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EngagementSessionsTable extends EngagementSessions
    with TableInfo<$EngagementSessionsTable, EngagementSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EngagementSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
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
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tapCountMeta = const VerificationMeta(
    'tapCount',
  );
  @override
  late final GeneratedColumn<int> tapCount = GeneratedColumn<int>(
    'tap_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scrollEventsMeta = const VerificationMeta(
    'scrollEvents',
  );
  @override
  late final GeneratedColumn<int> scrollEvents = GeneratedColumn<int>(
    'scroll_events',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idleSecondsMeta = const VerificationMeta(
    'idleSeconds',
  );
  @override
  late final GeneratedColumn<int> idleSeconds = GeneratedColumn<int>(
    'idle_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    contentId,
    state,
    durationSeconds,
    tapCount,
    scrollEvents,
    idleSeconds,
    startedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'engagement_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EngagementSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('tap_count')) {
      context.handle(
        _tapCountMeta,
        tapCount.isAcceptableOrUnknown(data['tap_count']!, _tapCountMeta),
      );
    }
    if (data.containsKey('scroll_events')) {
      context.handle(
        _scrollEventsMeta,
        scrollEvents.isAcceptableOrUnknown(
          data['scroll_events']!,
          _scrollEventsMeta,
        ),
      );
    }
    if (data.containsKey('idle_seconds')) {
      context.handle(
        _idleSecondsMeta,
        idleSeconds.isAcceptableOrUnknown(
          data['idle_seconds']!,
          _idleSecondsMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EngagementSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EngagementSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      tapCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tap_count'],
      )!,
      scrollEvents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scroll_events'],
      )!,
      idleSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idle_seconds'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
    );
  }

  @override
  $EngagementSessionsTable createAlias(String alias) {
    return $EngagementSessionsTable(attachedDatabase, alias);
  }
}

class EngagementSession extends DataClass
    implements Insertable<EngagementSession> {
  final String id;
  final String userId;
  final String contentId;
  final String state;
  final int durationSeconds;
  final int tapCount;
  final int scrollEvents;
  final int idleSeconds;
  final int startedAt;
  const EngagementSession({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.state,
    required this.durationSeconds,
    required this.tapCount,
    required this.scrollEvents,
    required this.idleSeconds,
    required this.startedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['content_id'] = Variable<String>(contentId);
    map['state'] = Variable<String>(state);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['tap_count'] = Variable<int>(tapCount);
    map['scroll_events'] = Variable<int>(scrollEvents);
    map['idle_seconds'] = Variable<int>(idleSeconds);
    map['started_at'] = Variable<int>(startedAt);
    return map;
  }

  EngagementSessionsCompanion toCompanion(bool nullToAbsent) {
    return EngagementSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      contentId: Value(contentId),
      state: Value(state),
      durationSeconds: Value(durationSeconds),
      tapCount: Value(tapCount),
      scrollEvents: Value(scrollEvents),
      idleSeconds: Value(idleSeconds),
      startedAt: Value(startedAt),
    );
  }

  factory EngagementSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EngagementSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      contentId: serializer.fromJson<String>(json['contentId']),
      state: serializer.fromJson<String>(json['state']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      tapCount: serializer.fromJson<int>(json['tapCount']),
      scrollEvents: serializer.fromJson<int>(json['scrollEvents']),
      idleSeconds: serializer.fromJson<int>(json['idleSeconds']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'contentId': serializer.toJson<String>(contentId),
      'state': serializer.toJson<String>(state),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'tapCount': serializer.toJson<int>(tapCount),
      'scrollEvents': serializer.toJson<int>(scrollEvents),
      'idleSeconds': serializer.toJson<int>(idleSeconds),
      'startedAt': serializer.toJson<int>(startedAt),
    };
  }

  EngagementSession copyWith({
    String? id,
    String? userId,
    String? contentId,
    String? state,
    int? durationSeconds,
    int? tapCount,
    int? scrollEvents,
    int? idleSeconds,
    int? startedAt,
  }) => EngagementSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    contentId: contentId ?? this.contentId,
    state: state ?? this.state,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    tapCount: tapCount ?? this.tapCount,
    scrollEvents: scrollEvents ?? this.scrollEvents,
    idleSeconds: idleSeconds ?? this.idleSeconds,
    startedAt: startedAt ?? this.startedAt,
  );
  EngagementSession copyWithCompanion(EngagementSessionsCompanion data) {
    return EngagementSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      state: data.state.present ? data.state.value : this.state,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      tapCount: data.tapCount.present ? data.tapCount.value : this.tapCount,
      scrollEvents: data.scrollEvents.present
          ? data.scrollEvents.value
          : this.scrollEvents,
      idleSeconds: data.idleSeconds.present
          ? data.idleSeconds.value
          : this.idleSeconds,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EngagementSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('contentId: $contentId, ')
          ..write('state: $state, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('tapCount: $tapCount, ')
          ..write('scrollEvents: $scrollEvents, ')
          ..write('idleSeconds: $idleSeconds, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    contentId,
    state,
    durationSeconds,
    tapCount,
    scrollEvents,
    idleSeconds,
    startedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EngagementSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.contentId == this.contentId &&
          other.state == this.state &&
          other.durationSeconds == this.durationSeconds &&
          other.tapCount == this.tapCount &&
          other.scrollEvents == this.scrollEvents &&
          other.idleSeconds == this.idleSeconds &&
          other.startedAt == this.startedAt);
}

class EngagementSessionsCompanion extends UpdateCompanion<EngagementSession> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> contentId;
  final Value<String> state;
  final Value<int> durationSeconds;
  final Value<int> tapCount;
  final Value<int> scrollEvents;
  final Value<int> idleSeconds;
  final Value<int> startedAt;
  final Value<int> rowid;
  const EngagementSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.contentId = const Value.absent(),
    this.state = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.tapCount = const Value.absent(),
    this.scrollEvents = const Value.absent(),
    this.idleSeconds = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EngagementSessionsCompanion.insert({
    required String id,
    required String userId,
    required String contentId,
    required String state,
    required int durationSeconds,
    this.tapCount = const Value.absent(),
    this.scrollEvents = const Value.absent(),
    this.idleSeconds = const Value.absent(),
    required int startedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       contentId = Value(contentId),
       state = Value(state),
       durationSeconds = Value(durationSeconds),
       startedAt = Value(startedAt);
  static Insertable<EngagementSession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? contentId,
    Expression<String>? state,
    Expression<int>? durationSeconds,
    Expression<int>? tapCount,
    Expression<int>? scrollEvents,
    Expression<int>? idleSeconds,
    Expression<int>? startedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (contentId != null) 'content_id': contentId,
      if (state != null) 'state': state,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (tapCount != null) 'tap_count': tapCount,
      if (scrollEvents != null) 'scroll_events': scrollEvents,
      if (idleSeconds != null) 'idle_seconds': idleSeconds,
      if (startedAt != null) 'started_at': startedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EngagementSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? contentId,
    Value<String>? state,
    Value<int>? durationSeconds,
    Value<int>? tapCount,
    Value<int>? scrollEvents,
    Value<int>? idleSeconds,
    Value<int>? startedAt,
    Value<int>? rowid,
  }) {
    return EngagementSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      state: state ?? this.state,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      tapCount: tapCount ?? this.tapCount,
      scrollEvents: scrollEvents ?? this.scrollEvents,
      idleSeconds: idleSeconds ?? this.idleSeconds,
      startedAt: startedAt ?? this.startedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (tapCount.present) {
      map['tap_count'] = Variable<int>(tapCount.value);
    }
    if (scrollEvents.present) {
      map['scroll_events'] = Variable<int>(scrollEvents.value);
    }
    if (idleSeconds.present) {
      map['idle_seconds'] = Variable<int>(idleSeconds.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EngagementSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('contentId: $contentId, ')
          ..write('state: $state, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('tapCount: $tapCount, ')
          ..write('scrollEvents: $scrollEvents, ')
          ..write('idleSeconds: $idleSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, UserProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionPctMeta = const VerificationMeta(
    'completionPct',
  );
  @override
  late final GeneratedColumn<double> completionPct = GeneratedColumn<double>(
    'completion_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<int> lastAccessedAt = GeneratedColumn<int>(
    'last_accessed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyRatingMeta = const VerificationMeta(
    'difficultyRating',
  );
  @override
  late final GeneratedColumn<int> difficultyRating = GeneratedColumn<int>(
    'difficulty_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeSpentSecondsMeta = const VerificationMeta(
    'timeSpentSeconds',
  );
  @override
  late final GeneratedColumn<int> timeSpentSeconds = GeneratedColumn<int>(
    'time_spent_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    contentId,
    completionPct,
    lastAccessedAt,
    difficultyRating,
    timeSpentSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('completion_pct')) {
      context.handle(
        _completionPctMeta,
        completionPct.isAcceptableOrUnknown(
          data['completion_pct']!,
          _completionPctMeta,
        ),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('difficulty_rating')) {
      context.handle(
        _difficultyRatingMeta,
        difficultyRating.isAcceptableOrUnknown(
          data['difficulty_rating']!,
          _difficultyRatingMeta,
        ),
      );
    }
    if (data.containsKey('time_spent_seconds')) {
      context.handle(
        _timeSpentSecondsMeta,
        timeSpentSeconds.isAcceptableOrUnknown(
          data['time_spent_seconds']!,
          _timeSpentSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      completionPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}completion_pct'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      difficultyRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_rating'],
      ),
      timeSpentSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_spent_seconds'],
      )!,
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressData extends DataClass
    implements Insertable<UserProgressData> {
  final String id;
  final String userId;
  final String contentId;
  final double completionPct;
  final int lastAccessedAt;
  final int? difficultyRating;
  final int timeSpentSeconds;
  const UserProgressData({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.completionPct,
    required this.lastAccessedAt,
    this.difficultyRating,
    required this.timeSpentSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['content_id'] = Variable<String>(contentId);
    map['completion_pct'] = Variable<double>(completionPct);
    map['last_accessed_at'] = Variable<int>(lastAccessedAt);
    if (!nullToAbsent || difficultyRating != null) {
      map['difficulty_rating'] = Variable<int>(difficultyRating);
    }
    map['time_spent_seconds'] = Variable<int>(timeSpentSeconds);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      id: Value(id),
      userId: Value(userId),
      contentId: Value(contentId),
      completionPct: Value(completionPct),
      lastAccessedAt: Value(lastAccessedAt),
      difficultyRating: difficultyRating == null && nullToAbsent
          ? const Value.absent()
          : Value(difficultyRating),
      timeSpentSeconds: Value(timeSpentSeconds),
    );
  }

  factory UserProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      contentId: serializer.fromJson<String>(json['contentId']),
      completionPct: serializer.fromJson<double>(json['completionPct']),
      lastAccessedAt: serializer.fromJson<int>(json['lastAccessedAt']),
      difficultyRating: serializer.fromJson<int?>(json['difficultyRating']),
      timeSpentSeconds: serializer.fromJson<int>(json['timeSpentSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'contentId': serializer.toJson<String>(contentId),
      'completionPct': serializer.toJson<double>(completionPct),
      'lastAccessedAt': serializer.toJson<int>(lastAccessedAt),
      'difficultyRating': serializer.toJson<int?>(difficultyRating),
      'timeSpentSeconds': serializer.toJson<int>(timeSpentSeconds),
    };
  }

  UserProgressData copyWith({
    String? id,
    String? userId,
    String? contentId,
    double? completionPct,
    int? lastAccessedAt,
    Value<int?> difficultyRating = const Value.absent(),
    int? timeSpentSeconds,
  }) => UserProgressData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    contentId: contentId ?? this.contentId,
    completionPct: completionPct ?? this.completionPct,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    difficultyRating: difficultyRating.present
        ? difficultyRating.value
        : this.difficultyRating,
    timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      completionPct: data.completionPct.present
          ? data.completionPct.value
          : this.completionPct,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      difficultyRating: data.difficultyRating.present
          ? data.difficultyRating.value
          : this.difficultyRating,
      timeSpentSeconds: data.timeSpentSeconds.present
          ? data.timeSpentSeconds.value
          : this.timeSpentSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('contentId: $contentId, ')
          ..write('completionPct: $completionPct, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('difficultyRating: $difficultyRating, ')
          ..write('timeSpentSeconds: $timeSpentSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    contentId,
    completionPct,
    lastAccessedAt,
    difficultyRating,
    timeSpentSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.contentId == this.contentId &&
          other.completionPct == this.completionPct &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.difficultyRating == this.difficultyRating &&
          other.timeSpentSeconds == this.timeSpentSeconds);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> contentId;
  final Value<double> completionPct;
  final Value<int> lastAccessedAt;
  final Value<int?> difficultyRating;
  final Value<int> timeSpentSeconds;
  final Value<int> rowid;
  const UserProgressCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.contentId = const Value.absent(),
    this.completionPct = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.difficultyRating = const Value.absent(),
    this.timeSpentSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProgressCompanion.insert({
    required String id,
    required String userId,
    required String contentId,
    this.completionPct = const Value.absent(),
    required int lastAccessedAt,
    this.difficultyRating = const Value.absent(),
    this.timeSpentSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       contentId = Value(contentId),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<UserProgressData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? contentId,
    Expression<double>? completionPct,
    Expression<int>? lastAccessedAt,
    Expression<int>? difficultyRating,
    Expression<int>? timeSpentSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (contentId != null) 'content_id': contentId,
      if (completionPct != null) 'completion_pct': completionPct,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (difficultyRating != null) 'difficulty_rating': difficultyRating,
      if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProgressCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? contentId,
    Value<double>? completionPct,
    Value<int>? lastAccessedAt,
    Value<int?>? difficultyRating,
    Value<int>? timeSpentSeconds,
    Value<int>? rowid,
  }) {
    return UserProgressCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      completionPct: completionPct ?? this.completionPct,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (completionPct.present) {
      map['completion_pct'] = Variable<double>(completionPct.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt.value);
    }
    if (difficultyRating.present) {
      map['difficulty_rating'] = Variable<int>(difficultyRating.value);
    }
    if (timeSpentSeconds.present) {
      map['time_spent_seconds'] = Variable<int>(timeSpentSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('contentId: $contentId, ')
          ..write('completionPct: $completionPct, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('difficultyRating: $difficultyRating, ')
          ..write('timeSpentSeconds: $timeSpentSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIResponseCacheTable extends AIResponseCache
    with TableInfo<$AIResponseCacheTable, AIResponseCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIResponseCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cacheKey,
    responseJson,
    source,
    model,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'a_i_response_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AIResponseCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseJsonMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
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
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIResponseCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIResponseCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $AIResponseCacheTable createAlias(String alias) {
    return $AIResponseCacheTable(attachedDatabase, alias);
  }
}

class AIResponseCacheData extends DataClass
    implements Insertable<AIResponseCacheData> {
  final String id;
  final String cacheKey;
  final String responseJson;
  final String source;
  final String? model;
  final int createdAt;
  final int expiresAt;
  const AIResponseCacheData({
    required this.id,
    required this.cacheKey,
    required this.responseJson,
    required this.source,
    this.model,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cache_key'] = Variable<String>(cacheKey);
    map['response_json'] = Variable<String>(responseJson);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['expires_at'] = Variable<int>(expiresAt);
    return map;
  }

  AIResponseCacheCompanion toCompanion(bool nullToAbsent) {
    return AIResponseCacheCompanion(
      id: Value(id),
      cacheKey: Value(cacheKey),
      responseJson: Value(responseJson),
      source: Value(source),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory AIResponseCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIResponseCacheData(
      id: serializer.fromJson<String>(json['id']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      responseJson: serializer.fromJson<String>(json['responseJson']),
      source: serializer.fromJson<String>(json['source']),
      model: serializer.fromJson<String?>(json['model']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      expiresAt: serializer.fromJson<int>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'responseJson': serializer.toJson<String>(responseJson),
      'source': serializer.toJson<String>(source),
      'model': serializer.toJson<String?>(model),
      'createdAt': serializer.toJson<int>(createdAt),
      'expiresAt': serializer.toJson<int>(expiresAt),
    };
  }

  AIResponseCacheData copyWith({
    String? id,
    String? cacheKey,
    String? responseJson,
    String? source,
    Value<String?> model = const Value.absent(),
    int? createdAt,
    int? expiresAt,
  }) => AIResponseCacheData(
    id: id ?? this.id,
    cacheKey: cacheKey ?? this.cacheKey,
    responseJson: responseJson ?? this.responseJson,
    source: source ?? this.source,
    model: model.present ? model.value : this.model,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  AIResponseCacheData copyWithCompanion(AIResponseCacheCompanion data) {
    return AIResponseCacheData(
      id: data.id.present ? data.id.value : this.id,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      source: data.source.present ? data.source.value : this.source,
      model: data.model.present ? data.model.value : this.model,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIResponseCacheData(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('responseJson: $responseJson, ')
          ..write('source: $source, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cacheKey,
    responseJson,
    source,
    model,
    createdAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIResponseCacheData &&
          other.id == this.id &&
          other.cacheKey == this.cacheKey &&
          other.responseJson == this.responseJson &&
          other.source == this.source &&
          other.model == this.model &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class AIResponseCacheCompanion extends UpdateCompanion<AIResponseCacheData> {
  final Value<String> id;
  final Value<String> cacheKey;
  final Value<String> responseJson;
  final Value<String> source;
  final Value<String?> model;
  final Value<int> createdAt;
  final Value<int> expiresAt;
  final Value<int> rowid;
  const AIResponseCacheCompanion({
    this.id = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.source = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIResponseCacheCompanion.insert({
    required String id,
    required String cacheKey,
    required String responseJson,
    required String source,
    this.model = const Value.absent(),
    required int createdAt,
    required int expiresAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cacheKey = Value(cacheKey),
       responseJson = Value(responseJson),
       source = Value(source),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt);
  static Insertable<AIResponseCacheData> custom({
    Expression<String>? id,
    Expression<String>? cacheKey,
    Expression<String>? responseJson,
    Expression<String>? source,
    Expression<String>? model,
    Expression<int>? createdAt,
    Expression<int>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (responseJson != null) 'response_json': responseJson,
      if (source != null) 'source': source,
      if (model != null) 'model': model,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIResponseCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? cacheKey,
    Value<String>? responseJson,
    Value<String>? source,
    Value<String?>? model,
    Value<int>? createdAt,
    Value<int>? expiresAt,
    Value<int>? rowid,
  }) {
    return AIResponseCacheCompanion(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      responseJson: responseJson ?? this.responseJson,
      source: source ?? this.source,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIResponseCacheCompanion(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('responseJson: $responseJson, ')
          ..write('source: $source, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaderboardEntriesTable extends LeaderboardEntries
    with TableInfo<$LeaderboardEntriesTable, LeaderboardEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaderboardEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPointsMeta = const VerificationMeta(
    'totalPoints',
  );
  @override
  late final GeneratedColumn<int> totalPoints = GeneratedColumn<int>(
    'total_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weeklyPointsMeta = const VerificationMeta(
    'weeklyPoints',
  );
  @override
  late final GeneratedColumn<int> weeklyPoints = GeneratedColumn<int>(
    'weekly_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    displayName,
    streakDays,
    totalPoints,
    weeklyPoints,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaderboard_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaderboardEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('total_points')) {
      context.handle(
        _totalPointsMeta,
        totalPoints.isAcceptableOrUnknown(
          data['total_points']!,
          _totalPointsMeta,
        ),
      );
    }
    if (data.containsKey('weekly_points')) {
      context.handle(
        _weeklyPointsMeta,
        weeklyPoints.isAcceptableOrUnknown(
          data['weekly_points']!,
          _weeklyPointsMeta,
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
  LeaderboardEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaderboardEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      totalPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_points'],
      )!,
      weeklyPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_points'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LeaderboardEntriesTable createAlias(String alias) {
    return $LeaderboardEntriesTable(attachedDatabase, alias);
  }
}

class LeaderboardEntry extends DataClass
    implements Insertable<LeaderboardEntry> {
  final String id;
  final String userId;
  final String displayName;
  final int streakDays;
  final int totalPoints;
  final int weeklyPoints;
  final int updatedAt;
  const LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.streakDays,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['streak_days'] = Variable<int>(streakDays);
    map['total_points'] = Variable<int>(totalPoints);
    map['weekly_points'] = Variable<int>(weeklyPoints);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LeaderboardEntriesCompanion toCompanion(bool nullToAbsent) {
    return LeaderboardEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      displayName: Value(displayName),
      streakDays: Value(streakDays),
      totalPoints: Value(totalPoints),
      weeklyPoints: Value(weeklyPoints),
      updatedAt: Value(updatedAt),
    );
  }

  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaderboardEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      totalPoints: serializer.fromJson<int>(json['totalPoints']),
      weeklyPoints: serializer.fromJson<int>(json['weeklyPoints']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'streakDays': serializer.toJson<int>(streakDays),
      'totalPoints': serializer.toJson<int>(totalPoints),
      'weeklyPoints': serializer.toJson<int>(weeklyPoints),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LeaderboardEntry copyWith({
    String? id,
    String? userId,
    String? displayName,
    int? streakDays,
    int? totalPoints,
    int? weeklyPoints,
    int? updatedAt,
  }) => LeaderboardEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    streakDays: streakDays ?? this.streakDays,
    totalPoints: totalPoints ?? this.totalPoints,
    weeklyPoints: weeklyPoints ?? this.weeklyPoints,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LeaderboardEntry copyWithCompanion(LeaderboardEntriesCompanion data) {
    return LeaderboardEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      totalPoints: data.totalPoints.present
          ? data.totalPoints.value
          : this.totalPoints,
      weeklyPoints: data.weeklyPoints.present
          ? data.weeklyPoints.value
          : this.weeklyPoints,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('streakDays: $streakDays, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('weeklyPoints: $weeklyPoints, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    displayName,
    streakDays,
    totalPoints,
    weeklyPoints,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.streakDays == this.streakDays &&
          other.totalPoints == this.totalPoints &&
          other.weeklyPoints == this.weeklyPoints &&
          other.updatedAt == this.updatedAt);
}

class LeaderboardEntriesCompanion extends UpdateCompanion<LeaderboardEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> displayName;
  final Value<int> streakDays;
  final Value<int> totalPoints;
  final Value<int> weeklyPoints;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LeaderboardEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.weeklyPoints = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaderboardEntriesCompanion.insert({
    required String id,
    required String userId,
    required String displayName,
    this.streakDays = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.weeklyPoints = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt);
  static Insertable<LeaderboardEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<int>? streakDays,
    Expression<int>? totalPoints,
    Expression<int>? weeklyPoints,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (streakDays != null) 'streak_days': streakDays,
      if (totalPoints != null) 'total_points': totalPoints,
      if (weeklyPoints != null) 'weekly_points': weeklyPoints,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaderboardEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? displayName,
    Value<int>? streakDays,
    Value<int>? totalPoints,
    Value<int>? weeklyPoints,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LeaderboardEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      streakDays: streakDays ?? this.streakDays,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (totalPoints.present) {
      map['total_points'] = Variable<int>(totalPoints.value);
    }
    if (weeklyPoints.present) {
      map['weekly_points'] = Variable<int>(weeklyPoints.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('streakDays: $streakDays, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('weeklyPoints: $weeklyPoints, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeerDevicesTable extends PeerDevices
    with TableInfo<$PeerDevicesTable, PeerDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeerDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointIdMeta = const VerificationMeta(
    'endpointId',
  );
  @override
  late final GeneratedColumn<String> endpointId = GeneratedColumn<String>(
    'endpoint_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentSyncedMeta = const VerificationMeta(
    'contentSynced',
  );
  @override
  late final GeneratedColumn<String> contentSynced = GeneratedColumn<String>(
    'content_synced',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceName,
    endpointId,
    lastSeenAt,
    contentSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'peer_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeerDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('endpoint_id')) {
      context.handle(
        _endpointIdMeta,
        endpointId.isAcceptableOrUnknown(data['endpoint_id']!, _endpointIdMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('content_synced')) {
      context.handle(
        _contentSyncedMeta,
        contentSynced.isAcceptableOrUnknown(
          data['content_synced']!,
          _contentSyncedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeerDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeerDevice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      endpointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint_id'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
      contentSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_synced'],
      ),
    );
  }

  @override
  $PeerDevicesTable createAlias(String alias) {
    return $PeerDevicesTable(attachedDatabase, alias);
  }
}

class PeerDevice extends DataClass implements Insertable<PeerDevice> {
  final String id;
  final String deviceName;
  final String? endpointId;
  final int lastSeenAt;
  final String? contentSynced;
  const PeerDevice({
    required this.id,
    required this.deviceName,
    this.endpointId,
    required this.lastSeenAt,
    this.contentSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_name'] = Variable<String>(deviceName);
    if (!nullToAbsent || endpointId != null) {
      map['endpoint_id'] = Variable<String>(endpointId);
    }
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    if (!nullToAbsent || contentSynced != null) {
      map['content_synced'] = Variable<String>(contentSynced);
    }
    return map;
  }

  PeerDevicesCompanion toCompanion(bool nullToAbsent) {
    return PeerDevicesCompanion(
      id: Value(id),
      deviceName: Value(deviceName),
      endpointId: endpointId == null && nullToAbsent
          ? const Value.absent()
          : Value(endpointId),
      lastSeenAt: Value(lastSeenAt),
      contentSynced: contentSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(contentSynced),
    );
  }

  factory PeerDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeerDevice(
      id: serializer.fromJson<String>(json['id']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      endpointId: serializer.fromJson<String?>(json['endpointId']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
      contentSynced: serializer.fromJson<String?>(json['contentSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceName': serializer.toJson<String>(deviceName),
      'endpointId': serializer.toJson<String?>(endpointId),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
      'contentSynced': serializer.toJson<String?>(contentSynced),
    };
  }

  PeerDevice copyWith({
    String? id,
    String? deviceName,
    Value<String?> endpointId = const Value.absent(),
    int? lastSeenAt,
    Value<String?> contentSynced = const Value.absent(),
  }) => PeerDevice(
    id: id ?? this.id,
    deviceName: deviceName ?? this.deviceName,
    endpointId: endpointId.present ? endpointId.value : this.endpointId,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    contentSynced: contentSynced.present
        ? contentSynced.value
        : this.contentSynced,
  );
  PeerDevice copyWithCompanion(PeerDevicesCompanion data) {
    return PeerDevice(
      id: data.id.present ? data.id.value : this.id,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      endpointId: data.endpointId.present
          ? data.endpointId.value
          : this.endpointId,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      contentSynced: data.contentSynced.present
          ? data.contentSynced.value
          : this.contentSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeerDevice(')
          ..write('id: $id, ')
          ..write('deviceName: $deviceName, ')
          ..write('endpointId: $endpointId, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('contentSynced: $contentSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceName, endpointId, lastSeenAt, contentSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeerDevice &&
          other.id == this.id &&
          other.deviceName == this.deviceName &&
          other.endpointId == this.endpointId &&
          other.lastSeenAt == this.lastSeenAt &&
          other.contentSynced == this.contentSynced);
}

class PeerDevicesCompanion extends UpdateCompanion<PeerDevice> {
  final Value<String> id;
  final Value<String> deviceName;
  final Value<String?> endpointId;
  final Value<int> lastSeenAt;
  final Value<String?> contentSynced;
  final Value<int> rowid;
  const PeerDevicesCompanion({
    this.id = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.endpointId = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.contentSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeerDevicesCompanion.insert({
    required String id,
    required String deviceName,
    this.endpointId = const Value.absent(),
    required int lastSeenAt,
    this.contentSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceName = Value(deviceName),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<PeerDevice> custom({
    Expression<String>? id,
    Expression<String>? deviceName,
    Expression<String>? endpointId,
    Expression<int>? lastSeenAt,
    Expression<String>? contentSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceName != null) 'device_name': deviceName,
      if (endpointId != null) 'endpoint_id': endpointId,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (contentSynced != null) 'content_synced': contentSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeerDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceName,
    Value<String?>? endpointId,
    Value<int>? lastSeenAt,
    Value<String?>? contentSynced,
    Value<int>? rowid,
  }) {
    return PeerDevicesCompanion(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      endpointId: endpointId ?? this.endpointId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      contentSynced: contentSynced ?? this.contentSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (endpointId.present) {
      map['endpoint_id'] = Variable<String>(endpointId.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (contentSynced.present) {
      map['content_synced'] = Variable<String>(contentSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeerDevicesCompanion(')
          ..write('id: $id, ')
          ..write('deviceName: $deviceName, ')
          ..write('endpointId: $endpointId, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('contentSynced: $contentSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedFileIdsMeta = const VerificationMeta(
    'linkedFileIds',
  );
  @override
  late final GeneratedColumn<String> linkedFileIds = GeneratedColumn<String>(
    'linked_file_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    linkedFileIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('linked_file_ids')) {
      context.handle(
        _linkedFileIdsMeta,
        linkedFileIds.isAcceptableOrUnknown(
          data['linked_file_ids']!,
          _linkedFileIdsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      linkedFileIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_file_ids'],
      )!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  final int id;
  final String name;
  final int createdAt;
  final int updatedAt;
  final String linkedFileIds;
  const ChatSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.linkedFileIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['linked_file_ids'] = Variable<String>(linkedFileIds);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      linkedFileIds: Value(linkedFileIds),
    );
  }

  factory ChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      linkedFileIds: serializer.fromJson<String>(json['linkedFileIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'linkedFileIds': serializer.toJson<String>(linkedFileIds),
    };
  }

  ChatSession copyWith({
    int? id,
    String? name,
    int? createdAt,
    int? updatedAt,
    String? linkedFileIds,
  }) => ChatSession(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    linkedFileIds: linkedFileIds ?? this.linkedFileIds,
  );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      linkedFileIds: data.linkedFileIds.present
          ? data.linkedFileIds.value
          : this.linkedFileIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('linkedFileIds: $linkedFileIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, createdAt, updatedAt, linkedFileIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.linkedFileIds == this.linkedFileIds);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> linkedFileIds;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.linkedFileIds = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int createdAt,
    required int updatedAt,
    this.linkedFileIds = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatSession> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? linkedFileIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (linkedFileIds != null) 'linked_file_ids': linkedFileIds,
    });
  }

  ChatSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? linkedFileIds,
  }) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      linkedFileIds: linkedFileIds ?? this.linkedFileIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (linkedFileIds.present) {
      map['linked_file_ids'] = Variable<String>(linkedFileIds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('linkedFileIds: $linkedFileIds')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceChunkIdMeta = const VerificationMeta(
    'sourceChunkId',
  );
  @override
  late final GeneratedColumn<String> sourceChunkId = GeneratedColumn<String>(
    'source_chunk_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    content,
    timestamp,
    sourceChunkId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
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
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('source_chunk_id')) {
      context.handle(
        _sourceChunkIdMeta,
        sourceChunkId.isAcceptableOrUnknown(
          data['source_chunk_id']!,
          _sourceChunkIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      sourceChunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_chunk_id'],
      ),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final int sessionId;
  final String role;
  final String content;
  final int timestamp;
  final String? sourceChunkId;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sourceChunkId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || sourceChunkId != null) {
      map['source_chunk_id'] = Variable<String>(sourceChunkId);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      timestamp: Value(timestamp),
      sourceChunkId: sourceChunkId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceChunkId),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      sourceChunkId: serializer.fromJson<String?>(json['sourceChunkId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<int>(timestamp),
      'sourceChunkId': serializer.toJson<String?>(sourceChunkId),
    };
  }

  ChatMessage copyWith({
    int? id,
    int? sessionId,
    String? role,
    String? content,
    int? timestamp,
    Value<String?> sourceChunkId = const Value.absent(),
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
    sourceChunkId: sourceChunkId.present
        ? sourceChunkId.value
        : this.sourceChunkId,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      sourceChunkId: data.sourceChunkId.present
          ? data.sourceChunkId.value
          : this.sourceChunkId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('sourceChunkId: $sourceChunkId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, role, content, timestamp, sourceChunkId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.sourceChunkId == this.sourceChunkId);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<int> timestamp;
  final Value<String?> sourceChunkId;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.sourceChunkId = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String role,
    required String content,
    required int timestamp,
    this.sourceChunkId = const Value.absent(),
  }) : sessionId = Value(sessionId),
       role = Value(role),
       content = Value(content),
       timestamp = Value(timestamp);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<int>? timestamp,
    Expression<String>? sourceChunkId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (sourceChunkId != null) 'source_chunk_id': sourceChunkId,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? role,
    Value<String>? content,
    Value<int>? timestamp,
    Value<String?>? sourceChunkId,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sourceChunkId: sourceChunkId ?? this.sourceChunkId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (sourceChunkId.present) {
      map['source_chunk_id'] = Variable<String>(sourceChunkId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('sourceChunkId: $sourceChunkId')
          ..write(')'))
        .toString();
  }
}

class $ManagedFilesTable extends ManagedFiles
    with TableInfo<$ManagedFilesTable, ManagedFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManagedFilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedAtMeta = const VerificationMeta(
    'uploadedAt',
  );
  @override
  late final GeneratedColumn<int> uploadedAt = GeneratedColumn<int>(
    'uploaded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extractedTextPreviewMeta =
      const VerificationMeta('extractedTextPreview');
  @override
  late final GeneratedColumn<String> extractedTextPreview =
      GeneratedColumn<String>(
        'extracted_text_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embeddingCountMeta = const VerificationMeta(
    'embeddingCount',
  );
  @override
  late final GeneratedColumn<int> embeddingCount = GeneratedColumn<int>(
    'embedding_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fileType,
    localPath,
    sizeBytes,
    uploadedAt,
    extractedTextPreview,
    thumbnailPath,
    embeddingCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'managed_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManagedFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
        _uploadedAtMeta,
        uploadedAt.isAcceptableOrUnknown(data['uploaded_at']!, _uploadedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_uploadedAtMeta);
    }
    if (data.containsKey('extracted_text_preview')) {
      context.handle(
        _extractedTextPreviewMeta,
        extractedTextPreview.isAcceptableOrUnknown(
          data['extracted_text_preview']!,
          _extractedTextPreviewMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('embedding_count')) {
      context.handle(
        _embeddingCountMeta,
        embeddingCount.isAcceptableOrUnknown(
          data['embedding_count']!,
          _embeddingCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ManagedFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManagedFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      uploadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded_at'],
      )!,
      extractedTextPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_text_preview'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      embeddingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}embedding_count'],
      )!,
    );
  }

  @override
  $ManagedFilesTable createAlias(String alias) {
    return $ManagedFilesTable(attachedDatabase, alias);
  }
}

class ManagedFile extends DataClass implements Insertable<ManagedFile> {
  final int id;
  final String name;
  final String fileType;
  final String localPath;
  final int sizeBytes;
  final int uploadedAt;
  final String? extractedTextPreview;
  final String? thumbnailPath;
  final int embeddingCount;
  const ManagedFile({
    required this.id,
    required this.name,
    required this.fileType,
    required this.localPath,
    required this.sizeBytes,
    required this.uploadedAt,
    this.extractedTextPreview,
    this.thumbnailPath,
    required this.embeddingCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['file_type'] = Variable<String>(fileType);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['uploaded_at'] = Variable<int>(uploadedAt);
    if (!nullToAbsent || extractedTextPreview != null) {
      map['extracted_text_preview'] = Variable<String>(extractedTextPreview);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['embedding_count'] = Variable<int>(embeddingCount);
    return map;
  }

  ManagedFilesCompanion toCompanion(bool nullToAbsent) {
    return ManagedFilesCompanion(
      id: Value(id),
      name: Value(name),
      fileType: Value(fileType),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      uploadedAt: Value(uploadedAt),
      extractedTextPreview: extractedTextPreview == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedTextPreview),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      embeddingCount: Value(embeddingCount),
    );
  }

  factory ManagedFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManagedFile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fileType: serializer.fromJson<String>(json['fileType']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      uploadedAt: serializer.fromJson<int>(json['uploadedAt']),
      extractedTextPreview: serializer.fromJson<String?>(
        json['extractedTextPreview'],
      ),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      embeddingCount: serializer.fromJson<int>(json['embeddingCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fileType': serializer.toJson<String>(fileType),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'uploadedAt': serializer.toJson<int>(uploadedAt),
      'extractedTextPreview': serializer.toJson<String?>(extractedTextPreview),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'embeddingCount': serializer.toJson<int>(embeddingCount),
    };
  }

  ManagedFile copyWith({
    int? id,
    String? name,
    String? fileType,
    String? localPath,
    int? sizeBytes,
    int? uploadedAt,
    Value<String?> extractedTextPreview = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    int? embeddingCount,
  }) => ManagedFile(
    id: id ?? this.id,
    name: name ?? this.name,
    fileType: fileType ?? this.fileType,
    localPath: localPath ?? this.localPath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    extractedTextPreview: extractedTextPreview.present
        ? extractedTextPreview.value
        : this.extractedTextPreview,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    embeddingCount: embeddingCount ?? this.embeddingCount,
  );
  ManagedFile copyWithCompanion(ManagedFilesCompanion data) {
    return ManagedFile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      uploadedAt: data.uploadedAt.present
          ? data.uploadedAt.value
          : this.uploadedAt,
      extractedTextPreview: data.extractedTextPreview.present
          ? data.extractedTextPreview.value
          : this.extractedTextPreview,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      embeddingCount: data.embeddingCount.present
          ? data.embeddingCount.value
          : this.embeddingCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManagedFile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileType: $fileType, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('extractedTextPreview: $extractedTextPreview, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('embeddingCount: $embeddingCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fileType,
    localPath,
    sizeBytes,
    uploadedAt,
    extractedTextPreview,
    thumbnailPath,
    embeddingCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagedFile &&
          other.id == this.id &&
          other.name == this.name &&
          other.fileType == this.fileType &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.uploadedAt == this.uploadedAt &&
          other.extractedTextPreview == this.extractedTextPreview &&
          other.thumbnailPath == this.thumbnailPath &&
          other.embeddingCount == this.embeddingCount);
}

class ManagedFilesCompanion extends UpdateCompanion<ManagedFile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> fileType;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<int> uploadedAt;
  final Value<String?> extractedTextPreview;
  final Value<String?> thumbnailPath;
  final Value<int> embeddingCount;
  const ManagedFilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fileType = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.extractedTextPreview = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.embeddingCount = const Value.absent(),
  });
  ManagedFilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String fileType,
    required String localPath,
    required int sizeBytes,
    required int uploadedAt,
    this.extractedTextPreview = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.embeddingCount = const Value.absent(),
  }) : name = Value(name),
       fileType = Value(fileType),
       localPath = Value(localPath),
       sizeBytes = Value(sizeBytes),
       uploadedAt = Value(uploadedAt);
  static Insertable<ManagedFile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? fileType,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<int>? uploadedAt,
    Expression<String>? extractedTextPreview,
    Expression<String>? thumbnailPath,
    Expression<int>? embeddingCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fileType != null) 'file_type': fileType,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (extractedTextPreview != null)
        'extracted_text_preview': extractedTextPreview,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (embeddingCount != null) 'embedding_count': embeddingCount,
    });
  }

  ManagedFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? fileType,
    Value<String>? localPath,
    Value<int>? sizeBytes,
    Value<int>? uploadedAt,
    Value<String?>? extractedTextPreview,
    Value<String?>? thumbnailPath,
    Value<int>? embeddingCount,
  }) {
    return ManagedFilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fileType: fileType ?? this.fileType,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      extractedTextPreview: extractedTextPreview ?? this.extractedTextPreview,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      embeddingCount: embeddingCount ?? this.embeddingCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<int>(uploadedAt.value);
    }
    if (extractedTextPreview.present) {
      map['extracted_text_preview'] = Variable<String>(
        extractedTextPreview.value,
      );
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (embeddingCount.present) {
      map['embedding_count'] = Variable<int>(embeddingCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManagedFilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileType: $fileType, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('extractedTextPreview: $extractedTextPreview, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('embeddingCount: $embeddingCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ContentItemsTable contentItems = $ContentItemsTable(this);
  late final $TranscriptsTable transcripts = $TranscriptsTable(this);
  late final $ImageInsightsTable imageInsights = $ImageInsightsTable(this);
  late final $EmbeddingsTable embeddings = $EmbeddingsTable(this);
  late final $EngagementSessionsTable engagementSessions =
      $EngagementSessionsTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $AIResponseCacheTable aIResponseCache = $AIResponseCacheTable(
    this,
  );
  late final $LeaderboardEntriesTable leaderboardEntries =
      $LeaderboardEntriesTable(this);
  late final $PeerDevicesTable peerDevices = $PeerDevicesTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $ManagedFilesTable managedFiles = $ManagedFilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    contentItems,
    transcripts,
    imageInsights,
    embeddings,
    engagementSessions,
    userProgress,
    aIResponseCache,
    leaderboardEntries,
    peerDevices,
    chatSessions,
    chatMessages,
    managedFiles,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String deviceId,
      required int createdAt,
      Value<String?> prefs,
      Value<bool> consentOnline,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<int> createdAt,
      Value<String?> prefs,
      Value<bool> consentOnline,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prefs => $composableBuilder(
    column: $table.prefs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get consentOnline => $composableBuilder(
    column: $table.consentOnline,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prefs => $composableBuilder(
    column: $table.prefs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get consentOnline => $composableBuilder(
    column: $table.consentOnline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get prefs =>
      $composableBuilder(column: $table.prefs, builder: (column) => column);

  GeneratedColumn<bool> get consentOnline => $composableBuilder(
    column: $table.consentOnline,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> prefs = const Value.absent(),
                Value<bool> consentOnline = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                prefs: prefs,
                consentOnline: consentOnline,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required int createdAt,
                Value<String?> prefs = const Value.absent(),
                Value<bool> consentOnline = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
                prefs: prefs,
                consentOnline: consentOnline,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$ContentItemsTableCreateCompanionBuilder =
    ContentItemsCompanion Function({
      required String id,
      required String title,
      required String type,
      required String filePath,
      Value<int> difficultyLevel,
      Value<String?> topicTags,
      Value<String?> subject,
      Value<String> language,
      Value<int?> fileSize,
      required int addedAt,
      Value<int> rowid,
    });
typedef $$ContentItemsTableUpdateCompanionBuilder =
    ContentItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> type,
      Value<String> filePath,
      Value<int> difficultyLevel,
      Value<String?> topicTags,
      Value<String?> subject,
      Value<String> language,
      Value<int?> fileSize,
      Value<int> addedAt,
      Value<int> rowid,
    });

class $$ContentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicTags => $composableBuilder(
    column: $table.topicTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicTags => $composableBuilder(
    column: $table.topicTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicTags =>
      $composableBuilder(column: $table.topicTags, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ContentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentItemsTable,
          ContentItem,
          $$ContentItemsTableFilterComposer,
          $$ContentItemsTableOrderingComposer,
          $$ContentItemsTableAnnotationComposer,
          $$ContentItemsTableCreateCompanionBuilder,
          $$ContentItemsTableUpdateCompanionBuilder,
          (
            ContentItem,
            BaseReferences<_$AppDatabase, $ContentItemsTable, ContentItem>,
          ),
          ContentItem,
          PrefetchHooks Function()
        > {
  $$ContentItemsTableTableManager(_$AppDatabase db, $ContentItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> difficultyLevel = const Value.absent(),
                Value<String?> topicTags = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsCompanion(
                id: id,
                title: title,
                type: type,
                filePath: filePath,
                difficultyLevel: difficultyLevel,
                topicTags: topicTags,
                subject: subject,
                language: language,
                fileSize: fileSize,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String type,
                required String filePath,
                Value<int> difficultyLevel = const Value.absent(),
                Value<String?> topicTags = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                required int addedAt,
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsCompanion.insert(
                id: id,
                title: title,
                type: type,
                filePath: filePath,
                difficultyLevel: difficultyLevel,
                topicTags: topicTags,
                subject: subject,
                language: language,
                fileSize: fileSize,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentItemsTable,
      ContentItem,
      $$ContentItemsTableFilterComposer,
      $$ContentItemsTableOrderingComposer,
      $$ContentItemsTableAnnotationComposer,
      $$ContentItemsTableCreateCompanionBuilder,
      $$ContentItemsTableUpdateCompanionBuilder,
      (
        ContentItem,
        BaseReferences<_$AppDatabase, $ContentItemsTable, ContentItem>,
      ),
      ContentItem,
      PrefetchHooks Function()
    >;
typedef $$TranscriptsTableCreateCompanionBuilder =
    TranscriptsCompanion Function({
      required String id,
      required String videoId,
      required String textChunk,
      required double startTime,
      required double endTime,
      Value<String> language,
      Value<int> rowid,
    });
typedef $$TranscriptsTableUpdateCompanionBuilder =
    TranscriptsCompanion Function({
      Value<String> id,
      Value<String> videoId,
      Value<String> textChunk,
      Value<double> startTime,
      Value<double> endTime,
      Value<String> language,
      Value<int> rowid,
    });

class $$TranscriptsTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptsTable> {
  $$TranscriptsTableFilterComposer({
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

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textChunk => $composableBuilder(
    column: $table.textChunk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranscriptsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptsTable> {
  $$TranscriptsTableOrderingComposer({
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

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textChunk => $composableBuilder(
    column: $table.textChunk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranscriptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptsTable> {
  $$TranscriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get textChunk =>
      $composableBuilder(column: $table.textChunk, builder: (column) => column);

  GeneratedColumn<double> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<double> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);
}

class $$TranscriptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranscriptsTable,
          Transcript,
          $$TranscriptsTableFilterComposer,
          $$TranscriptsTableOrderingComposer,
          $$TranscriptsTableAnnotationComposer,
          $$TranscriptsTableCreateCompanionBuilder,
          $$TranscriptsTableUpdateCompanionBuilder,
          (
            Transcript,
            BaseReferences<_$AppDatabase, $TranscriptsTable, Transcript>,
          ),
          Transcript,
          PrefetchHooks Function()
        > {
  $$TranscriptsTableTableManager(_$AppDatabase db, $TranscriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<String> textChunk = const Value.absent(),
                Value<double> startTime = const Value.absent(),
                Value<double> endTime = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptsCompanion(
                id: id,
                videoId: videoId,
                textChunk: textChunk,
                startTime: startTime,
                endTime: endTime,
                language: language,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String videoId,
                required String textChunk,
                required double startTime,
                required double endTime,
                Value<String> language = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptsCompanion.insert(
                id: id,
                videoId: videoId,
                textChunk: textChunk,
                startTime: startTime,
                endTime: endTime,
                language: language,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranscriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranscriptsTable,
      Transcript,
      $$TranscriptsTableFilterComposer,
      $$TranscriptsTableOrderingComposer,
      $$TranscriptsTableAnnotationComposer,
      $$TranscriptsTableCreateCompanionBuilder,
      $$TranscriptsTableUpdateCompanionBuilder,
      (
        Transcript,
        BaseReferences<_$AppDatabase, $TranscriptsTable, Transcript>,
      ),
      Transcript,
      PrefetchHooks Function()
    >;
typedef $$ImageInsightsTableCreateCompanionBuilder =
    ImageInsightsCompanion Function({
      required String id,
      required String contentId,
      Value<String?> imageType,
      Value<String?> caption,
      Value<String?> extractedConcepts,
      Value<String?> ocrText,
      required int processedAt,
      Value<int> rowid,
    });
typedef $$ImageInsightsTableUpdateCompanionBuilder =
    ImageInsightsCompanion Function({
      Value<String> id,
      Value<String> contentId,
      Value<String?> imageType,
      Value<String?> caption,
      Value<String?> extractedConcepts,
      Value<String?> ocrText,
      Value<int> processedAt,
      Value<int> rowid,
    });

class $$ImageInsightsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageInsightsTable> {
  $$ImageInsightsTableFilterComposer({
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

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageType => $composableBuilder(
    column: $table.imageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedConcepts => $composableBuilder(
    column: $table.extractedConcepts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImageInsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageInsightsTable> {
  $$ImageInsightsTableOrderingComposer({
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

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageType => $composableBuilder(
    column: $table.imageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedConcepts => $composableBuilder(
    column: $table.extractedConcepts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImageInsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageInsightsTable> {
  $$ImageInsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get imageType =>
      $composableBuilder(column: $table.imageType, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get extractedConcepts => $composableBuilder(
    column: $table.extractedConcepts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<int> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );
}

class $$ImageInsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageInsightsTable,
          ImageInsight,
          $$ImageInsightsTableFilterComposer,
          $$ImageInsightsTableOrderingComposer,
          $$ImageInsightsTableAnnotationComposer,
          $$ImageInsightsTableCreateCompanionBuilder,
          $$ImageInsightsTableUpdateCompanionBuilder,
          (
            ImageInsight,
            BaseReferences<_$AppDatabase, $ImageInsightsTable, ImageInsight>,
          ),
          ImageInsight,
          PrefetchHooks Function()
        > {
  $$ImageInsightsTableTableManager(_$AppDatabase db, $ImageInsightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageInsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageInsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageInsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contentId = const Value.absent(),
                Value<String?> imageType = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String?> extractedConcepts = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<int> processedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImageInsightsCompanion(
                id: id,
                contentId: contentId,
                imageType: imageType,
                caption: caption,
                extractedConcepts: extractedConcepts,
                ocrText: ocrText,
                processedAt: processedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contentId,
                Value<String?> imageType = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String?> extractedConcepts = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                required int processedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImageInsightsCompanion.insert(
                id: id,
                contentId: contentId,
                imageType: imageType,
                caption: caption,
                extractedConcepts: extractedConcepts,
                ocrText: ocrText,
                processedAt: processedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImageInsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageInsightsTable,
      ImageInsight,
      $$ImageInsightsTableFilterComposer,
      $$ImageInsightsTableOrderingComposer,
      $$ImageInsightsTableAnnotationComposer,
      $$ImageInsightsTableCreateCompanionBuilder,
      $$ImageInsightsTableUpdateCompanionBuilder,
      (
        ImageInsight,
        BaseReferences<_$AppDatabase, $ImageInsightsTable, ImageInsight>,
      ),
      ImageInsight,
      PrefetchHooks Function()
    >;
typedef $$EmbeddingsTableCreateCompanionBuilder =
    EmbeddingsCompanion Function({
      required String id,
      required String contentId,
      required int chunkIndex,
      required String chunkText,
      required Uint8List embedding,
      Value<String> model,
      Value<int> rowid,
    });
typedef $$EmbeddingsTableUpdateCompanionBuilder =
    EmbeddingsCompanion Function({
      Value<String> id,
      Value<String> contentId,
      Value<int> chunkIndex,
      Value<String> chunkText,
      Value<Uint8List> embedding,
      Value<String> model,
      Value<int> rowid,
    });

class $$EmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $EmbeddingsTable> {
  $$EmbeddingsTableFilterComposer({
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

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chunkText => $composableBuilder(
    column: $table.chunkText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmbeddingsTable> {
  $$EmbeddingsTableOrderingComposer({
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

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chunkText => $composableBuilder(
    column: $table.chunkText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmbeddingsTable> {
  $$EmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chunkText =>
      $composableBuilder(column: $table.chunkText, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);
}

class $$EmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmbeddingsTable,
          Embedding,
          $$EmbeddingsTableFilterComposer,
          $$EmbeddingsTableOrderingComposer,
          $$EmbeddingsTableAnnotationComposer,
          $$EmbeddingsTableCreateCompanionBuilder,
          $$EmbeddingsTableUpdateCompanionBuilder,
          (
            Embedding,
            BaseReferences<_$AppDatabase, $EmbeddingsTable, Embedding>,
          ),
          Embedding,
          PrefetchHooks Function()
        > {
  $$EmbeddingsTableTableManager(_$AppDatabase db, $EmbeddingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contentId = const Value.absent(),
                Value<int> chunkIndex = const Value.absent(),
                Value<String> chunkText = const Value.absent(),
                Value<Uint8List> embedding = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingsCompanion(
                id: id,
                contentId: contentId,
                chunkIndex: chunkIndex,
                chunkText: chunkText,
                embedding: embedding,
                model: model,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contentId,
                required int chunkIndex,
                required String chunkText,
                required Uint8List embedding,
                Value<String> model = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingsCompanion.insert(
                id: id,
                contentId: contentId,
                chunkIndex: chunkIndex,
                chunkText: chunkText,
                embedding: embedding,
                model: model,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmbeddingsTable,
      Embedding,
      $$EmbeddingsTableFilterComposer,
      $$EmbeddingsTableOrderingComposer,
      $$EmbeddingsTableAnnotationComposer,
      $$EmbeddingsTableCreateCompanionBuilder,
      $$EmbeddingsTableUpdateCompanionBuilder,
      (Embedding, BaseReferences<_$AppDatabase, $EmbeddingsTable, Embedding>),
      Embedding,
      PrefetchHooks Function()
    >;
typedef $$EngagementSessionsTableCreateCompanionBuilder =
    EngagementSessionsCompanion Function({
      required String id,
      required String userId,
      required String contentId,
      required String state,
      required int durationSeconds,
      Value<int> tapCount,
      Value<int> scrollEvents,
      Value<int> idleSeconds,
      required int startedAt,
      Value<int> rowid,
    });
typedef $$EngagementSessionsTableUpdateCompanionBuilder =
    EngagementSessionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> contentId,
      Value<String> state,
      Value<int> durationSeconds,
      Value<int> tapCount,
      Value<int> scrollEvents,
      Value<int> idleSeconds,
      Value<int> startedAt,
      Value<int> rowid,
    });

class $$EngagementSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $EngagementSessionsTable> {
  $$EngagementSessionsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tapCount => $composableBuilder(
    column: $table.tapCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scrollEvents => $composableBuilder(
    column: $table.scrollEvents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idleSeconds => $composableBuilder(
    column: $table.idleSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EngagementSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EngagementSessionsTable> {
  $$EngagementSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tapCount => $composableBuilder(
    column: $table.tapCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scrollEvents => $composableBuilder(
    column: $table.scrollEvents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idleSeconds => $composableBuilder(
    column: $table.idleSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EngagementSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EngagementSessionsTable> {
  $$EngagementSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tapCount =>
      $composableBuilder(column: $table.tapCount, builder: (column) => column);

  GeneratedColumn<int> get scrollEvents => $composableBuilder(
    column: $table.scrollEvents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get idleSeconds => $composableBuilder(
    column: $table.idleSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);
}

class $$EngagementSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EngagementSessionsTable,
          EngagementSession,
          $$EngagementSessionsTableFilterComposer,
          $$EngagementSessionsTableOrderingComposer,
          $$EngagementSessionsTableAnnotationComposer,
          $$EngagementSessionsTableCreateCompanionBuilder,
          $$EngagementSessionsTableUpdateCompanionBuilder,
          (
            EngagementSession,
            BaseReferences<
              _$AppDatabase,
              $EngagementSessionsTable,
              EngagementSession
            >,
          ),
          EngagementSession,
          PrefetchHooks Function()
        > {
  $$EngagementSessionsTableTableManager(
    _$AppDatabase db,
    $EngagementSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EngagementSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EngagementSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EngagementSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> contentId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> tapCount = const Value.absent(),
                Value<int> scrollEvents = const Value.absent(),
                Value<int> idleSeconds = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EngagementSessionsCompanion(
                id: id,
                userId: userId,
                contentId: contentId,
                state: state,
                durationSeconds: durationSeconds,
                tapCount: tapCount,
                scrollEvents: scrollEvents,
                idleSeconds: idleSeconds,
                startedAt: startedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String contentId,
                required String state,
                required int durationSeconds,
                Value<int> tapCount = const Value.absent(),
                Value<int> scrollEvents = const Value.absent(),
                Value<int> idleSeconds = const Value.absent(),
                required int startedAt,
                Value<int> rowid = const Value.absent(),
              }) => EngagementSessionsCompanion.insert(
                id: id,
                userId: userId,
                contentId: contentId,
                state: state,
                durationSeconds: durationSeconds,
                tapCount: tapCount,
                scrollEvents: scrollEvents,
                idleSeconds: idleSeconds,
                startedAt: startedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EngagementSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EngagementSessionsTable,
      EngagementSession,
      $$EngagementSessionsTableFilterComposer,
      $$EngagementSessionsTableOrderingComposer,
      $$EngagementSessionsTableAnnotationComposer,
      $$EngagementSessionsTableCreateCompanionBuilder,
      $$EngagementSessionsTableUpdateCompanionBuilder,
      (
        EngagementSession,
        BaseReferences<
          _$AppDatabase,
          $EngagementSessionsTable,
          EngagementSession
        >,
      ),
      EngagementSession,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      required String id,
      required String userId,
      required String contentId,
      Value<double> completionPct,
      required int lastAccessedAt,
      Value<int?> difficultyRating,
      Value<int> timeSpentSeconds,
      Value<int> rowid,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> contentId,
      Value<double> completionPct,
      Value<int> lastAccessedAt,
      Value<int?> difficultyRating,
      Value<int> timeSpentSeconds,
      Value<int> rowid,
    });

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get completionPct => $composableBuilder(
    column: $table.completionPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyRating => $composableBuilder(
    column: $table.difficultyRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSpentSeconds => $composableBuilder(
    column: $table.timeSpentSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get completionPct => $composableBuilder(
    column: $table.completionPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyRating => $composableBuilder(
    column: $table.difficultyRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSpentSeconds => $composableBuilder(
    column: $table.timeSpentSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<double> get completionPct => $composableBuilder(
    column: $table.completionPct,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficultyRating => $composableBuilder(
    column: $table.difficultyRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSpentSeconds => $composableBuilder(
    column: $table.timeSpentSeconds,
    builder: (column) => column,
  );
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          UserProgressData,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (
            UserProgressData,
            BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
          ),
          UserProgressData,
          PrefetchHooks Function()
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> contentId = const Value.absent(),
                Value<double> completionPct = const Value.absent(),
                Value<int> lastAccessedAt = const Value.absent(),
                Value<int?> difficultyRating = const Value.absent(),
                Value<int> timeSpentSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressCompanion(
                id: id,
                userId: userId,
                contentId: contentId,
                completionPct: completionPct,
                lastAccessedAt: lastAccessedAt,
                difficultyRating: difficultyRating,
                timeSpentSeconds: timeSpentSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String contentId,
                Value<double> completionPct = const Value.absent(),
                required int lastAccessedAt,
                Value<int?> difficultyRating = const Value.absent(),
                Value<int> timeSpentSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressCompanion.insert(
                id: id,
                userId: userId,
                contentId: contentId,
                completionPct: completionPct,
                lastAccessedAt: lastAccessedAt,
                difficultyRating: difficultyRating,
                timeSpentSeconds: timeSpentSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      UserProgressData,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (
        UserProgressData,
        BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
      ),
      UserProgressData,
      PrefetchHooks Function()
    >;
typedef $$AIResponseCacheTableCreateCompanionBuilder =
    AIResponseCacheCompanion Function({
      required String id,
      required String cacheKey,
      required String responseJson,
      required String source,
      Value<String?> model,
      required int createdAt,
      required int expiresAt,
      Value<int> rowid,
    });
typedef $$AIResponseCacheTableUpdateCompanionBuilder =
    AIResponseCacheCompanion Function({
      Value<String> id,
      Value<String> cacheKey,
      Value<String> responseJson,
      Value<String> source,
      Value<String?> model,
      Value<int> createdAt,
      Value<int> expiresAt,
      Value<int> rowid,
    });

class $$AIResponseCacheTableFilterComposer
    extends Composer<_$AppDatabase, $AIResponseCacheTable> {
  $$AIResponseCacheTableFilterComposer({
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

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AIResponseCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $AIResponseCacheTable> {
  $$AIResponseCacheTableOrderingComposer({
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

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AIResponseCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIResponseCacheTable> {
  $$AIResponseCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$AIResponseCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AIResponseCacheTable,
          AIResponseCacheData,
          $$AIResponseCacheTableFilterComposer,
          $$AIResponseCacheTableOrderingComposer,
          $$AIResponseCacheTableAnnotationComposer,
          $$AIResponseCacheTableCreateCompanionBuilder,
          $$AIResponseCacheTableUpdateCompanionBuilder,
          (
            AIResponseCacheData,
            BaseReferences<
              _$AppDatabase,
              $AIResponseCacheTable,
              AIResponseCacheData
            >,
          ),
          AIResponseCacheData,
          PrefetchHooks Function()
        > {
  $$AIResponseCacheTableTableManager(
    _$AppDatabase db,
    $AIResponseCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIResponseCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AIResponseCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AIResponseCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> responseJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AIResponseCacheCompanion(
                id: id,
                cacheKey: cacheKey,
                responseJson: responseJson,
                source: source,
                model: model,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cacheKey,
                required String responseJson,
                required String source,
                Value<String?> model = const Value.absent(),
                required int createdAt,
                required int expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => AIResponseCacheCompanion.insert(
                id: id,
                cacheKey: cacheKey,
                responseJson: responseJson,
                source: source,
                model: model,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AIResponseCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AIResponseCacheTable,
      AIResponseCacheData,
      $$AIResponseCacheTableFilterComposer,
      $$AIResponseCacheTableOrderingComposer,
      $$AIResponseCacheTableAnnotationComposer,
      $$AIResponseCacheTableCreateCompanionBuilder,
      $$AIResponseCacheTableUpdateCompanionBuilder,
      (
        AIResponseCacheData,
        BaseReferences<
          _$AppDatabase,
          $AIResponseCacheTable,
          AIResponseCacheData
        >,
      ),
      AIResponseCacheData,
      PrefetchHooks Function()
    >;
typedef $$LeaderboardEntriesTableCreateCompanionBuilder =
    LeaderboardEntriesCompanion Function({
      required String id,
      required String userId,
      required String displayName,
      Value<int> streakDays,
      Value<int> totalPoints,
      Value<int> weeklyPoints,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LeaderboardEntriesTableUpdateCompanionBuilder =
    LeaderboardEntriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> displayName,
      Value<int> streakDays,
      Value<int> totalPoints,
      Value<int> weeklyPoints,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$LeaderboardEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LeaderboardEntriesTable> {
  $$LeaderboardEntriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyPoints => $composableBuilder(
    column: $table.weeklyPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaderboardEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaderboardEntriesTable> {
  $$LeaderboardEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyPoints => $composableBuilder(
    column: $table.weeklyPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaderboardEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaderboardEntriesTable> {
  $$LeaderboardEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyPoints => $composableBuilder(
    column: $table.weeklyPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LeaderboardEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaderboardEntriesTable,
          LeaderboardEntry,
          $$LeaderboardEntriesTableFilterComposer,
          $$LeaderboardEntriesTableOrderingComposer,
          $$LeaderboardEntriesTableAnnotationComposer,
          $$LeaderboardEntriesTableCreateCompanionBuilder,
          $$LeaderboardEntriesTableUpdateCompanionBuilder,
          (
            LeaderboardEntry,
            BaseReferences<
              _$AppDatabase,
              $LeaderboardEntriesTable,
              LeaderboardEntry
            >,
          ),
          LeaderboardEntry,
          PrefetchHooks Function()
        > {
  $$LeaderboardEntriesTableTableManager(
    _$AppDatabase db,
    $LeaderboardEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaderboardEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaderboardEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeaderboardEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> totalPoints = const Value.absent(),
                Value<int> weeklyPoints = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardEntriesCompanion(
                id: id,
                userId: userId,
                displayName: displayName,
                streakDays: streakDays,
                totalPoints: totalPoints,
                weeklyPoints: weeklyPoints,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String displayName,
                Value<int> streakDays = const Value.absent(),
                Value<int> totalPoints = const Value.absent(),
                Value<int> weeklyPoints = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardEntriesCompanion.insert(
                id: id,
                userId: userId,
                displayName: displayName,
                streakDays: streakDays,
                totalPoints: totalPoints,
                weeklyPoints: weeklyPoints,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaderboardEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaderboardEntriesTable,
      LeaderboardEntry,
      $$LeaderboardEntriesTableFilterComposer,
      $$LeaderboardEntriesTableOrderingComposer,
      $$LeaderboardEntriesTableAnnotationComposer,
      $$LeaderboardEntriesTableCreateCompanionBuilder,
      $$LeaderboardEntriesTableUpdateCompanionBuilder,
      (
        LeaderboardEntry,
        BaseReferences<
          _$AppDatabase,
          $LeaderboardEntriesTable,
          LeaderboardEntry
        >,
      ),
      LeaderboardEntry,
      PrefetchHooks Function()
    >;
typedef $$PeerDevicesTableCreateCompanionBuilder =
    PeerDevicesCompanion Function({
      required String id,
      required String deviceName,
      Value<String?> endpointId,
      required int lastSeenAt,
      Value<String?> contentSynced,
      Value<int> rowid,
    });
typedef $$PeerDevicesTableUpdateCompanionBuilder =
    PeerDevicesCompanion Function({
      Value<String> id,
      Value<String> deviceName,
      Value<String?> endpointId,
      Value<int> lastSeenAt,
      Value<String?> contentSynced,
      Value<int> rowid,
    });

class $$PeerDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $PeerDevicesTable> {
  $$PeerDevicesTableFilterComposer({
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

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpointId => $composableBuilder(
    column: $table.endpointId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentSynced => $composableBuilder(
    column: $table.contentSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeerDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $PeerDevicesTable> {
  $$PeerDevicesTableOrderingComposer({
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

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpointId => $composableBuilder(
    column: $table.endpointId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentSynced => $composableBuilder(
    column: $table.contentSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeerDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeerDevicesTable> {
  $$PeerDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpointId => $composableBuilder(
    column: $table.endpointId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentSynced => $composableBuilder(
    column: $table.contentSynced,
    builder: (column) => column,
  );
}

class $$PeerDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeerDevicesTable,
          PeerDevice,
          $$PeerDevicesTableFilterComposer,
          $$PeerDevicesTableOrderingComposer,
          $$PeerDevicesTableAnnotationComposer,
          $$PeerDevicesTableCreateCompanionBuilder,
          $$PeerDevicesTableUpdateCompanionBuilder,
          (
            PeerDevice,
            BaseReferences<_$AppDatabase, $PeerDevicesTable, PeerDevice>,
          ),
          PeerDevice,
          PrefetchHooks Function()
        > {
  $$PeerDevicesTableTableManager(_$AppDatabase db, $PeerDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeerDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeerDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeerDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<String?> endpointId = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<String?> contentSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerDevicesCompanion(
                id: id,
                deviceName: deviceName,
                endpointId: endpointId,
                lastSeenAt: lastSeenAt,
                contentSynced: contentSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceName,
                Value<String?> endpointId = const Value.absent(),
                required int lastSeenAt,
                Value<String?> contentSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerDevicesCompanion.insert(
                id: id,
                deviceName: deviceName,
                endpointId: endpointId,
                lastSeenAt: lastSeenAt,
                contentSynced: contentSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeerDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeerDevicesTable,
      PeerDevice,
      $$PeerDevicesTableFilterComposer,
      $$PeerDevicesTableOrderingComposer,
      $$PeerDevicesTableAnnotationComposer,
      $$PeerDevicesTableCreateCompanionBuilder,
      $$PeerDevicesTableUpdateCompanionBuilder,
      (
        PeerDevice,
        BaseReferences<_$AppDatabase, $PeerDevicesTable, PeerDevice>,
      ),
      PeerDevice,
      PrefetchHooks Function()
    >;
typedef $$ChatSessionsTableCreateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<int> id,
      required String name,
      required int createdAt,
      required int updatedAt,
      Value<String> linkedFileIds,
    });
typedef $$ChatSessionsTableUpdateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> linkedFileIds,
    });

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedFileIds => $composableBuilder(
    column: $table.linkedFileIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedFileIds => $composableBuilder(
    column: $table.linkedFileIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get linkedFileIds => $composableBuilder(
    column: $table.linkedFileIds,
    builder: (column) => column,
  );
}

class $$ChatSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatSessionsTable,
          ChatSession,
          $$ChatSessionsTableFilterComposer,
          $$ChatSessionsTableOrderingComposer,
          $$ChatSessionsTableAnnotationComposer,
          $$ChatSessionsTableCreateCompanionBuilder,
          $$ChatSessionsTableUpdateCompanionBuilder,
          (
            ChatSession,
            BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession>,
          ),
          ChatSession,
          PrefetchHooks Function()
        > {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> linkedFileIds = const Value.absent(),
              }) => ChatSessionsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                linkedFileIds: linkedFileIds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int createdAt,
                required int updatedAt,
                Value<String> linkedFileIds = const Value.absent(),
              }) => ChatSessionsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                linkedFileIds: linkedFileIds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatSessionsTable,
      ChatSession,
      $$ChatSessionsTableFilterComposer,
      $$ChatSessionsTableOrderingComposer,
      $$ChatSessionsTableAnnotationComposer,
      $$ChatSessionsTableCreateCompanionBuilder,
      $$ChatSessionsTableUpdateCompanionBuilder,
      (
        ChatSession,
        BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession>,
      ),
      ChatSession,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required int sessionId,
      required String role,
      required String content,
      required int timestamp,
      Value<String?> sourceChunkId,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> role,
      Value<String> content,
      Value<int> timestamp,
      Value<String?> sourceChunkId,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
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

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceChunkId => $composableBuilder(
    column: $table.sourceChunkId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
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

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceChunkId => $composableBuilder(
    column: $table.sourceChunkId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get sourceChunkId => $composableBuilder(
    column: $table.sourceChunkId,
    builder: (column) => column,
  );
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String?> sourceChunkId = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                timestamp: timestamp,
                sourceChunkId: sourceChunkId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String role,
                required String content,
                required int timestamp,
                Value<String?> sourceChunkId = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                timestamp: timestamp,
                sourceChunkId: sourceChunkId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$ManagedFilesTableCreateCompanionBuilder =
    ManagedFilesCompanion Function({
      Value<int> id,
      required String name,
      required String fileType,
      required String localPath,
      required int sizeBytes,
      required int uploadedAt,
      Value<String?> extractedTextPreview,
      Value<String?> thumbnailPath,
      Value<int> embeddingCount,
    });
typedef $$ManagedFilesTableUpdateCompanionBuilder =
    ManagedFilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> fileType,
      Value<String> localPath,
      Value<int> sizeBytes,
      Value<int> uploadedAt,
      Value<String?> extractedTextPreview,
      Value<String?> thumbnailPath,
      Value<int> embeddingCount,
    });

class $$ManagedFilesTableFilterComposer
    extends Composer<_$AppDatabase, $ManagedFilesTable> {
  $$ManagedFilesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedTextPreview => $composableBuilder(
    column: $table.extractedTextPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get embeddingCount => $composableBuilder(
    column: $table.embeddingCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ManagedFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ManagedFilesTable> {
  $$ManagedFilesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedTextPreview => $composableBuilder(
    column: $table.extractedTextPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get embeddingCount => $composableBuilder(
    column: $table.embeddingCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManagedFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManagedFilesTable> {
  $$ManagedFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractedTextPreview => $composableBuilder(
    column: $table.extractedTextPreview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get embeddingCount => $composableBuilder(
    column: $table.embeddingCount,
    builder: (column) => column,
  );
}

class $$ManagedFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManagedFilesTable,
          ManagedFile,
          $$ManagedFilesTableFilterComposer,
          $$ManagedFilesTableOrderingComposer,
          $$ManagedFilesTableAnnotationComposer,
          $$ManagedFilesTableCreateCompanionBuilder,
          $$ManagedFilesTableUpdateCompanionBuilder,
          (
            ManagedFile,
            BaseReferences<_$AppDatabase, $ManagedFilesTable, ManagedFile>,
          ),
          ManagedFile,
          PrefetchHooks Function()
        > {
  $$ManagedFilesTableTableManager(_$AppDatabase db, $ManagedFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManagedFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManagedFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManagedFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> uploadedAt = const Value.absent(),
                Value<String?> extractedTextPreview = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> embeddingCount = const Value.absent(),
              }) => ManagedFilesCompanion(
                id: id,
                name: name,
                fileType: fileType,
                localPath: localPath,
                sizeBytes: sizeBytes,
                uploadedAt: uploadedAt,
                extractedTextPreview: extractedTextPreview,
                thumbnailPath: thumbnailPath,
                embeddingCount: embeddingCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String fileType,
                required String localPath,
                required int sizeBytes,
                required int uploadedAt,
                Value<String?> extractedTextPreview = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> embeddingCount = const Value.absent(),
              }) => ManagedFilesCompanion.insert(
                id: id,
                name: name,
                fileType: fileType,
                localPath: localPath,
                sizeBytes: sizeBytes,
                uploadedAt: uploadedAt,
                extractedTextPreview: extractedTextPreview,
                thumbnailPath: thumbnailPath,
                embeddingCount: embeddingCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManagedFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManagedFilesTable,
      ManagedFile,
      $$ManagedFilesTableFilterComposer,
      $$ManagedFilesTableOrderingComposer,
      $$ManagedFilesTableAnnotationComposer,
      $$ManagedFilesTableCreateCompanionBuilder,
      $$ManagedFilesTableUpdateCompanionBuilder,
      (
        ManagedFile,
        BaseReferences<_$AppDatabase, $ManagedFilesTable, ManagedFile>,
      ),
      ManagedFile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ContentItemsTableTableManager get contentItems =>
      $$ContentItemsTableTableManager(_db, _db.contentItems);
  $$TranscriptsTableTableManager get transcripts =>
      $$TranscriptsTableTableManager(_db, _db.transcripts);
  $$ImageInsightsTableTableManager get imageInsights =>
      $$ImageInsightsTableTableManager(_db, _db.imageInsights);
  $$EmbeddingsTableTableManager get embeddings =>
      $$EmbeddingsTableTableManager(_db, _db.embeddings);
  $$EngagementSessionsTableTableManager get engagementSessions =>
      $$EngagementSessionsTableTableManager(_db, _db.engagementSessions);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$AIResponseCacheTableTableManager get aIResponseCache =>
      $$AIResponseCacheTableTableManager(_db, _db.aIResponseCache);
  $$LeaderboardEntriesTableTableManager get leaderboardEntries =>
      $$LeaderboardEntriesTableTableManager(_db, _db.leaderboardEntries);
  $$PeerDevicesTableTableManager get peerDevices =>
      $$PeerDevicesTableTableManager(_db, _db.peerDevices);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$ManagedFilesTableTableManager get managedFiles =>
      $$ManagedFilesTableTableManager(_db, _db.managedFiles);
}
