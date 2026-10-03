import 'package:deutsch_bilarabi/data/canonical_grammar_catalog.dart';
import 'package:deutsch_bilarabi/services/canonical_grammar_compiler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'compiler materializes the single canonical grammar catalog to SQLite',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      await CanonicalGrammarCompiler.rebuild(db);

      final topics = await db.query(
        'grammar_topic_runtime',
        orderBy: 'level ASC, order_index ASC',
      );
      final rules = await db.query('grammar_rules');
      final quizzes = await db.query('grammar_quizzes');

      expect(topics.length, CanonicalGrammarCatalog.allTopics.length);
      expect(topics.where((row) => row['id'] == 'a1_nominativ'), isNotEmpty);
      expect(topics.where((row) => row['id'] == 'a1_pronouns'), isNotEmpty);
      expect(topics.where((row) => row['id'] == 'b1_passiv'), isNotEmpty);
      expect(rules, isNotEmpty);
      expect(quizzes, isNotEmpty);

      await db.close();
    },
  );

  test('rebuild preserves mastery for stable canonical topic IDs', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await CanonicalGrammarCompiler.rebuild(db);
    await db.update(
      'grammar_topics',
      <String, Object>{'is_mastered': 1},
      where: 'id = ?',
      whereArgs: const <Object?>['a1_nominativ'],
    );

    await CanonicalGrammarCompiler.rebuild(db);

    final row = (await db.query(
      'grammar_topic_runtime',
      where: 'id = ?',
      whereArgs: const <Object?>['a1_nominativ'],
    )).single;
    expect(row['is_mastered'], 1);

    await db.close();
  });
}
