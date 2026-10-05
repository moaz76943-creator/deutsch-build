import 'package:deutsch_bilarabi/core/explain_why/deterministic_explain_why_engine.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_corpus_reader.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_models.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_service.dart';
import 'package:deutsch_bilarabi/core/l10n/l10n_dictionary_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Explain Why v2 corpus rule engine', () {
    test(
      'uses ExplainerRequest plus bounded corpus evidence to explain verb agreement',
      () async {
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
        final reader = _CountingReader(
          entry: ExplainerCorpusEntry(
            id: 'verb.fahren',
            sourceText: 'fahren',
            translationText: 'يذهب بالمركبة',
            sentence: 'Du fährst zur Arbeit.',
            sentenceTranslation: 'أنت تذهب إلى العمل.',
            grammaticalMarker: '',
            pluralForm: '',
          ),
          verbRows: <ExplainerVerbEvidence>[
            ExplainerVerbEvidence(
              infinitive: 'fahren',
              person: 'du',
              personTranslation: 'أنت',
              form: 'fährst',
              past: 'bist gefahren',
              pastTranslation: 'ذهبت',
              example: 'Du fährst zur Arbeit.',
              exampleTranslation: 'أنت تذهب إلى العمل.',
            ),
          ],
        );
        final service = ExplainerService(
          corpusReader: reader,
          explainWhyEngine: engine,
        );

        final result = await service.explainWhy(
          ExplainerRequest(
            contentId: 'verb.fahren',
            observedForm: 'fahrt',
            pronoun: 'du',
            arguments: const <String, String>{
              'expected': 'spoofed',
            },
          ),
        );

        expect(result.reasonCode, 'lexicon.verb.agreement');
        expect(
          result.explanationText,
          'مع du: fahren → fährst، وليس fahrt.',
        );
        expect(result.explanationLanguageCode, 'ar');
        expect(reader.contentReads, 1);
        expect(reader.verbReads, 1);
        expect(reader.lastVerbLimit, lessThanOrEqualTo(12));
      },
    );

    test('explicit reasonCode rendering is data-driven and corpus-independent', () {
      final engine = DeterministicExplainWhyEngine.fromDictionary(
        dictionary: L10nDictionaryCodec.decodeJson(
          '''
{
  "locale": "ar",
  "strings": {
    "explain.grammar.word_order.main_v2.correct": "V2 صحيح.",
    "explain.grammar.word_order.main_v2.incorrect": "الفعل المصرف في الموضع الثاني."
  }
}
''',
        ),
        userLanguageCode: 'ar',
        sourceLanguageCode: 'ar',
        targetLanguageCode: 'de',
      );

      final result = engine.explain(
        ExplainerRequest(
          reasonCode: 'grammar.word_order.main_v2',
          correct: false,
        ),
      );

      expect(result.reasonCode, 'grammar.word_order.main_v2');
      expect(result.text, 'الفعل المصرف في الموضع الثاني.');
      expect(result.languageCode, 'ar');
    });

    test('dictionary admission rejects an unpaired reason template', () {
      expect(
        () => DeterministicExplainWhyEngine.fromDictionary(
          dictionary: L10nDictionaryCodec.decodeJson(
            '''
{
  "locale": "ar",
  "strings": {
    "explain.lexicon.meaning.correct": "{source} = {translation}"
  }
}
''',
          ),
          userLanguageCode: 'ar',
          sourceLanguageCode: 'ar',
          targetLanguageCode: 'de',
        ),
        throwsFormatException,
      );
    });
  });
}

final class _CountingReader implements ExplainerCorpusReader {
  _CountingReader({
    required this.entry,
    required this.verbRows,
  });

  final ExplainerCorpusEntry? entry;
  final List<ExplainerVerbEvidence> verbRows;
  int contentReads = 0;
  int verbReads = 0;
  int lastVerbLimit = 0;

  @override
  Future<ExplainerCorpusEntry?> fetchById(String contentId) async {
    contentReads += 1;
    return entry?.id == contentId ? entry : null;
  }

  @override
  Future<List<ExplainerVerbEvidence>> fetchVerbForms(
    String infinitive, {
    int limit = 6,
  }) async {
    verbReads += 1;
    lastVerbLimit = limit;
    return verbRows.take(limit).toList(growable: false);
  }
}
