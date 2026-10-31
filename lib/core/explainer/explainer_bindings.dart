import '../../features/srs/corpus_sqlite_repository.dart';
import '../explain_why/deterministic_explain_why_engine.dart';
import 'explainer_corpus_reader.dart';
import 'explainer_service.dart';

final class ExplainerBindings {
  const ExplainerBindings._();

  static ExplainerService fromIndexedSrsCorpus(
    IndexedSrsCorpusRepository repository, {
    ExplainWhyEngine? explainWhyEngine,
  }) =>
      ExplainerService(
        corpusReader: IndexedSrsExplainerCorpusReader(repository),
        explainWhyEngine: explainWhyEngine,
      );
}
