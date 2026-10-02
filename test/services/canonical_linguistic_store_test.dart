import 'dart:convert';

import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_word_family.dart';
import 'package:deutsch_bilarabi/models/linguistics/linguistic_concept.dart';
import 'package:deutsch_bilarabi/services/canonical_linguistic_schema.dart';
import 'package:deutsch_bilarabi/services/canonical_linguistic_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'legacy flat lexicon migrates concept identity without invented morphology',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(
        'CREATE TABLE lexicon ('
        'id TEXT PRIMARY KEY, surface TEXT NOT NULL, '
        'part_of_speech TEXT NOT NULL, direction TEXT NOT NULL, '
        'fields_json TEXT NOT NULL)',
      );
      await db.insert('lexicon', <String, Object>{
        'id': 'home.house',
        'surface': 'Haus',
        'part_of_speech': 'noun',
        'direction': 'ltr',
        'fields_json': jsonEncode(<String, Object>{'article': 'das'}),
      });

      await CanonicalLinguisticSchema.migrateLegacyFlatSchema(db);
      final store = CanonicalLinguisticStore(db);
      final concept = await store.readConcept('home.house');

      expect(concept?.lemma, 'Haus');
      expect(concept?.senseId, 'home.house');
      expect(concept?.partOfSpeech, LinguisticPartOfSpeech.noun);
      expect(concept?.cefr, CefrLevel.unknown);
      expect(await store.readGermanNoun('home.house'), isNull);
      expect(
        (await db.rawQuery('PRAGMA user_version')).single['user_version'],
        CanonicalLinguisticSchema.sqliteUserVersion,
      );

      await db.close();
    },
  );

  test(
    'canonical store reads noun cases and verb valency relationally',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await CanonicalLinguisticSchema.migrateLegacyFlatSchema(db);

      await db.insert('concepts', <String, Object>{
        'concept_id': 'noun.student',
        'sense_id': 'student.person',
        'lemma': 'Student',
        'part_of_speech': 'noun',
        'register': 'neutral',
        'cefr': 'A1',
        'surface': 'Student',
        'direction': 'ltr',
        'semantic_tags_json': '["people"]',
        'legacy_fields_json': '{}',
      });
      await db.insert('german_nouns', <String, Object?>{
        'concept_id': 'noun.student',
        'gender': 'masculine',
        'plural': 'Studenten',
        'declension_class': 'weak',
        'nominative_singular': 'Student',
        'accusative_singular': 'Studenten',
        'dative_singular': 'Studenten',
        'genitive_singular': 'Studenten',
        'nominative_plural': 'Studenten',
        'accusative_plural': 'Studenten',
        'dative_plural': 'Studenten',
        'genitive_plural': 'Studenten',
      });

      await db.insert('concepts', <String, Object>{
        'concept_id': 'verb.warten',
        'sense_id': 'warten.wait',
        'lemma': 'warten',
        'part_of_speech': 'verb',
        'register': 'neutral',
        'cefr': 'A1',
        'surface': 'warten',
        'direction': 'ltr',
        'semantic_tags_json': '[]',
        'legacy_fields_json': '{}',
      });
      await db.insert('german_verbs', <String, Object?>{
        'concept_id': 'verb.warten',
        'infinitive': 'warten',
        'separable_prefix': null,
        'inseparable_prefix': null,
        'reflexivity': 'none',
        'auxiliary': 'haben',
        'participle_ii': 'gewartet',
        'preterite': 'wartete',
        'imperative': 'warte',
      });
      await db.insert('verb_valency_frames', <String, Object?>{
        'concept_id': 'verb.warten',
        'frame_id': 'prep_auf',
        'governed_case': null,
        'preposition': 'auf',
        'preposition_case': 'accusative',
        'semantic_role': 'target',
        'object_required': 1,
      });

      final store = CanonicalLinguisticStore(db);
      final noun = await store.readGermanNoun('noun.student');
      final verb = await store.readGermanVerb('verb.warten');

      expect(noun?.gender, GermanGender.masculine);
      expect(
        noun?.caseForms.formFor(GermanCase.dative, plural: false),
        'Studenten',
      );
      expect(verb?.auxiliary, GermanAuxiliary.haben);
      expect(verb?.valencyFrames.single.preposition, 'auf');
      expect(verb?.valencyFrames.single.prepositionCase, GermanCase.accusative);

      await db.close();
    },
  );
  test('canonical store reads explicit German word-family relations', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await CanonicalLinguisticSchema.migrateLegacyFlatSchema(db);

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
      await db.insert('concepts', row);
    }
    await db.insert('german_word_families', <String, Object>{
      'family_id': 'fahren',
      'base_concept_id': 'verb.fahren',
    });
    await db.insert('german_word_family_members', <String, Object?>{
      'family_id': 'fahren',
      'concept_id': 'verb.fahren',
      'relation_type': 'base',
      'prefix': null,
      'suffix': null,
      'semantic_distance': 'low',
      'pedagogical_level': 'A1',
      'interference_risk': 0,
    });
    await db.insert('german_word_family_members', <String, Object?>{
      'family_id': 'fahren',
      'concept_id': 'noun.fahrer',
      'relation_type': 'agent_noun',
      'prefix': null,
      'suffix': 'er',
      'semantic_distance': 'low',
      'pedagogical_level': 'A1',
      'interference_risk': 0,
    });

    final family =
        await CanonicalLinguisticStore(db).readGermanWordFamily('fahren');

    expect(family?.baseConceptId, 'verb.fahren');
    expect(family?.baseMember?.concept.lemma, 'fahren');
    expect(family?.members, hasLength(2));
    expect(
      family?.members.last.relationType,
      GermanWordFamilyRelationType.agentNoun,
    );
    expect(family?.members.last.suffix, 'er');
    expect(family?.members.last.semanticDistance, GermanSemanticDistance.low);

    await db.close();
  });

}
