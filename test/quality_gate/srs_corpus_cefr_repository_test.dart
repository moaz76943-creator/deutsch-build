import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_contract.dart';
import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_migrator.dart';
import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CEFR flows from concepts.cefr into indexed repository items', () async {
    sqfliteFfiInit();
    final source = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    final target = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(source.close);
    addTearDown(target.close);

    await source.execute('''
CREATE TABLE lexicon (
  id TEXT PRIMARY KEY,
  surface TEXT NOT NULL,
  fields_json TEXT NOT NULL
)
''');
    await source.execute('''
CREATE TABLE concepts (
  concept_id TEXT PRIMARY KEY,
  cefr TEXT NOT NULL
)
''');

    await source.insert('lexicon', <String, Object?>{
      'id': 'a1.house',
      'surface': 'Haus',
      'fields_json':
          '{"translation":"بيت","topic":"home","skill":"vocabulary"}',
    });
    await source.insert('concepts', <String, Object?>{
      'concept_id': 'a1.house',
      'cefr': 'A1',
    });

    await source.insert('lexicon', <String, Object?>{
      'id': 'b2.decision',
      'surface': 'Entscheidung',
      'fields_json':
          '{"translation":"قرار","topic":"daily","skill":"vocabulary"}',
    });
    await source.insert('concepts', <String, Object?>{
      'concept_id': 'b2.decision',
      'cefr': 'B2',
    });

    final expected = SrsCorpusCardinality(contentRows: 2, verbRows: 0);
    const sha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

    await const SrsCorpusSqliteMigrator().migrate(
      source: source,
      target: target,
      expectedCardinality: expected,
      sourceContentSha256: sha,
    );

    final repository = await IndexedSrsCorpusRepository.open(
      target,
      expectedCardinality: expected,
      sourceContentSha256: sha,
    );
    final items = await repository.fetchByIds(
      const <String>['a1.house', 'b2.decision'],
    );

    expect(items.map((item) => item.cefr).toList(), <String>['A1', 'B2']);
  });
  test('migration requires concepts.cefr as the CEFR authority', () async {
    sqfliteFfiInit();
    final source = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    final target = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(source.close);
    addTearDown(target.close);

    await source.execute('''
CREATE TABLE lexicon (
  id TEXT PRIMARY KEY,
  surface TEXT NOT NULL,
  fields_json TEXT NOT NULL
)
''');
    await source.insert('lexicon', <String, Object?>{
      'id': 'a1.house',
      'surface': 'Haus',
      'fields_json':
          '{"translation":"بيت","canonical":{"cefr":"A1"}}',
    });

    final expected = SrsCorpusCardinality(contentRows: 1, verbRows: 0);

    expect(
      () => const SrsCorpusSqliteMigrator().migrate(
        source: source,
        target: target,
        expectedCardinality: expected,
        sourceContentSha256:
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'srs_corpus_concepts_missing',
        ),
      ),
    );
  });
}
