import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import '../models/grammar_microscope.dart';
import 'canonical_grammar_compiler.dart';
import 'sqlite_policy.dart';

class GrammarTopic {
  final String id;
  final String level;
  final String titleDe;
  final String titleAr;
  final String explanationMarkdown;
  final String? formulaPattern;
  final int orderIndex;
  final bool isMastered;

  GrammarTopic({
    required this.id,
    required this.level,
    required this.titleDe,
    required this.titleAr,
    required this.explanationMarkdown,
    this.formulaPattern,
    required this.orderIndex,
    this.isMastered = false,
  });

  factory GrammarTopic.fromMap(Map<String, dynamic> map) {
    return GrammarTopic(
      id: map['id'] as String,
      level: map['level'] as String,
      titleDe: map['title_de'] as String,
      titleAr: map['title_ar'] as String,
      explanationMarkdown: map['explanation_markdown'] as String,
      formulaPattern: map['formula_pattern'] as String?,
      orderIndex: map['order_index'] as int,
      isMastered: (map['is_mastered'] as int? ?? 0) == 1,
    );
  }
}

class GrammarQuiz {
  final int? id;
  final String topicId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  GrammarQuiz({
    this.id,
    required this.topicId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory GrammarQuiz.fromMap(Map<String, dynamic> map) {
    return GrammarQuiz(
      id: map['id'] as int?,
      topicId: map['topic_id'] as String,
      question: map['question'] as String,
      options: List<String>.from(json.decode(map['options_json'] as String)),
      correctIndex: map['correct_index'] as int,
      explanation: map['explanation'] as String,
    );
  }
}

abstract interface class GrammarHubRepository {
  Future<List<GrammarTopic>> getTopicsByLevel(String level);
  Future<GrammarTopic?> getTopicDetail(String topicId);
  Future<List<GrammarQuiz>> getQuizzesForTopic(String topicId);
  Future<void> saveTopicMastery(String topicId, bool mastered);
  Future<void> close();
}

/// Optional detailed grammar capability used by the Phase 13 microscope.
/// Keeping this separate preserves compatibility with lightweight hub fakes.
abstract interface class GrammarMicroscopeRepository {
  Future<List<GrammarRuleDetail>> getRulesForTopic(String topicId);
}

class GrammarHubService
    implements GrammarHubRepository, GrammarMicroscopeRepository {
  static const String _dbName = 'grammar_hub.db';
  Database? _db;
  final AppSqlitePolicy _sqlitePolicy;
  final String? _inMemoryPath;

  GrammarHubService({DatabaseFactory? factory, String? path})
      : _sqlitePolicy = AppSqlitePolicy(factory: factory),
        _inMemoryPath = path;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = await _sqlitePolicy.resolvePath(
      fileName: _dbName,
      overridePath: _inMemoryPath,
    );
    return _sqlitePolicy.openWritable(
      path: path,
      version: CanonicalGrammarCompiler.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await CanonicalGrammarCompiler.rebuild(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < CanonicalGrammarCompiler.databaseVersion) {
      await CanonicalGrammarCompiler.rebuild(db);
    }
  }

  Future<List<GrammarTopic>> getTopicsByLevel(String level) async {
    final db = await database;
    final maps = await db.query(
      'grammar_topic_runtime',
      where: 'level = ?',
      whereArgs: [level],
      orderBy: 'order_index ASC',
    );
    return maps.map((e) => GrammarTopic.fromMap(e)).toList();
  }

  Future<GrammarTopic?> getTopicDetail(String topicId) async {
    final db = await database;
    final maps = await db.query(
      'grammar_topic_runtime',
      where: 'id = ?',
      whereArgs: [topicId],
    );
    if (maps.isNotEmpty) {
      return GrammarTopic.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GrammarQuiz>> getQuizzesForTopic(String topicId) async {
    final db = await database;
    final maps = await db.query(
      'grammar_quizzes',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
    return maps.map((e) => GrammarQuiz.fromMap(e)).toList();
  }

  @override
  Future<List<GrammarRuleDetail>> getRulesForTopic(String topicId) async {
    final safeTopicId = topicId.trim();
    if (safeTopicId.isEmpty || safeTopicId.length > 160) {
      return const <GrammarRuleDetail>[];
    }

    final db = await database;
    final ruleRows = await db.query(
      'grammar_rules',
      where: 'topic_id = ?',
      whereArgs: <Object?>[safeTopicId],
      orderBy: 'order_index ASC',
      limit: 100,
    );
    final result = <GrammarRuleDetail>[];

    for (final row in ruleRows) {
      final ruleId = _boundedText(row['id'], maxLength: 160);
      if (ruleId.isEmpty) continue;
      final tableRows = await db.query(
        'grammar_rule_rows',
        where: 'rule_id = ?',
        whereArgs: <Object?>[ruleId],
        orderBy: 'row_index ASC',
        limit: 100,
      );
      final exampleRows = await db.query(
        'grammar_examples',
        where: 'rule_id = ?',
        whereArgs: <Object?>[ruleId],
        orderBy: 'example_index ASC',
        limit: 100,
      );

      result.add(
        GrammarRuleDetail(
          id: ruleId,
          topicId: safeTopicId,
          title: _boundedText(row['title']),
          explanationAr: _boundedText(row['explanation_ar']),
          orderIndex: _safeInt(row['order_index']),
          table: tableRows
              .map((entry) => _decodeCells(entry['cells_json']))
              .where((cells) => cells.isNotEmpty)
              .toList(growable: false),
          examples: exampleRows
              .map(
                (entry) => GrammarExampleDetail(
                  german: _boundedText(entry['german']),
                  arabic: _boundedText(entry['arabic']),
                ),
              )
              .where(
                (example) =>
                    example.german.isNotEmpty || example.arabic.isNotEmpty,
              )
              .toList(growable: false),
        ),
      );
    }
    return List<GrammarRuleDetail>.unmodifiable(result);
  }

  static List<String> _decodeCells(Object? raw) {
    if (raw is! String || raw.length > 64 * 1024) {
      return const <String>[];
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is! List) return const <String>[];
      return decoded
          .map((value) => _boundedText(value))
          .where((value) => value.isNotEmpty)
          .take(16)
          .toList(growable: false);
    } on Object {
      return const <String>[];
    }
  }

  static String _boundedText(Object? raw, {int maxLength = 4000}) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return '';
    return value.length <= maxLength ? value : value.substring(0, maxLength);
  }

  static int _safeInt(Object? raw) =>
      raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '') ?? 0;

  Future<void> saveTopicMastery(String topicId, bool mastered) async {
    final db = await database;
    await db.update(
      'grammar_topics',
      {'is_mastered': mastered ? 1 : 0},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
