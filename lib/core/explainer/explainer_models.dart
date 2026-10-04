enum ExplainerStatus {
  explained,
  notFound,
}

enum ExplainerFactKind {
  meaning,
  grammaticalMarker,
  pluralForm,
  usageExample,
  verbAgreement,
  pastForm,
}

enum ExplainerEvidenceSource {
  indexedSqliteCorpus,
}

final class ExplainerRequest {
  const ExplainerRequest({
    required this.contentId,
    this.observedForm,
    this.pronoun,
    this.maxVerbForms = 6,
  });

  final String contentId;
  final String? observedForm;
  final String? pronoun;
  final int maxVerbForms;
}

final class ExplainerFact {
  ExplainerFact({
    required this.kind,
    required String value,
    required this.source,
    Iterable<String> evidence = const <String>[],
  })  : value = value.trim(),
        evidence = List<String>.unmodifiable(
          evidence
              .map((entry) => entry.trim())
              .where((entry) => entry.isNotEmpty),
        );

  final ExplainerFactKind kind;
  final String value;
  final ExplainerEvidenceSource source;
  final List<String> evidence;
}

final class ExplainerResult {
  ExplainerResult({
    required this.status,
    required this.contentId,
    required String sourceText,
    required String translationText,
    required Iterable<ExplainerFact> facts,
  })  : sourceText = sourceText.trim(),
        translationText = translationText.trim(),
        facts = List<ExplainerFact>.unmodifiable(facts);

  factory ExplainerResult.notFound(String contentId) => ExplainerResult(
        status: ExplainerStatus.notFound,
        contentId: contentId,
        sourceText: '',
        translationText: '',
        facts: const <ExplainerFact>[],
      );

  final ExplainerStatus status;
  final String contentId;
  final String sourceText;
  final String translationText;
  final List<ExplainerFact> facts;

  bool get found => status == ExplainerStatus.explained;
}
