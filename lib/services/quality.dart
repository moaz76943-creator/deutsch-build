import '../models/content.dart';
import '../language/german/german_content_quality.dart';

/// Compatibility facade for legacy service callers.
///
/// New code should receive LanguageContentQuality from the selected LanguagePack.
final class ContentQuality {
  static final GermanContentQuality _delegate = const GermanContentQuality();
  static final Expando<List<String>> _validationCache = Expando<List<String>>(
    'contentQualityIssues',
  );

  static List<String> issues(ContentItem item) {
    final cached = _validationCache[item];
    if (cached != null) return cached;
    final computed = _delegate.issues(item);
    _validationCache[item] = computed;
    return computed;
  }

  static List<String> validate(ContentItem item) => issues(item);
  static bool isLearnable(ContentItem item) => issues(item).isEmpty;

  static bool uniqueGerman(List<ContentItem> xs) =>
      xs.map((x) => x.german.trim().toLowerCase()).toSet().length == xs.length;

  static bool uniqueIds(List<ContentItem> xs) =>
      xs.map((x) => x.id.trim()).toSet().length == xs.length;

  static List<String> collectionErrors(List<ContentItem> xs) {
    final errors = <String>[];
    final ids = <String>{};
    final german = <String>{};
    for (final x in xs) {
      final id = x.id.trim();
      final de = x.german.trim().toLowerCase();
      if (id.isNotEmpty && !ids.add(id)) errors.add('duplicate id: $id');
      if (de.isNotEmpty && !german.add(de)) errors.add('duplicate german: $de');
    }
    return errors;
  }

  static bool question(String value) => value.trim().endsWith('?');
}
