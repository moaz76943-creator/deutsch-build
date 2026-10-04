import '../../features/srs/corpus_sqlite_repository.dart';
import 'explainer_corpus_reader.dart';
import 'explainer_service.dart';

final class ExplainerBindings {
  const ExplainerBindings._();

  static ExplainerService fromIndexedSrsCorpus(
    IndexedSrsCorpusRepository repository,
  ) =>
      ExplainerService(
        corpusReader: IndexedSrsExplainerCorpusReader(repository),
      );
}
