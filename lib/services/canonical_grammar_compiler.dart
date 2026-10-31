import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../data/canonical_grammar_catalog.dart';
import '../models/grammar.dart' as canonical;
import 'linguistics/german_linguistic_validator.dart';

/// Compiles the single authored grammar catalog into the runtime SQLite model.
///
/// Rebuilds preserve mastery for stable topic IDs while removing stale seed
/// rows, so SQLite never becomes a second independently authored source.
abstract final class CanonicalGrammarCompiler {
  static const int databaseVersion = 2;

  static const List<String> createStatements = <String>[
    '''
CREATE TABLE IF NOT EXISTS grammar_topics (
  id TEXT PRIMARY KEY,
  level TEXT NOT NULL,
  title_de TEXT NOT NULL,
  title_ar TEXT NOT NULL,
  explanation_markdown TEXT NOT NULL,
  formula_pattern TEXT,
  order_index INTEGER NOT NULL,
  is_mastered INTEGER NOT NULL DEFAULT 0 CHECK (is_mastered IN (0, 1))
)
''',
    '''
CREATE TABLE IF NOT EXISTS grammar_rules (
  id TEXT PRIMARY KEY,
  topic_id TEXT NOT NULL
    REFERENCES grammar_topics(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  explanation_ar TEXT NOT NULL,
  order_index INTEGER NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS grammar_rule_rows (
  rule_id TEXT NOT NULL
    REFERENCES grammar_rules(id) ON DELETE CASCADE,
  row_index INTEGER NOT NULL,
  cells_json TEXT NOT NULL,
  PRIMARY KEY (rule_id, row_index)
)
''',
    '''
CREATE TABLE IF NOT EXISTS grammar_examples (
  rule_id TEXT NOT NULL
    REFERENCES grammar_rules(id) ON DELETE CASCADE,
  example_index INTEGER NOT NULL,
  german TEXT NOT NULL,
  arabic TEXT NOT NULL,
  PRIMARY KEY (rule_id, example_index)
)
''',
    '''
CREATE TABLE IF NOT EXISTS grammar_quizzes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  canonical_id TEXT NOT NULL UNIQUE,
  topic_id TEXT NOT NULL
    REFERENCES grammar_topics(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options_json TEXT NOT NULL,
  correct_index INTEGER NOT NULL,
  explanation TEXT NOT NULL
)
''',
    'CREATE INDEX IF NOT EXISTS idx_grammar_topics_level '
        'ON grammar_topics(level, order_index)',
    'CREATE INDEX IF NOT EXISTS idx_grammar_rules_topic '
        'ON grammar_rules(topic_id, order_index)',
    'CREATE INDEX IF NOT EXISTS idx_grammar_quizzes_topic '
        'ON grammar_quizzes(topic_id, id)',
    '''
CREATE VIEW IF NOT EXISTS grammar_topic_runtime AS
SELECT
  id,
  level,
  title_de,
  title_ar,
  explanation_markdown,
  formula_pattern,
  order_index,
  is_mastered
FROM grammar_topics
''',
  ];

  static Future<void> rebuild(Database db) async {
    const GermanLinguisticValidator().validateCanonicalGrammar().throwIfInvalid(
          context: 'canonical grammar catalog',
        );
    await db.execute('PRAGMA foreign_keys = ON');
    final mastered = await _existingMastery(db);

    await db.transaction((txn) async {
      // Old v1 grammar_quizzes lacks canonical_id. Recreate child tables
      // instead of mutating a partially compatible schema in place.
      await txn.execute('DROP VIEW IF EXISTS grammar_topic_runtime');
      await txn.execute('DROP TABLE IF EXISTS grammar_examples');
      await txn.execute('DROP TABLE IF EXISTS grammar_rule_rows');
      await txn.execute('DROP TABLE IF EXISTS grammar_rules');
      await txn.execute('DROP TABLE IF EXISTS grammar_quizzes');

      for (final statement in createStatements) {
        await txn.execute(statement);
      }
      await txn.delete('grammar_topics');

      final orderByLevel = <String, int>{};
      for (final topic in CanonicalGrammarCatalog.allTopics) {
        final nextOrder = (orderByLevel[topic.level] ?? 0) + 1;
        orderByLevel[topic.level] = nextOrder;
        await _insertTopic(
          txn,
          topic,
          orderIndex: nextOrder,
          mastered: mastered.contains(topic.id),
        );
      }
    });
  }

  static Future<Set<String>> _existingMastery(Database db) async {
    final tables = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      <Object?>['table', 'grammar_topics'],
    );
    if (tables.isEmpty) return <String>{};
    final rows = await db.query(
      'grammar_topics',
      columns: const <String>['id'],
      where: 'is_mastered = ?',
      whereArgs: const <Object?>[1],
    );
    return rows.map((row) => row['id'].toString()).toSet();
  }

  static Future<void> _insertTopic(
    DatabaseExecutor db,
    canonical.GrammarTopic topic, {
    required int orderIndex,
    required bool mastered,
  }) async {
    await db.insert('grammar_topics', <String, Object?>{
      'id': topic.id,
      'level': topic.level,
      'title_de': topic.titleDe,
      'title_ar': topic.titleAr,
      'explanation_markdown': topic.summaryAr,
      'formula_pattern': _formula(topic),
      'order_index': orderIndex,
      'is_mastered': mastered ? 1 : 0,
    });

    for (var ruleIndex = 0; ruleIndex < topic.rules.length; ruleIndex++) {
      final rule = topic.rules[ruleIndex];
      await db.insert('grammar_rules', <String, Object?>{
        'id': rule.id,
        'topic_id': topic.id,
        'title': rule.title,
        'explanation_ar': rule.explanationAr,
        'order_index': ruleIndex + 1,
      });

      for (var rowIndex = 0; rowIndex < rule.table.length; rowIndex++) {
        await db.insert('grammar_rule_rows', <String, Object?>{
          'rule_id': rule.id,
          'row_index': rowIndex,
          'cells_json': jsonEncode(rule.table[rowIndex]),
        });
      }

      for (var exampleIndex = 0;
          exampleIndex < rule.examples.length;
          exampleIndex++) {
        final example = rule.examples[exampleIndex];
        await db.insert('grammar_examples', <String, Object?>{
          'rule_id': rule.id,
          'example_index': exampleIndex,
          'german': example.german,
          'arabic': example.arabic,
        });
      }
    }

    for (final quiz in topic.miniChecks) {
      await db.insert('grammar_quizzes', <String, Object?>{
        'canonical_id': quiz.id,
        'topic_id': topic.id,
        'question': quiz.questionText,
        'options_json': jsonEncode(quiz.options),
        'correct_index': quiz.correctAnswerIndex,
        'explanation': quiz.explanationAr,
      });
    }
  }

  static String? _formula(canonical.GrammarTopic topic) {
    if (topic.rules.isEmpty || topic.rules.first.table.isEmpty) return null;
    final firstRow = topic.rules.first.table.first;
    if (firstRow.isEmpty) return null;
    return firstRow.join(' · ');
  }
}
