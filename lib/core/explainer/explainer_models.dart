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
  ExplainerRequest({
    this.contentId = '',
    this.reasonCode,
    this.correct,
    this.observedForm,
    this.pronoun,
    Map<String, String> arguments = const <String, String>{},
    this.maxVerbForms = 6,
  }) : arguments = Map<String, String>.unmodifiable(arguments);

  final String contentId;
  final String? reasonCode;
  final bool? correct;
  final String? observedForm;
  final String? pronoun;
  final Map<String, String> arguments;
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
    this.reasonCode,
    String explanationText = '',
    String explanationLanguageCode = '',
  })  : sourceText = sourceText.trim(),
        translationText = translationText.trim(),
        facts = List<ExplainerFact>.unmodifiable(facts),
        explanationText = explanationText.trim(),
        explanationLanguageCode = explanationLanguageCode.trim();

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
  final String? reasonCode;
  final String explanationText;
  final String explanationLanguageCode;

  bool get found => status == ExplainerStatus.explained;
}
