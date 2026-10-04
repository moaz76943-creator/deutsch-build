import 'explainer_corpus_reader.dart';
import 'explainer_models.dart';

/// Offline-first, evidence-only explanation engine.
///
/// The service is lazy: constructing it does not open a database or perform
/// corpus work. Each explanation uses at most two bounded repository queries:
/// one item lookup and one indexed verb lookup.
final class ExplainerService {
  const ExplainerService({
    required ExplainerCorpusReader corpusReader,
  }) : _corpusReader = corpusReader;

  static const int maxVerbFormsPerExplanation = 12;
  static const int maxContentIdLength = 160;

  final ExplainerCorpusReader _corpusReader;

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

    final verbRows = await _corpusReader.fetchVerbForms(
      entry.sourceText,
      limit: maxVerbForms,
    );
    if (verbRows.isNotEmpty) {
      final selected = _selectVerbEvidence(
        verbRows,
        observedForm: request.observedForm,
        pronoun: request.pronoun,
      );

      if (selected != null) {
        facts.add(
          ExplainerFact(
            kind: ExplainerFactKind.verbAgreement,
            value: selected.form,
            source: ExplainerEvidenceSource.indexedSqliteCorpus,
            evidence: <String>[
              selected.person,
              selected.personTranslation,
              selected.infinitive,
              selected.example,
              selected.exampleTranslation,
            ],
          ),
        );
        if (selected.past.isNotEmpty) {
          facts.add(
            ExplainerFact(
              kind: ExplainerFactKind.pastForm,
              value: selected.past,
              source: ExplainerEvidenceSource.indexedSqliteCorpus,
              evidence: <String>[
                selected.pastTranslation,
                selected.infinitive,
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

    return ExplainerResult(
      status: ExplainerStatus.explained,
      contentId: entry.id,
      sourceText: entry.sourceText,
      translationText: entry.translationText,
      facts: facts,
    );
  }

  ExplainerVerbEvidence? _selectVerbEvidence(
    List<ExplainerVerbEvidence> rows, {
    String? observedForm,
    String? pronoun,
  }) {
    final safeForm = observedForm?.trim().toLowerCase();
    final safePronoun = pronoun?.trim().toLowerCase();
    if ((safeForm == null || safeForm.isEmpty) &&
        (safePronoun == null || safePronoun.isEmpty)) {
      return null;
    }

    for (final row in rows) {
      final formMatches = safeForm == null ||
          safeForm.isEmpty ||
          row.form.toLowerCase() == safeForm;
      final pronounMatches = safePronoun == null ||
          safePronoun.isEmpty ||
          row.person.toLowerCase() == safePronoun;
      if (formMatches && pronounMatches) return row;
    }
    return null;
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
