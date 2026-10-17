import 'package:deutsch_bilarabi/services/concept_disambiguation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  final opened = <Database>[];

  Future<Database> pack(List<List<Object?>> records,
      {bool legacy = false}) async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false));
    opened.add(db);
    if (legacy) {
      await db.execute('CREATE TABLE concepts '
        '(concept_id TEXT PRIMARY KEY, surface TEXT)');
      for (final row in records) {
        await db.insert('concepts', {
          'concept_id': row[0], 'surface': row[1],
        });
      }
      return db;
    }
    await db.execute('CREATE TABLE concepts (concept_id TEXT, '
      'surface TEXT, sense_index INTEGER, part_of_speech TEXT)');
    for (final row in records) {
      await db.insert('concepts', {
        'concept_id': row[0],
        'surface': row[1],
        'sense_index': row[2],
        'part_of_speech': row[3],
      });
    }
    return db;
  }

  tearDown(() async {
    for (final db in opened) {
      if (db.isOpen) await db.close();
    }
    opened.clear();
  });

  test('distinguishes finance bank and river bank across pivot languages',
      () async {
    final french = await pack([
      ['bank', 'banque', 0, 'noun'],
      ['bank', 'rive', 1, 'noun'],
      ['bank', 'banquer', 0, 'verb'],
    ]);
    final spanish = await pack([
      ['bank', 'banco', 0, 'noun'],
      ['bank', 'orilla', 1, 'noun'],
    ]);
    final german = await pack([['bank', 'Bank', 0, 'noun']]);
    final bridge = ConceptDisambiguationService(openPackConnections: {
      'fr': french, 'es': spanish, 'de': german,
    });
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: 0, partOfSpeech: 'noun',
      activeLanguageCode: 'de-DE'), {'fr': 'banque', 'es': 'banco'});
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: 1, partOfSpeech: 'noun',
      activeLanguageCode: 'de'), {'fr': 'rive', 'es': 'orilla'});
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: 0, partOfSpeech: 'verb',
      activeLanguageCode: 'de'), {'fr': 'banquer'});
  });

  test('never falls back to headword in legacy schema or ambiguous senses',
      () async {
    final old = await pack([['bank', 'banque']], legacy: true);
    final ambiguous = await pack([
      ['bank', 'first', 0, 'noun'],
      ['bank', 'second', 0, 'noun'],
    ]);
    final bridge = ConceptDisambiguationService(openPackConnections: {
      'fr': old, 'es': ambiguous,
    });
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: 0, partOfSpeech: 'noun',
      activeLanguageCode: 'de'), isEmpty);
  });

  test('parameterized concept input, invalid context and unregister guard',
      () async {
    final french = await pack([['bank', 'banque', 0, 'noun']]);
    final bridge = ConceptDisambiguationService();
    bridge.registerOpenPack('fr-FR', french);
    expect(await bridge.findTranslations(
      conceptId: "bank' OR 1=1 --", senseIndex: 0,
      partOfSpeech: 'noun', activeLanguageCode: 'de'), isEmpty);
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: -1,
      partOfSpeech: 'noun', activeLanguageCode: 'de'), isEmpty);
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: 0,
      partOfSpeech: 'noun', activeLanguageCode: 'de'), {'fr-fr': 'banque'});
    bridge.unregisterOpenPack('fr-FR', connection: french);
    expect(await bridge.findTranslations(
      conceptId: 'bank', senseIndex: 0,
      partOfSpeech: 'noun', activeLanguageCode: 'de'), isEmpty);
  });
}
