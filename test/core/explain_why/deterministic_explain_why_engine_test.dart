import 'package:deutsch_bilarabi/core/explain_why/deterministic_explain_why_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = DeterministicExplainWhyEngine(
    ExplainWhyCatalog(
      userLanguageCode: 'ar',
      sourceLanguageCode: 'ar',
      targetLanguageCode: 'de',
      templates: <String, ExplainWhyTemplate>{
        'grammar.verb.conjugation': ExplainWhyTemplate(
          reasonCode: 'grammar.verb.conjugation',
          successTemplate: 'صحيح — مع {pronoun}: {infinitive} → {expected}.',
          failureTemplate:
              'راجع التصريف مع الضمير {pronoun}: {infinitive} → {expected}.',
        ),
      },
    ),
  );

  test('renders the same reason code deterministically from structured args', () {
    final request = ExplainWhyRequest(
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

  test('selects the success template without storing per-item explanation text', () {
    final result = engine.explain(
      ExplainWhyRequest(
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
        ExplainWhyRequest(
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
        ExplainWhyRequest(
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
      () => ExplainWhyRequest(
        reasonCode: 'grammar verb conjugation',
        correct: false,
      ),
      throwsFormatException,
    );
  });
}
