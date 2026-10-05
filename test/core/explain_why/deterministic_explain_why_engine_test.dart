import 'package:deutsch_bilarabi/core/explain_why/deterministic_explain_why_engine.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_models.dart';
import 'package:deutsch_bilarabi/core/l10n/l10n_dictionary_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = DeterministicExplainWhyEngine.fromDictionary(
    dictionary: L10nDictionaryCodec.decodeJson(
      '''
{
  "locale": "ar",
  "strings": {
    "explain.grammar.verb.conjugation.correct":
      "صحيح — مع {pronoun}: {infinitive} → {expected}.",
    "explain.grammar.verb.conjugation.incorrect":
      "راجع التصريف مع الضمير {pronoun}: {infinitive} → {expected}."
  }
}
''',
    ),
    userLanguageCode: 'ar',
    sourceLanguageCode: 'ar',
    targetLanguageCode: 'de',
  );

  test('renders the same reason code deterministically from structured args', () {
    final request = ExplainerRequest(
      reasonCode: 'grammar.verb.conjugation',
      correct: false,
      arguments: const <String, String>{
        'pronoun': 'du',
        'infinitive': 'fahren',
        'expected': 'fährst',
      },
    );

    final first = engine.explain(request);
    final second = engine.explain(request);

    expect(first.reasonCode, 'grammar.verb.conjugation');
    expect(first.languageCode, 'ar');
    expect(first.text, 'راجع التصريف مع الضمير du: fahren → fährst.');
    expect(second.text, first.text);
  });

  test('selects the success template without per-item explanation prose', () {
    final result = engine.explain(
      ExplainerRequest(
        reasonCode: 'grammar.verb.conjugation',
        correct: true,
        arguments: const <String, String>{
          'pronoun': 'ich',
          'infinitive': 'sein',
          'expected': 'bin',
        },
      ),
    );

    expect(result.text, 'صحيح — مع ich: sein → bin.');
  });

  test('fails closed for an unknown reason code', () {
    expect(
      () => engine.explain(
        ExplainerRequest(
          reasonCode: 'grammar.unknown',
          correct: false,
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.toString(),
          'message',
          contains('explain_why_reason_unsupported'),
        ),
      ),
    );
  });

  test('fails closed when a required template argument is missing', () {
    expect(
      () => engine.explain(
        ExplainerRequest(
          reasonCode: 'grammar.verb.conjugation',
          correct: false,
          arguments: <String, String>{
            'pronoun': 'du',
            'infinitive': 'fahren',
          },
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('reason codes reject whitespace and unstable characters', () {
    expect(
      () => engine.explain(
        ExplainerRequest(
          reasonCode: 'grammar verb conjugation',
          correct: false,
        ),
      ),
      throwsFormatException,
    );
  });
}
