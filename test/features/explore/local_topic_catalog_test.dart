import 'dart:convert';

import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ffi.sqfliteFfiInit);

  late Database db;
  setUp(() async {
    db = await ffi.databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY, surface TEXT NOT NULL, sort_key TEXT NOT NULL,
        part_of_speech TEXT NOT NULL, cefr_level TEXT NOT NULL,
        language_code TEXT NOT NULL, fields_json TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE senses (concept_id TEXT NOT NULL, lexeme_id TEXT NOT NULL)
    ''');
    Future<void> insertWord(String id, String word, String pos,
        String lang, String level, String translation) async {
      await db.insert('lexicon', <String, Object?>{
        'id': id,
        'surface': word,
        'sort_key': word.toLowerCase(),
        'part_of_speech': pos,
        'cefr_level': level,
        'language_code': lang,
        'fields_json': jsonEncode(<String, String>{
          'translation_ar': translation,
        }),
      });
      await db.insert('senses',
          <String, String>{'concept_id': 'sense-$id', 'lexeme_id': id});
    }
    await insertWord('de-mutter', 'Mutter', 'noun', 'de', 'A1', 'أم');
    await insertWord('de-bruder', 'Bruder', 'noun', 'de', 'A1', 'أخ');
    await insertWord('de-brot', 'Brot', 'noun', 'de', 'A1', 'خبز');
    await insertWord('de-later', 'Mutter', 'noun', 'de', 'A2', 'أم');
    await insertWord('en-mutter', 'Mutter', 'noun', 'en', 'A1', 'mother');
    await insertWord('de-kaufen', 'kaufen', 'verb', 'de', 'A1', 'يشتري');
  });
  tearDown(() async => db.close());

  test('family topics resolve local German IDs without copied translations',
      () async {
    final rows = await LocalTopicCatalog.querySectionFromDb(db,
        sectionId: 'FAMILY', cefr: 'A1', languageCode: 'de');
    expect(rows.map((row) => row['lexeme_id']),
        containsAll(<String>['de-mutter', 'de-bruder']));
    expect(rows.length, 2);
    expect(rows.first['concept_id'], startsWith('sense-'));
    expect(rows.first['translation_ar'], isNotEmpty);
    expect(rows.map((r) => r['lexeme_id']), isNot(contains('de-brot')));
    expect(rows.map((r) => r['lexeme_id']), isNot(contains('en-mutter')));
  });

  test('a lexeme is referenced in multiple topics without being duplicated',
      () async {
    final work = await LocalTopicCatalog.querySectionFromDb(db,
        sectionId: 'WORK', cefr: 'A1', languageCode: 'de');
    final clothing = await LocalTopicCatalog.querySectionFromDb(db,
        sectionId: 'CLOTHING', cefr: 'A1', languageCode: 'de');
    expect(work.single['lexeme_id'], 'de-kaufen');
    expect(clothing.single['lexeme_id'], 'de-kaufen');
  });

  test('missing topics and unsupported languages fail closed', () async {
    for (final section in <String>['UNKNOWN', "FAMILY' OR 1=1 --"]) {
      expect(
        await LocalTopicCatalog.querySectionFromDb(db,
            sectionId: section, cefr: 'A1', languageCode: 'de'),
        isEmpty,
      );
    }
    expect(
      await LocalTopicCatalog.querySectionFromDb(db,
          sectionId: 'FAMILY', cefr: 'A1', languageCode: 'fr'),
      isEmpty,
    );
    expect(
      await LocalTopicCatalog.querySectionFromDb(db,
          sectionId: 'FAMILY', cefr: 'C9', languageCode: 'de'),
      isEmpty,
    );
  });
}
