import '../../core/content_contract.dart';
import '../language_text_normalizer.dart';
import '../language_content_intelligence.dart';

/// V123 content intelligence.
///
/// CEFR is not stored as authoritative metadata in LearningContent. The level
/// exposed here is therefore an inferred curriculum band, not a certification.
final class GermanContentIntelligence implements LanguageContentIntelligence {
  final LanguageTextNormalizer normalizer;
  const GermanContentIntelligence({
    this.normalizer = const _GermanFallbackNormalizer(),
  });
  @override
  ContentProfile profile(LearningContent item) {
    final german = normalizer.answer(item.sourceText);
    final tokens = german.split(' ').where((x) => x.isNotEmpty).toList();
    final hasArticle = item.grammaticalMarker.trim().isNotEmpty;
    final hasPlural = item.pluralForm.trim().isNotEmpty;
    final hasExample = item.exampleText.trim().isNotEmpty &&
        item.exampleTranslationText.trim().isNotEmpty;
    final phrase = tokens.length > 1;
    final compound = german.length >= 14 && !phrase;
    var difficulty = .18 + (german.length.clamp(0, 28) / 100);
    if (phrase) difficulty += .12;
    if (compound) difficulty += .12;
    if (item.exampleText.split(' ').length >= 9) difficulty += .08;
    if (item.exampleText.contains('weil') ||
        item.exampleText.contains('dass') ||
        item.exampleText.contains('obwohl')) difficulty += .10;
    difficulty = difficulty.clamp(.05, .95).toDouble();

    final level = _inferLevel(item, difficulty);
    final lexicalClass = _lexicalClass(item);
    final family = _wordFamily(german);
    var quality = .55;
    if (hasExample) quality += .18;
    if (hasArticle) quality += .10;
    if (hasPlural || phrase) quality += .07;
    if (item.acceptedForms.isNotEmpty) quality += .05;
    quality -= german.length > 34 ? .08 : 0;

    return ContentProfile(
      itemId: item.id,
      inferredLevel: level,
      difficulty: difficulty,
      wordFamily: family,
      lexicalClass: lexicalClass,
      hasArticle: hasArticle,
      hasPlural: hasPlural,
      hasExample: hasExample,
      qualityScore: quality.clamp(.0, 1.0).toDouble(),
    );
  }

  @override
  ContentIntelligenceReport analyze(List<LearningContent> items) {
    final levels = <ContentLevel, int>{};
    final topics = <String, int>{};
    final skills = <String, int>{};
    final german = <String, int>{};
    final families = <String>{};
    var articles = 0;
    var plurals = 0;
    var examples = 0;
    final profiles = <ContentProfile>[];

    for (final item in items) {
      final p = profile(item);
      profiles.add(p);
      levels[p.inferredLevel] = (levels[p.inferredLevel] ?? 0) + 1;
      final topic = item.topic.trim().isEmpty ? 'غير مصنف' : item.topic.trim();
      topics[topic] = (topics[topic] ?? 0) + 1;
      skills[item.skill] = (skills[item.skill] ?? 0) + 1;
      final g = normalizer.answer(item.sourceText);
      german[g] = (german[g] ?? 0) + 1;
      if (p.hasArticle) articles++;
      if (p.hasPlural) plurals++;
      if (p.hasExample) examples++;
      if (p.wordFamily.isNotEmpty) families.add(p.wordFamily);
    }

    final duplicateGermanCount =
        german.values.where((x) => x > 1).fold<int>(0, (sum, x) => sum + x - 1);
    final nearDuplicatePairCount = _nearDuplicatePairs(items);
    final gaps = _gaps(items, levels, skills, articles, plurals);
    return ContentIntelligenceReport(
      total: items.length,
      levelCounts: levels,
      topicCounts: topics,
      skillCounts: skills,
      articleCoverage: articles,
      pluralCoverage: plurals,
      exampleCoverage: examples,
      duplicateGermanCount: duplicateGermanCount,
      nearDuplicatePairCount: nearDuplicatePairCount,
      wordFamilyCount: families.length,
      gaps: gaps,
    );
  }

  /// Returns curriculum buckets ordered by inferred progression.
  @override
  Map<ContentLevel, List<LearningContent>> curriculum(
    List<LearningContent> items,
  ) {
    final result = <ContentLevel, List<LearningContent>>{
      ContentLevel.a1: <LearningContent>[],
      ContentLevel.a2: <LearningContent>[],
      ContentLevel.b1: <LearningContent>[],
      ContentLevel.unknown: <LearningContent>[],
    };
    for (final item in items) {
      result[profile(item).inferredLevel]?.add(item);
    }
    return result;
  }

