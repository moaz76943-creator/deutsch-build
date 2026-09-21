import '../language_content_pack.dart';
import '../../services/content_engine.dart';
import '../../models/content.dart';
import '../../data/content_a1.dart';
import '../../services/verb_index.dart';
import 'german_text_normalizer.dart';

/// German content adapter. Editable sources are compiled into the package-local
/// runtime facade before Flutter analysis/build.
abstract interface class GermanContentSource implements ContentSource<ContentItem> {}

final class LegacyGermanContentSource implements GermanContentSource {
  const LegacyGermanContentSource();
  @override
  Iterable<ContentItem> get items => a1;
}

final class JsonGermanContentSource implements GermanContentSource {
  const JsonGermanContentSource();
  @override
  Iterable<ContentItem> get items => generatedContentItems;
}

final class GermanContentPack implements LanguageContentPack {
  const GermanContentPack();

  static const useGeneratedContent =
      bool.fromEnvironment('DEUTSCH_JSON_CONTENT', defaultValue: false);

  ContentEngine<ContentItem> get _engine => ContentEngine<ContentItem>(
        useGeneratedContent
            ? const JsonGermanContentSource()
            : const LegacyGermanContentSource(),
      );

  @override
  List<ContentItem> get items => _engine.items.toList(growable: false);

  @override
  VerbIndex get verbIndex =>
      VerbIndex(textNormalizer: const GermanTextNormalizer());
}
