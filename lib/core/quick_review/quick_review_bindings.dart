import '../../features/srs/corpus_sqlite_repository.dart';
import 'quick_review_corpus_reader.dart';
import 'quick_review_service.dart';

final class QuickReviewBindings {
  const QuickReviewBindings._();

  static QuickReviewService fromIndexedSrsCorpus(
    IndexedSrsCorpusRepository repository,
  ) =>
      QuickReviewService(
        corpusReader: IndexedSrsQuickReviewCorpusReader(repository),
      );
}