  ContentLevel _inferLevel(LearningContent item, double difficulty) {
    final topic = item.topic.toLowerCase();
    if (topic.contains('المستوى a2')) return ContentLevel.a2;
    if (topic.contains('المستوى a1')) return ContentLevel.a1;
    if (topic.contains('المستوى b1')) return ContentLevel.b1;
    if (item.sourceText.trim().isEmpty) return ContentLevel.unknown;
    // Heuristic only: lexical length, phrase complexity and clause markers.
    if (difficulty <= .44) return ContentLevel.a1;
    if (difficulty <= .72) return ContentLevel.a2;
    return ContentLevel.b1;
  }

  String _lexicalClass(LearningContent item) {
    final g = item.sourceText.trim();
    if (item.grammaticalMarker.isNotEmpty) return 'noun';
    if (g.startsWith('sich ')) return 'reflexivePhrase';
    if (g.split(' ').length > 1) return 'phrase';
    if (g.endsWith('en') || g.endsWith('n')) return 'possibleVerb';
    return 'other';
  }

  String _wordFamily(String word) {
    final w = word.toLowerCase();
    if (w.isEmpty) return '';
    if (w.contains(' ')) return normalizer.answer(w.split(' ').first);
    var stem = w;
    for (final suffix in const [
      'lichkeit',
      'igkeit',
      'ung',
      'heit',
      'schaft',
      'tion',
      'isch',
      'lich',
      'er',
      'en',
      'e',
    ]) {
      if (stem.length > suffix.length + 4 && stem.endsWith(suffix)) {
        stem = stem.substring(0, stem.length - suffix.length);
        break;
      }
    }
    return stem.length >= 4 ? stem : w;
  }

  int _nearDuplicatePairs(List<LearningContent> items) {
    final buckets = <String, List<String>>{};
    for (final item in items) {
      final g = normalizer.answer(item.sourceText);
      if (g.length < 5) continue;
      final key = g.substring(0, g.length.clamp(0, 5).toInt());
      (buckets[key] ??= <String>[]).add(g);
    }
    var pairs = 0;
    for (final values in buckets.values) {
      final cap = values.length > 80 ? values.sublist(0, 80) : values;
      for (var i = 0; i < cap.length; i++) {
        for (var j = i + 1; j < cap.length; j++) {
          if (cap[i] == cap[j]) continue;
          final maxLen =
              cap[i].length > cap[j].length ? cap[i].length : cap[j].length;
          if ((cap[i].length - cap[j].length).abs() <= 3 &&
              _editDistance(cap[i], cap[j]) <= (maxLen <= 9 ? 1 : 2)) pairs++;
        }
      }
    }
    return pairs;
  }

  List<CurriculumGap> _gaps(
    List<LearningContent> items,
    Map<ContentLevel, int> levels,
    Map<String, int> skills,
    int articles,
    int plurals,
  ) {
    final gaps = <CurriculumGap>[];
    final a2 = levels[ContentLevel.a2] ?? 0;
    if (items.isNotEmpty && a2 / items.length < .05) {
      gaps.add(
        const CurriculumGap(
          'curriculum',
          'A2',
          0,
          'أضف وحدات A2 تدريجيًا مع أمثلة وتراكيب عملية، ثم راجعها لغويًا بشريًا.',
        ),
      );
    }
    for (final skill in const [
      'recall',
      'transfer',
      'production',
      'listening',
    ]) {
      if ((skills[skill] ?? 0) == 0)
        gaps.add(
          CurriculumGap(
            'skill',
            skill,
            0,
            'أضف محتوى لهذه المهارة بدل الاعتماد على مهارة واحدة.',
          ),
        );
    }
    final nounCount = items.where((x) => x.grammaticalMarker.isNotEmpty).length;
    if (nounCount > 0 && articles / nounCount < .98)
      gaps.add(
        CurriculumGap(
          'metadata',
          'article',
          nounCount - articles,
          'أكمل Artikel للأسماء قبل إدخالها في التدريب الأساسي.',
        ),
      );
    if (nounCount > 0 && plurals / nounCount < .55)
      gaps.add(
        CurriculumGap(
          'metadata',
          'plural',
          nounCount - plurals,
          'وسّع بيانات الجمع للأسماء التي تدخل مسار المفردات.',
        ),
      );
    return gaps;
  }

  int _editDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final curr = List<int>.filled(b.length + 1, 0);
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      prev = curr;
    }
    return prev[b.length];
  }
}

final class _GermanFallbackNormalizer implements LanguageTextNormalizer {
  const _GermanFallbackNormalizer();
  @override
  String answer(String value) => value
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[.!?,;،؛؟]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
