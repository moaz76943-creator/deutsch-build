import '../language/german/german_content_pack.dart';
import 'search_index.dart';
import 'verb_index.dart';
import '../language/german/german_text_normalizer.dart';

/// Temporary composition facade for callers that still rely on global runtime sources.
final class LegacySearchIndex {
  LegacySearchIndex._();

  static SearchIndex? _instance;

  static SearchIndex get instance => _instance ??= SearchIndex(
        const GermanContentPack().items,
        VerbIndex(textNormalizer: const GermanTextNormalizer()),
        const GermanTextNormalizer(),
      );
}
