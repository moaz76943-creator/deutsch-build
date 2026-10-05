import '../explain_why/deterministic_explain_why_engine.dart';
import 'explainer_corpus_reader.dart';
import 'explainer_models.dart';

/// Offline-first deterministic explanation service.
///
/// Construction is lazy. Each content-linked explanation performs one indexed
/// content lookup and at most one indexed verb lookup. Verb evidence is capped
/// at [maxVerbFormsPerExplanation], so rule resolution remains bounded O(1).
final class ExplainerService {
  const ExplainerService({
    required ExplainerCorpusReader corpusReader,
    ExplainWhyEngine? explainWhyEngine,
  })  : _corpusReader = corpusReader,
        _explainWhyEngine = explainWhyEngine;

  static const int maxVerbFormsPerExplanation = 12;
  static const int maxContentIdLength = 160;

  final ExplainerCorpusReader _corpusReader;
  final ExplainWhyEngine? _explainWhyEngine;

  Future<ExplainerResult> explainWhy(
    ExplainerRequest request,
  ) async {
    final contentId = request.contentId.trim();
    if (contentId.isEmpty || contentId.length > maxContentIdLength) {
      return ExplainerResult.notFound(contentId);
    }

    final maxVerbForms =
        request.maxVerbForms.clamp(1, maxVerbFormsPerExplanation).toInt();

    final entry = await _corpusReader.fetchById(contentId);
    if (entry == null) {
      return ExplainerResult.notFound(contentId);
    }

    final verbRows = await _corpusReader.fetchVerbForms(
      entry.sourceText,
      limit: maxVerbForms,
    );
    final expectedVerb = _selectExpectedVerbEvidence(
      verbRows,
      pronoun: request.pronoun,
      observedForm: request.observedForm,
    );

    final facts = _factsFor(
      entry,
      verbRows: verbRows,
      selectedVerb: expectedVerb,
    );
    final rule = _resolveRule(
      request,
      entry: entry,
      expectedVerb: expectedVerb,
    );
    final engine = _explainWhyEngine;
    if (engine == null) {
      return ExplainerResult(
        status: ExplainerStatus.explained,
        contentId: entry.id,
        sourceText: entry.sourceText,
        translationText: entry.translationText,
        facts: facts,
        reasonCode: rule.reasonCode,
      );
    }

    final rendered = engine.explain(
      ExplainerRequest(
        contentId: entry.id,
        reasonCode: rule.reasonCode,
        correct: rule.correct,
        observedForm: request.observedForm,
        pronoun: request.pronoun,
        arguments: rule.arguments,
        maxVerbForms: maxVerbForms,
      ),
    );

    return ExplainerResult(
      status: ExplainerStatus.explained,
      contentId: entry.id,
      sourceText: entry.sourceText,
      translationText: entry.translationText,
      facts: facts,
      reasonCode: rendered.reasonCode,
      explanationText: rendered.text,
      explanationLanguageCode: rendered.languageCode,
    );
  }

  List<ExplainerFact> _factsFor(
    ExplainerCorpusEntry entry, {
    required List<ExplainerVerbEvidence> verbRows,
    required ExplainerVerbEvidence? selectedVerb,
  }) {
    final facts = <ExplainerFact>[];

    if (entry.translationText.isNotEmpty) {
      facts.add(
        ExplainerFact(
          kind: ExplainerFactKind.meaning,
          value: entry.translationText,
          source: ExplainerEvidenceSource.indexedSqliteCorpus,
          evidence: <String>[entry.sourceText],
        ),
      );
    }

    if (entry.grammaticalMarker.isNotEmpty) {
      facts.add(
        ExplainerFact(
          kind: ExplainerFactKind.grammaticalMarker,
          value: entry.grammaticalMarker,
          source: ExplainerEvidenceSource.indexedSqliteCorpus,
          evidence: <String>[entry.sourceText],
        ),
      );
    }

    if (entry.pluralForm.isNotEmpty) {
      facts.add(
        ExplainerFact(
          kind: ExplainerFactKind.pluralForm,
          value: entry.pluralForm,
          source: ExplainerEvidenceSource.indexedSqliteCorpus,
          evidence: <String>[entry.sourceText],
        ),
      );
    }

    if (entry.sentence.isNotEmpty || entry.sentenceTranslation.isNotEmpty) {
      facts.add(
        ExplainerFact(
          kind: ExplainerFactKind.usageExample,
          value: entry.sentence,
          source: ExplainerEvidenceSource.indexedSqliteCorpus,
          evidence: <String>[entry.sentenceTranslation],
        ),
      );
    }

    if (verbRows.isNotEmpty) {
      if (selectedVerb != null) {
        facts.add(
          ExplainerFact(
            kind: ExplainerFactKind.verbAgreement,
            value: selectedVerb.form,
            source: ExplainerEvidenceSource.indexedSqliteCorpus,
            evidence: <String>[
              selectedVerb.person,
              selectedVerb.personTranslation,
              selectedVerb.infinitive,
              selectedVerb.example,
              selectedVerb.exampleTranslation,
            ],
          ),
        );
        if (selectedVerb.past.isNotEmpty) {
          facts.add(
            ExplainerFact(
              kind: ExplainerFactKind.pastForm,
              value: selectedVerb.past,
              source: ExplainerEvidenceSource.indexedSqliteCorpus,
              evidence: <String>[
                selectedVerb.pastTranslation,
                selectedVerb.infinitive,
              ],
            ),
          );
        }
      } else {
        facts.add(
          ExplainerFact(
            kind: ExplainerFactKind.verbAgreement,
            value: entry.sourceText,
            source: ExplainerEvidenceSource.indexedSqliteCorpus,
            evidence: verbRows.expand(_verbEvidenceLines),
          ),
        );
      }
    }

    return List<ExplainerFact>.unmodifiable(facts);
  }

