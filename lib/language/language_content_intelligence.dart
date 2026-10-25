import '../core/content_contract.dart';

/// Language-owned content intelligence contract.
///
/// The result models are neutral; the implementation owns all language-specific
/// lexical, normalization, and curriculum heuristics.
abstract interface class LanguageContentIntelligence {
  ContentProfile profile(LearningContent item);
  ContentIntelligenceReport analyze(List<LearningContent> items);
  Map<ContentLevel, List<LearningContent>> curriculum(
    List<LearningContent> items,
  );
}

enum ContentLevel { a1, a2, b1, unknown }

class ContentProfile {
  final String itemId;
  final ContentLevel inferredLevel;
  final double difficulty;
  final String wordFamily;
  final String lexicalClass;
  final bool hasArticle;
  final bool hasPlural;
  final bool hasExample;
  final double qualityScore;
  const ContentProfile({
    required this.itemId,
    required this.inferredLevel,
    required this.difficulty,
    required this.wordFamily,
    required this.lexicalClass,
    required this.hasArticle,
    required this.hasPlural,
    required this.hasExample,
    required this.qualityScore,
  });
}

class CurriculumGap {
  final String dimension;
  final String value;
  final int count;
  final String recommendation;
  const CurriculumGap(
    this.dimension,
    this.value,
    this.count,
    this.recommendation,
  );
}

class ContentIntelligenceReport {
  final int total;
  final Map<ContentLevel, int> levelCounts;
  final Map<String, int> topicCounts;
  final Map<String, int> skillCounts;
  final int articleCoverage;
  final int pluralCoverage;
  final int exampleCoverage;
  final int duplicateGermanCount;
  final int nearDuplicatePairCount;
  final int wordFamilyCount;
  final List<CurriculumGap> gaps;
  const ContentIntelligenceReport({
    required this.total,
    required this.levelCounts,
    required this.topicCounts,
    required this.skillCounts,
    required this.articleCoverage,
    required this.pluralCoverage,
    required this.exampleCoverage,
    required this.duplicateGermanCount,
    required this.nearDuplicatePairCount,
    required this.wordFamilyCount,
    required this.gaps,
  });
  int get a1Count => levelCounts[ContentLevel.a1] ?? 0;
  int get a2Count => levelCounts[ContentLevel.a2] ?? 0;
  int get b1Count => levelCounts[ContentLevel.b1] ?? 0;
}
