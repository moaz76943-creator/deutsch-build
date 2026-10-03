import '../../lexicon_search/domain/german_search_normalizer.dart';

/// Compatibility facade retained for the existing search feature.
/// The canonical normalization logic lives in lexicon_search/domain.
abstract final class SearchTextNormalizer {
  static Set<String> variants(String input) =>
      GermanSearchNormalizer.variants(input);
}
