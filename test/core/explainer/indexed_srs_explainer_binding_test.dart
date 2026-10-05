import 'package:deutsch_bilarabi/core/explain_why/deterministic_explain_why_engine.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_bindings.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_models.dart';
import 'package:deutsch_bilarabi/core/l10n/l10n_dictionary_codec.dart';
import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_contract.dart';
import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('ExplainerBindings reads admitted IndexedSrsCorpusRepository evidence', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);

    for (final statement in SrsCorpusContract.createSchemaStatements) {
      await db.execute(statement);
    }
    for (final statement in SrsCorpusContract.createIndexStatements) {
      await db.execute(statement);
    }

    const sourceSha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final metadata = <String, String>{
      SrsCorpusContract.metadataStateKey: 'ready',
      SrsCorpusContract.metadataSchemaVersionKey:
          SrsCorpusContract.schemaVersion.toString(),
      SrsCorpusContract.metadataContentRowsKey: '1',
      SrsCorpusContract.metadataVerbRowsKey: '1',
      SrsCorpusContract.metadataSourceContentSha256Key: sourceSha,
    };
    for (final entry in metadata.entries) {
      await db.insert(
        SrsCorpusContract.metadataTable,
        <String, Object?>{'key': entry.key, 'value': entry.value},
      );
    }

    await db.insert(
      SrsCorpusContract.contentTable,
      const <String, Object?>{
        'id': 'verb.fahren',
        'german': 'fahren',
        'arabic': 'يذهب بالمركبة',
        'sentence': 'Du fährst zur Arbeit.',
        'sentence_ar': 'أنت تذهب إلى العمل.',
        'topic': 'verbs',
        'skill': 'production',
        'article': '',
        'plural': '',
      },
    );
    await db.insert(
      SrsCorpusContract.verbTable,
      const <String, Object?>{
        'content_id': 'verb.fahren',
        'row_ordinal': 0,
        'infinitive': 'fahren',
        'arabic': 'يذهب بالمركبة',
        'group_name': 'present',
        'person': 'du',
        'person_ar': 'أنت',
        'form': 'fährst',
        'past': 'bist gefahren',
        'past_arabic': 'ذهبت',
        'example': 'Du fährst zur Arbeit.',
        'example_ar': 'أنت تذهب إلى العمل.',
        'past_example': 'Du bist zur Arbeit gefahren.',
        'past_example_ar': 'لقد ذهبت إلى العمل.',
      },
    );

    final repository = await IndexedSrsCorpusRepository.open(
      db,
      expectedCardinality: SrsCorpusCardinality(
        contentRows: 1,
        verbRows: 1,
      ),
      sourceContentSha256: sourceSha,
    );
    final engine = DeterministicExplainWhyEngine.fromDictionary(
      dictionary: L10nDictionaryCodec.decodeJson(
        '''
{
  "locale": "ar",
  "strings": {
    "explain.lexicon.verb.agreement.correct":
      "الصيغة {observed} صحيحة مع {pronoun}.",
    "explain.lexicon.verb.agreement.incorrect":
      "مع {pronoun}: {infinitive} → {expected}، وليس {observed}."
  }
}
''',
      ),
      userLanguageCode: 'ar',
      sourceLanguageCode: 'ar',
      targetLanguageCode: 'de',
    );
    final service = ExplainerBindings.fromIndexedSrsCorpus(
      repository,
      explainWhyEngine: engine,
    );

    final result = await service.explainWhy(
      ExplainerRequest(
        contentId: 'verb.fahren',
        pronoun: 'du',
        observedForm: 'fahrt',
      ),
    );

    expect(result.found, isTrue);
    expect(result.reasonCode, 'lexicon.verb.agreement');
    expect(result.explanationText, contains('fahren → fährst'));
    expect(
      result.facts
          .where((fact) => fact.kind == ExplainerFactKind.verbAgreement)
          .single
          .value,
      'fährst',
    );
  });
}
