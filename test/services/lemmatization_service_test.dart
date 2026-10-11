import 'dart:io';

import 'package:deutsch_bilarabi/services/lemmatization_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database database;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final schema = File(
      'tools/morphology/reverse_lemmatization_schema.sql',
    ).readAsStringSync();
    for (final statement in schema.split(';')) {
      if (statement.trim().isNotEmpty) {
        await database.execute(statement);
      }
    }
    for (final entry in <List<String>>[
      <String>['ging', 'gehen', 'verb', 'de'],
      <String>['went', 'go', 'verb', 'en'],
      <String>['съел', 'есть', 'verb', 'ru'],
      <String>['saw', 'see', 'verb', 'en'],
      <String>['saw', 'saw', 'noun', 'en'],
    ]) {
      await database.rawInsert(
        'INSERT INTO inflections_lookup '
        '(inflected_form, lemma, pos, language_code) VALUES (?, ?, ?, ?)',
        entry,
      );
    }
  });

  tearDown(() async {
    await database.close();
  });

  LemmatizationService makeService({DictionarySearch? search}) {
    return LemmatizationService(
      openContentDb: (_) async => database,
      search: search,
    );
  }

  test('creates the required composite lookup index', () async {
    final indexes = await database.rawQuery(
      "PRAGMA index_list('inflections_lookup')",
    );
    expect(
      indexes.map((row) => row['name']),
      contains('idx_inflection_lang'),
    );
  });

  test('resolves German, English, and Russian inflections', () async {
    final service = makeService();
    expect(await service.resolveLemma('ging', 'de'), 'gehen');
    expect(await service.resolveLemma('went', 'en'), 'go');
    expect(await service.resolveLemma('съел', 'ru'), 'есть');
  });

  test('normalizes ASCII input case and isolates languages', () async {
    final service = makeService();
    expect(await service.resolveLemma('Ging', 'DE'), 'gehen');
    expect(await service.resolveLemma('went', 'de'), isNull);
    expect(await service.resolveLemma('ging', 'en'), isNull);
  });

  test('supports POS disambiguation through parameter binding', () async {
    final service = makeService();
    expect(
      await service.resolveLemma('saw', 'en', partOfSpeech: 'verb'),
      'see',
    );
    expect(
      await service.resolveLemma('saw', 'en', partOfSpeech: 'noun'),
      'saw',
    );
  });

  test('does not treat user text as executable SQL', () async {
    final service = makeService();
    expect(
      await service.resolveLemma("went' OR 1=1 --", 'en'),
      isNull,
    );
  });

  test('returns null for invalid and oversized terms', () async {
    final service = makeService();
    expect(await service.resolveLemma('', 'en'), isNull);
    expect(
      await service.resolveLemma(
        List<String>.filled(LemmatizationService.maxTermLength + 1, 'a').join(),
        'en',
      ),
      isNull,
    );
    expect(await service.resolveLemma('went', 'en; DROP TABLE x'), isNull);
  });

  test('degrades gracefully when legacy packs lack the lookup table',
      () async {
    await database.execute('DROP TABLE inflections_lookup');
    expect(await makeService().resolveLemma('ging', 'de'), isNull);
  });

  test('first returns ordinary FTS results without reverse lookup', () async {
    final seen = <String>[];
    final service = makeService(
      search: (query, code, limit) async {
        seen.add(query);
        return <Map<String, dynamic>>[
          <String, dynamic>{'surface': 'went'},
        ];
      },
    );
    final result = await service.searchDictionary('went', 'en');
    expect(result.single['surface'], 'went');
    expect(seen, <String>['went']);
  });

  test('retries canonical lemma only when initial search is empty', () async {
    final seen = <String>[];
    final service = makeService(
      search: (query, code, limit) async {
        seen.add(query);
        if (query == 'gehen') {
          return <Map<String, dynamic>>[
            <String, dynamic>{'surface': 'gehen'},
          ];
        }
        return <Map<String, dynamic>>[];
      },
    );
    final result = await service.searchDictionary('ging', 'de');
    expect(seen, <String>['ging', 'gehen']);
    expect(result.single['surface'], 'gehen');
  });

  test('preserves empty results when no lemma is indexed', () async {
    final seen = <String>[];
    final service = makeService(
      search: (query, code, limit) async {
        seen.add(query);
        return <Map<String, dynamic>>[];
      },
    );
    expect(await service.searchDictionary('absent', 'de'), isEmpty);
    expect(seen, <String>['absent']);
  });
}
