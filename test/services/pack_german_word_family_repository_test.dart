import 'package:deutsch_bilarabi/services/canonical_linguistic_schema.dart';
import 'package:deutsch_bilarabi/services/pack_database_security.dart';
import 'package:deutsch_bilarabi/services/pack_german_word_family_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('pack repository reads only canonical explicit word families', () async {
    final path = inMemoryDatabasePath;
    final database = await databaseFactoryFfi.openDatabase(path);
    await CanonicalLinguisticSchema.migrateLegacyFlatSchema(database);

    for (final row in <Map<String, Object>>[
      <String, Object>{
        'concept_id': 'verb.fahren',
        'sense_id': 'fahren.travel',
        'lemma': 'fahren',
        'part_of_speech': 'verb',
        'register': 'neutral',
        'cefr': 'A1',
        'surface': 'fahren',
        'direction': 'ltr',
        'semantic_tags_json': '[]',
        'legacy_fields_json': '{}',
      },
      <String, Object>{
        'concept_id': 'noun.fahrer',
        'sense_id': 'fahrer.person',
        'lemma': 'Fahrer',
        'part_of_speech': 'noun',
        'register': 'neutral',
        'cefr': 'A1',
        'surface': 'Fahrer',
        'direction': 'ltr',
        'semantic_tags_json': '[]',
        'legacy_fields_json': '{}',
      },
    ]) {
      await database.insert('concepts', row);
    }
    await database.insert('german_word_families', <String, Object>{
      'family_id': 'fahren',
      'base_concept_id': 'verb.fahren',
    });
    for (final row in <Map<String, Object?>>[
      <String, Object?>{
        'family_id': 'fahren',
        'concept_id': 'verb.fahren',
        'relation_type': 'base',
        'prefix': null,
        'suffix': null,
        'semantic_distance': 'low',
        'pedagogical_level': 'A1',
        'interference_risk': 0,
      },
      <String, Object?>{
        'family_id': 'fahren',
        'concept_id': 'noun.fahrer',
        'relation_type': 'agent_noun',
        'prefix': null,
        'suffix': 'er',
        'semantic_distance': 'low',
        'pedagogical_level': 'A1',
        'interference_risk': 0,
      },
    ]) {
      await database.insert('german_word_family_members', row);
    }
    await database.close();

    final repository = PackGermanWordFamilyRepository(
      databasePath: path,
      databaseOpener: FactoryBackedPackDatabaseOpener(databaseFactoryFfi),
      databasePassword: 'test-only',
    );

    final families = await repository.listFamilies();

    expect(families, hasLength(1));
    expect(families.single.baseMember?.concept.lemma, 'fahren');
    expect(families.single.members.last.concept.lemma, 'Fahrer');
  });
}
