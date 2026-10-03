import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import '../models/grammar_microscope.dart';
import 'grammar_hub_service.dart';
import 'pack_database_security.dart';

/// Reads grammar from an admitted active-pack SQLite database when that
/// database exposes the Phase-1 compatibility tables. Until Phase 2 compiles
/// canonical grammar into those tables, embedded grammar is the fail-safe.
final class PackGrammarHubRepository
    implements GrammarHubRepository, GrammarMicroscopeRepository {
  PackGrammarHubRepository({
    required this.databasePath,
    required this.packId,
    required GrammarHubRepository fallback,
    required PackDatabaseOpener databaseOpener,
    required String databasePassword,
  })  : _fallback = fallback,
        _databaseOpener = databaseOpener,
        _databasePassword = databasePassword;

  final String databasePath;
  final String packId;
  final GrammarHubRepository _fallback;
  final PackDatabaseOpener _databaseOpener;
  final String _databasePassword;
  final Set<String> _mastered = <String>{};

  Database? _database;
  bool? _compatibleSchema;
  bool? _microscopeCompatibleSchema;

  Future<Database> get _db async {
    final current = _database;
    if (current != null) return current;
    _database = await _databaseOpener.openReadOnly(
      databasePath,
      password: _databasePassword,
    );
    return _database!;
  }

  Future<bool> _hasCompatibleSchema() async {
    final cached = _compatibleSchema;
    if (cached != null) return cached;
    try {
      final db = await _db;
      final topicColumns = await db.rawQuery(
        'PRAGMA table_info(grammar_topics)',
      );
      final quizColumns = await db.rawQuery(
        'PRAGMA table_info(grammar_quizzes)',
      );
      final topicNames =
          topicColumns.map((row) => row['name']?.toString() ?? '').toSet();
      final quizNames =
          quizColumns.map((row) => row['name']?.toString() ?? '').toSet();
      const requiredTopics = <String>{
        'id',
        'level',
        'title_de',
        'title_ar',
        'explanation_markdown',
        'formula_pattern',
        'order_index',
      };
      const requiredQuizzes = <String>{
        'id',
        'topic_id',
        'question',
        'options_json',
        'correct_index',
        'explanation',
      };
      _compatibleSchema = topicNames.containsAll(requiredTopics) &&
          quizNames.containsAll(requiredQuizzes);
    } on Object {
      _compatibleSchema = false;
    }
    return _compatibleSchema!;
  }

  Future<bool> _hasMicroscopeSchema() async {
    final cached = _microscopeCompatibleSchema;
    if (cached != null) return cached;
    if (!await _hasCompatibleSchema()) {
      _microscopeCompatibleSchema = false;
      return false;
    }
    try {
      final db = await _db;
      final ruleColumns = await _columnNames(db, 'grammar_rules');
      final rowColumns = await _columnNames(db, 'grammar_rule_rows');
      final exampleColumns = await _columnNames(db, 'grammar_examples');
      _microscopeCompatibleSchema = ruleColumns.containsAll(const <String>{
            'id',
            'topic_id',
            'title',
            'explanation_ar',
            'order_index',
          }) &&
          rowColumns.containsAll(const <String>{
            'rule_id',
            'row_index',
            'cells_json',
          }) &&
          exampleColumns.containsAll(const <String>{
            'rule_id',
            'example_index',
            'german',
            'arabic',
          });
    } on Object {
      _microscopeCompatibleSchema = false;
    }
    return _microscopeCompatibleSchema!;
  }

  Future<Set<String>> _columnNames(Database db, String table) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.map((row) => row['name']?.toString() ?? '').toSet();
  }

  GrammarTopic _topic(Map<String, Object?> row) =>
      GrammarTopic.fromMap(<String, dynamic>{
        ...row,
        'is_mastered': _mastered.contains(row['id']?.toString()) ? 1 : 0,
      });

  @override
  Future<List<GrammarTopic>> getTopicsByLevel(String level) async {
    if (!await _hasCompatibleSchema()) {
      return _fallback.getTopicsByLevel(level);
    }
    try {
      final rows = await (await _db).query(
        'grammar_topics',
        where: 'level = ?',
        whereArgs: <Object?>[level],
        orderBy: 'order_index ASC',
        limit: 200,
      );
      return rows.map(_topic).toList(growable: false);
    } on Object {
      return _fallback.getTopicsByLevel(level);
    }
  }

  @override
  Future<GrammarTopic?> getTopicDetail(String topicId) async {
    if (!await _hasCompatibleSchema()) {
      return _fallback.getTopicDetail(topicId);
    }
    try {
      final rows = await (await _db).query(
        'grammar_topics',
        where: 'id = ?',
        whereArgs: <Object?>[topicId],
        limit: 1,
      );
      return rows.isEmpty ? null : _topic(rows.first);
    } on Object {
      return _fallback.getTopicDetail(topicId);
    }
  }

  @override
  Future<List<GrammarQuiz>> getQuizzesForTopic(String topicId) async {
    if (!await _hasCompatibleSchema()) {
      return _fallback.getQuizzesForTopic(topicId);
    }
    try {
      final rows = await (await _db).query(
        'grammar_quizzes',
        where: 'topic_id = ?',
        whereArgs: <Object?>[topicId],
        orderBy: 'id ASC',
        limit: 200,
      );
      return rows
          .map((row) => GrammarQuiz.fromMap(Map<String, dynamic>.from(row)))
          .toList(growable: false);
    } on Object {
      return _fallback.getQuizzesForTopic(topicId);
    }
  }

  @override
  Future<List<GrammarRuleDetail>> getRulesForTopic(String topicId) async {
    final safeTopicId = topicId.trim();
    if (safeTopicId.isEmpty || safeTopicId.length > 160) {
      return const <GrammarRuleDetail>[];
    }
    if (!await _hasMicroscopeSchema()) {
      final fallback = _fallback;
      if (fallback is GrammarMicroscopeRepository) {
        return (fallback as GrammarMicroscopeRepository).getRulesForTopic(
          safeTopicId,
        );
      }
      return const <GrammarRuleDetail>[];
    }

    try {
      final db = await _db;
      final rules = await db.query(
        'grammar_rules',
        where: 'topic_id = ?',
        whereArgs: <Object?>[safeTopicId],
        orderBy: 'order_index ASC',
        limit: 100,
      );
      final result = <GrammarRuleDetail>[];
      for (final row in rules) {
        final ruleId = _boundedText(row['id'], maxLength: 160);
        if (ruleId.isEmpty) continue;
        final tableRows = await db.query(
          'grammar_rule_rows',
          where: 'rule_id = ?',
          whereArgs: <Object?>[ruleId],
          orderBy: 'row_index ASC',
          limit: 100,
        );
        final examples = await db.query(
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
            examples: examples
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
    } on Object {
      final fallback = _fallback;
      if (fallback is GrammarMicroscopeRepository) {
        return (fallback as GrammarMicroscopeRepository).getRulesForTopic(
          safeTopicId,
        );
      }
      return const <GrammarRuleDetail>[];
    }
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

  @override
  Future<void> saveTopicMastery(String topicId, bool mastered) async {
    if (!await _hasCompatibleSchema()) {
      await _fallback.saveTopicMastery(topicId, mastered);
      return;
    }
    if (mastered) {
      _mastered.add(topicId);
    } else {
      _mastered.remove(topicId);
    }
  }

  @override
  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) {
      await db.close();
    }
    await _fallback.close();
  }
}
