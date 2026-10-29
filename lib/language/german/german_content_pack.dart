import '../language_content_pack.dart';
import '../../models/content.dart';
import '../../models/verb_conjugation.dart';
import '../../services/verb_index.dart';
import 'german_text_normalizer.dart';

/// German language metadata only.
///
/// The production corpus and verb rows are no longer embedded as compiled Dart
/// constants. They are resolved from the admitted, indexed local SQLite corpus
/// by ActivePackRuntimeProvider.
final class GermanContentPack implements LanguageContentPack {
  const GermanContentPack();

  @override
  List<ContentItem> get items => const <ContentItem>[];

  @override
  VerbIndex get verbIndex => VerbIndex.fromRows(
        textNormalizer: const GermanTextNormalizer(),
        rows: const <VerbConjugation>[],
      );
}
