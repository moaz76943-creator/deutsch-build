import 'dart:io';

import 'package:deutsch_bilarabi/services/lemmatization_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database database;
  late LemmatizationService service;

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
    await database.insert('inflections_lookup', <String, Object?>{
      'inflected_form': 'went',
      'language_code': 'en',
      'lemma': 'go',
      'lexicon_id': 'en-go',
    });
    await database.insert('inflections_lookup', <String, Object?>{
      'inflected_form': 'ging',
      'language_code': 'de',
      'lemma': 'gehen',
      'lexicon_id': 'de-gehen',
    });
    await database.insert('inflections_lookup', <String, Object?>{
      'inflected_form': 'parlé',
      'language_code': 'fr',
      'lemma': 'parler',
      'lexicon_id': 'fr-parler',
    });
    await database.insert('inflections_lookup', <String, Object?>{
      'inflected_form': 'съел',
      'language_code': 'ru',
      'lemma': 'есть',
      'lexicon_id': 'ru-eat',
    });
    service = LemmatizationService(
      openContentDb: (languageCode) async => database,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('indexed lookup resolves English, German, and French inflections',
      () async {
    expect(await service.resolve('went', languageCode: 'en'), 'go');
    expect(await service.resolve('ging', languageCode: 'de-DE'), 'gehen');
    expect(await service.resolve('parlé', languageCode: 'fr'), 'parler');
    expect(await service.resolve('съел', languageCode: 'ru'), 'есть');
    final matches = await service.lookup('WENT', languageCode: 'en');
    expect(matches.single.lexiconId, 'en-go');
  });

  test('schema provides POS and the required composite index', () async {
    final columns = await database.rawQuery(
      "PRAGMA table_info('inflections_lookup')",
    );
    expect(columns.map((row) => row['name']), contains('pos'));
    final indexes = await database.rawQuery(
      "PRAGMA index_list('inflections_lookup')",
    );
    expect(indexes.map((row) => row['name']), contains('idx_inflection_lang'));
  });

  test('language separation prevents false cross-language matches',
      () async {
    expect(await service.resolve('went', languageCode: 'de'), isNull);
    expect(await service.resolve('ging', languageCode: 'en'), isNull);
    expect(await service.lookup('', languageCode: 'en'), isEmpty);
    expect(await service.lookup(List<String>.filled(97, 'x').join(), languageCode: 'en'), isEmpty);
  });

  test('interceptor retries lemma only after empty normal search',
      () async {
    final requests = <String>[];
    final found = await service.searchWithLemmaFallback(
      'went',
      languageCode: 'en',
      searchDictionary: (word, code) async {
        requests.add('$code:$word');
        return word == 'go'
            ? <Map<String, dynamic>>[
                <String, dynamic>{'surface': 'go'},
              ]
            : <Map<String, dynamic>>[];
      },
    );
    expect(requests, <String>['en:went', 'en:go']);
    expect(found.single['surface'], 'go');

    requests.clear();
    final direct = await service.searchWithLemmaFallback(
      'went',
      languageCode: 'en',
      searchDictionary: (word, code) async {
        requests.add('$code:$word');
        return <Map<String, dynamic>>[
          <String, dynamic>{'surface': word},
        ];
      },
    );
    expect(direct.single['surface'], 'went');
    expect(requests, <String>['en:went']);
  });

  test('old packs without optional table degrade to empty', () async {
    await database.execute('DROP TABLE inflections_lookup');
    expect(await service.lookup('went', languageCode: 'en'), isEmpty);
  });

  test('enforces bounds and supports multiple attested lemmas', () async {
    await database.insert('inflections_lookup', <String, Object?>{
      'inflected_form': 'saw',
      'language_code': 'en',
      'lemma': 'see',
    });
    await database.insert('inflections_lookup', <String, Object?>{
      'inflected_form': 'saw',
      'language_code': 'en',
      'lemma': 'saw',
    });
    expect(
      (await service.lookup('saw', languageCode: 'en'))
          .map((entry) => entry.lemma).toList(),
      <String>['saw', 'see'],
    );
    expect(
      () => service.lookup('went', languageCode: 'en', limit: 9),
      throwsRangeError,
    );
    expect(
      () => service.lookup('went', languageCode: '../en'),
      throwsArgumentError,
    );
  });
}