  _ExplainerRule _resolveRule(
    ExplainerRequest request, {
    required ExplainerCorpusEntry entry,
    required ExplainerVerbEvidence? expectedVerb,
  }) {
    final corpusArguments = <String, String>{
      'source': entry.sourceText,
      'translation': entry.translationText,
      'marker': entry.grammaticalMarker,
      'plural': entry.pluralForm,
      'sentence': entry.sentence,
      'sentenceTranslation': entry.sentenceTranslation,
    };

    if (expectedVerb != null) {
      corpusArguments.addAll(<String, String>{
        'infinitive': expectedVerb.infinitive,
        'pronoun': expectedVerb.person,
        'expected': expectedVerb.form,
        'observed': request.observedForm?.trim() ?? '',
      });
    }

    final explicitReason = request.reasonCode?.trim();
    if (explicitReason != null && explicitReason.isNotEmpty) {
      return _ExplainerRule(
        reasonCode: explicitReason,
        correct: request.correct ??
            _verbOutcome(
              observedForm: request.observedForm,
              expectedVerb: expectedVerb,
            ) ??
            true,
        arguments: <String, String>{
          ...request.arguments,
          ...corpusArguments,
        },
      );
    }

    if (expectedVerb != null &&
        (request.observedForm?.trim().isNotEmpty ?? false)) {
      return _ExplainerRule(
        reasonCode: 'lexicon.verb.agreement',
        correct: request.correct ??
            _verbOutcome(
              observedForm: request.observedForm,
              expectedVerb: expectedVerb,
            )!,
        arguments: <String, String>{
          ...request.arguments,
          ...corpusArguments,
        },
      );
    }

    if (entry.grammaticalMarker.isNotEmpty) {
      return _ExplainerRule(
        reasonCode: 'lexicon.grammatical_marker',
        correct: request.correct ?? true,
        arguments: <String, String>{
          ...request.arguments,
          ...corpusArguments,
        },
      );
    }

    if (entry.pluralForm.isNotEmpty) {
      return _ExplainerRule(
        reasonCode: 'lexicon.plural_form',
        correct: request.correct ?? true,
        arguments: <String, String>{
          ...request.arguments,
          ...corpusArguments,
        },
      );
    }

    if (entry.sentence.isNotEmpty || entry.sentenceTranslation.isNotEmpty) {
      return _ExplainerRule(
        reasonCode: 'lexicon.usage_example',
        correct: request.correct ?? true,
        arguments: <String, String>{
          ...request.arguments,
          ...corpusArguments,
        },
      );
    }

    return _ExplainerRule(
      reasonCode: 'lexicon.meaning',
      correct: request.correct ?? true,
      arguments: <String, String>{
        ...corpusArguments,
        ...request.arguments,
      },
    );
  }

  ExplainerVerbEvidence? _selectExpectedVerbEvidence(
    List<ExplainerVerbEvidence> rows, {
    String? pronoun,
    String? observedForm,
  }) {
    final safePronoun = pronoun?.trim().toLowerCase() ?? '';
    if (safePronoun.isNotEmpty) {
      for (final row in rows) {
        if (row.person.toLowerCase() == safePronoun) return row;
      }
    }

    final safeForm = observedForm?.trim().toLowerCase() ?? '';
    if (safeForm.isNotEmpty) {
      for (final row in rows) {
        if (row.form.toLowerCase() == safeForm) return row;
      }
    }
    return null;
  }

  bool? _verbOutcome({
    required String? observedForm,
    required ExplainerVerbEvidence? expectedVerb,
  }) {
    final observed = observedForm?.trim().toLowerCase() ?? '';
    if (observed.isEmpty || expectedVerb == null) return null;
    return observed == expectedVerb.form.toLowerCase();
  }

  Iterable<String> _verbEvidenceLines(ExplainerVerbEvidence row) sync* {
    if (row.person.isNotEmpty) yield row.person;
    if (row.personTranslation.isNotEmpty) yield row.personTranslation;
    if (row.form.isNotEmpty) yield row.form;
    if (row.example.isNotEmpty) yield row.example;
    if (row.exampleTranslation.isNotEmpty) {
      yield row.exampleTranslation;
    }
  }
}

final class _ExplainerRule {
  _ExplainerRule({
    required this.reasonCode,
    required this.correct,
    required Map<String, String> arguments,
  }) : arguments = Map<String, String>.unmodifiable(arguments);

  final String reasonCode;
  final bool correct;
  final Map<String, String> arguments;
}
