export '../language/language_content_intelligence.dart';

import '../core/content_contract.dart';
import '../language/language_content_intelligence.dart';

/// Shared service facade. Language heuristics live behind the injected
/// LanguageContentIntelligence implementation.
final class ContentIntelligence {
  final LanguageContentIntelligence delegate;
  List<LearningContent>? _cachedCorpus;
  ContentIntelligenceReport? _cachedReport;

  ContentIntelligence(this.delegate);

  ContentProfile profile(LearningContent item) => delegate.profile(item);

  ContentIntelligenceReport analyze(List<LearningContent> items) =>
      delegate.analyze(items);

  ContentIntelligenceReport cachedReport(List<LearningContent> items) {
    if (identical(_cachedCorpus, items) && _cachedReport != null)
      return _cachedReport!;
    _cachedCorpus = items;
    _cachedReport = delegate.analyze(items);
    return _cachedReport!;
  }

  Map<ContentLevel, List<LearningContent>> curriculum(
    List<LearningContent> items,
  ) =>
      delegate.curriculum(items);
}
