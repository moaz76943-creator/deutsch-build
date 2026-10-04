import '../../features/srs/corpus_sqlite_repository.dart';

final class ExplainerCorpusEntry {
  ExplainerCorpusEntry({
    required this.id,
    required String sourceText,
    required String translationText,
    required String sentence,
    required String sentenceTranslation,
    required String grammaticalMarker,
    required String pluralForm,
  })  : sourceText = sourceText.trim(),
        translationText = translationText.trim(),
        sentence = sentence.trim(),
        sentenceTranslation = sentenceTranslation.trim(),
        grammaticalMarker = grammaticalMarker.trim(),
        pluralForm = pluralForm.trim();

  final String id;
  final String sourceText;
  final String translationText;
  final String sentence;
  final String sentenceTranslation;
  final String grammaticalMarker;
  final String pluralForm;
}

final class ExplainerVerbEvidence {
  ExplainerVerbEvidence({
    required String infinitive,
    required String person,
    required String personTranslation,
    required String form,
    required String past,
    required String pastTranslation,
    required String example,
    required String exampleTranslation,
  })  : infinitive = infinitive.trim(),
        person = person.trim(),
        personTranslation = personTranslation.trim(),
        form = form.trim(),
        past = past.trim(),
        pastTranslation = pastTranslation.trim(),
        example = example.trim(),
        exampleTranslation = exampleTranslation.trim();

  final String infinitive;
  final String person;
  final String personTranslation;
  final String form;
  final String past;
  final String pastTranslation;
  final String example;
  final String exampleTranslation;
}

abstract interface class ExplainerCorpusReader {
  Future<ExplainerCorpusEntry?> fetchById(String contentId);

  Future<List<ExplainerVerbEvidence>> fetchVerbForms(
    String infinitive, {
    int limit = 6,
  });
}

/// Adapter over the already admitted [IndexedSrsCorpusRepository].
///
/// It performs no work in the constructor and therefore adds no startup I/O.
/// Every request is bounded to one content row and at most 12 verb rows.
final class IndexedSrsExplainerCorpusReader
    implements ExplainerCorpusReader {
  const IndexedSrsExplainerCorpusReader(this.repository);

  static const int maxVerbRows = 12;
  static const int maxContentIdLength = 160;
  static const int maxInfinitiveLength = 200;

  final IndexedSrsCorpusRepository repository;

  @override
  Future<ExplainerCorpusEntry?> fetchById(String contentId) async {
    final safeId = contentId.trim();
    if (safeId.isEmpty || safeId.length > maxContentIdLength) {
      return null;
    }

    final rows = await repository.fetchByIds(<String>[safeId]);
    if (rows.isEmpty) return null;

    final item = rows.single;
    return ExplainerCorpusEntry(
      id: item.id,
      sourceText: item.german,
      translationText: item.arabic,
      sentence: item.sentence,
      sentenceTranslation: item.sentenceAr,
      grammaticalMarker: item.article,
      pluralForm: item.plural,
    );
  }

  @override
  Future<List<ExplainerVerbEvidence>> fetchVerbForms(
    String infinitive, {
    int limit = 6,
  }) async {
    final safeInfinitive = infinitive.trim();
    if (safeInfinitive.isEmpty ||
        safeInfinitive.length > maxInfinitiveLength) {
      return const <ExplainerVerbEvidence>[];
    }

    final safeLimit = limit.clamp(1, maxVerbRows).toInt();
    final rows = await repository.fetchVerbRows(
      infinitive: safeInfinitive,
      limit: safeLimit,
    );

    return rows
        .map(
          (row) => ExplainerVerbEvidence(
            infinitive: row.infinitive,
            person: row.person,
            personTranslation: row.personAr,
            form: row.form,
            past: row.past,
            pastTranslation: row.pastArabic,
            example: row.example,
            exampleTranslation: row.exampleAr,
          ),
        )
        .toList(growable: false);
  }
}
