import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/linguistics/german_grammar_types.dart';
import '../models/linguistics/german_noun.dart';
import '../models/linguistics/german_noun_forms.dart';
import '../models/linguistics/german_verb.dart';
import '../models/linguistics/german_word_family.dart';
import '../models/linguistics/linguistic_concept.dart';
import '../models/linguistics/verb_valency_frame.dart';
import 'canonical_linguistic_schema.dart';

/// Read-only query adapter for canonical linguistic tables.
///
/// If an older pack has only the Phase-1 flat lexicon table, concept identity
/// can still be projected safely. Morphology is never fabricated.
final class CanonicalLinguisticStore {
  const CanonicalLinguisticStore(this.db);

  final DatabaseExecutor db;

  Future<LinguisticConcept?> readConcept(String conceptId) async {
    if (await _hasTable(CanonicalLinguisticSchema.conceptsTable)) {
      final rows = await db.rawQuery(
        CanonicalLinguisticSchema.selectConceptById,
        <Object?>[conceptId],
      );
      return rows.isEmpty ? null : _concept(rows.first);
    }
    if (!await _hasTable('lexicon')) return null;
    final rows = await db.rawQuery(
      CanonicalLinguisticSchema.selectLegacyConceptById,
      <Object?>[conceptId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return LinguisticConcept(
      id: row['id'].toString(),
      senseId: row['id'].toString(),
      lemma: row['surface'].toString(),
      partOfSpeech: LinguisticPartOfSpeech.fromWire(
        row['part_of_speech']?.toString(),
      ),
      register: LanguageRegister.neutral,
      cefr: CefrLevel.unknown,
    );
  }

  Future<GermanNoun?> readGermanNoun(String conceptId) async {
    if (!await _hasTable(CanonicalLinguisticSchema.nounsTable)) return null;
    final concept = await readConcept(conceptId);
    if (concept == null) return null;
    final rows = await db.rawQuery(
      CanonicalLinguisticSchema.selectNounById,
      <Object?>[conceptId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return GermanNoun(
      concept: concept,
      gender: GermanGender.fromWire(row['gender']?.toString()),
      plural: _nullableText(row['plural']),
      declensionClass: GermanNounDeclensionClass.fromWire(
        row['declension_class']?.toString(),
      ),
      caseForms: GermanNounCaseForms(
        nominativeSingular: row['nominative_singular'].toString(),
        accusativeSingular: row['accusative_singular'].toString(),
        dativeSingular: row['dative_singular'].toString(),
        genitiveSingular: row['genitive_singular'].toString(),
        nominativePlural: _nullableText(row['nominative_plural']),
        accusativePlural: _nullableText(row['accusative_plural']),
        dativePlural: _nullableText(row['dative_plural']),
        genitivePlural: _nullableText(row['genitive_plural']),
      ),
    );
  }

  Future<GermanVerb?> readGermanVerb(String conceptId) async {
    if (!await _hasTable(CanonicalLinguisticSchema.verbsTable)) return null;
    final concept = await readConcept(conceptId);
    if (concept == null) return null;
    final rows = await db.rawQuery(
      CanonicalLinguisticSchema.selectVerbById,
      <Object?>[conceptId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    final valencyRows = await db.rawQuery(
      CanonicalLinguisticSchema.selectValencyByVerb,
      <Object?>[conceptId],
    );
    final formRows = await db.rawQuery(
      CanonicalLinguisticSchema.selectFormsByVerb,
      <Object?>[conceptId],
    );

    return GermanVerb(
      concept: concept,
      infinitive: row['infinitive'].toString(),
      separablePrefix: _nullableText(row['separable_prefix']),
      inseparablePrefix: _nullableText(row['inseparable_prefix']),
      reflexivity: GermanReflexivity.fromWire(row['reflexivity']?.toString()),
      auxiliary: GermanAuxiliary.fromWire(row['auxiliary']?.toString()),
      participleII: _nullableText(row['participle_ii']),
      preterite: _nullableText(row['preterite']),
      imperative: _nullableText(row['imperative']),
      valencyFrames: valencyRows
          .map(
            (item) => VerbValencyFrame(
              frameId: item['frame_id'].toString(),
              governedCase: GermanCase.fromWire(
                item['governed_case']?.toString(),
              ),
              preposition: _nullableText(item['preposition']),
              prepositionCase: GermanCase.fromWire(
                item['preposition_case']?.toString(),
              ),
              semanticRole: item['semantic_role'].toString(),
              objectRequired: item['object_required'] == 1,
            ),
          )
          .toList(growable: false),
      forms: formRows
          .map(
            (item) => GermanVerbForm(
              tense: item['tense'].toString(),
              personKey: item['person_key'].toString(),
              form: item['form'].toString(),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<List<String>> listGermanWordFamilyIds({int limit = 200}) async {
    if (limit <= 0 ||
        !await _hasTable(CanonicalLinguisticSchema.wordFamiliesTable)) {
      return const <String>[];
    }
    final rows = await db.rawQuery(
      CanonicalLinguisticSchema.selectWordFamilyIds,
      <Object?>[limit.clamp(1, 500)],
    );
    return rows
        .map((row) => row['family_id']?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Future<GermanWordFamily?> readGermanWordFamily(String familyId) async {
    if (familyId.trim().isEmpty ||
        !await _hasTable(CanonicalLinguisticSchema.wordFamiliesTable) ||
        !await _hasTable(CanonicalLinguisticSchema.wordFamilyMembersTable)) {
      return null;
    }
    final rows = await db.rawQuery(
      CanonicalLinguisticSchema.selectWordFamily,
      <Object?>[familyId],
    );
    if (rows.isEmpty) return null;
    final baseConceptId = rows.first['base_concept_id']?.toString() ?? '';
    if (baseConceptId.isEmpty) return null;

    final members = rows
        .map(
          (row) => GermanWordFamilyMember(
            concept: _concept(row),
            relationType: GermanWordFamilyRelationType.fromWire(
              row['relation_type']?.toString(),
            ),
            prefix: _nullableText(row['prefix']),
            suffix: _nullableText(row['suffix']),
            semanticDistance: GermanSemanticDistance.fromWire(
              row['semantic_distance']?.toString(),
            ),
            pedagogicalLevel: CefrLevel.fromWire(
              row['pedagogical_level']?.toString(),
            ),
            interferenceRisk: row['interference_risk'] == 1,
          ),
        )
        .toList(growable: false);

    final family = GermanWordFamily(
      familyId: familyId,
      baseConceptId: baseConceptId,
      members: List<GermanWordFamilyMember>.unmodifiable(members),
    );
    return family.baseMember == null ? null : family;
  }

  LinguisticConcept _concept(Map<String, Object?> row) {
    final tagsRaw = row['semantic_tags_json']?.toString() ?? '[]';
    final decoded = jsonDecode(tagsRaw);
    final tags = decoded is List
        ? decoded.whereType<String>().toList(growable: false)
        : const <String>[];
    return LinguisticConcept(
      id: row['concept_id'].toString(),
      senseId: row['sense_id'].toString(),
      lemma: row['lemma'].toString(),
      partOfSpeech: LinguisticPartOfSpeech.fromWire(
        row['part_of_speech']?.toString(),
      ),
      register: LanguageRegister.fromWire(row['register']?.toString()),
      cefr: CefrLevel.fromWire(row['cefr']?.toString()),
      semanticTags: tags,
    );
  }

  Future<bool> _hasTable(String table) async {
    final rows = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      <Object?>['table', table],
    );
    return rows.isNotEmpty;
  }

  String? _nullableText(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}
