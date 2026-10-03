import '../core/srs_facets.dart';

final class GrammarExampleDetail {
  const GrammarExampleDetail({required this.german, required this.arabic});

  final String german;
  final String arabic;
}

final class GrammarRuleDetail {
  const GrammarRuleDetail({
    required this.id,
    required this.topicId,
    required this.title,
    required this.explanationAr,
    required this.orderIndex,
    this.table = const <List<String>>[],
    this.examples = const <GrammarExampleDetail>[],
  });

  final String id;
  final String topicId;
  final String title;
  final String explanationAr;
  final int orderIndex;
  final List<List<String>> table;
  final List<GrammarExampleDetail> examples;
}

final class GrammarFacetEvidence {
  const GrammarFacetEvidence({
    required this.facetType,
    required this.cardCount,
    required this.failures,
    required this.lapses,
    required this.pressure,
  });

  final ReviewFacetType facetType;
  final int cardCount;
  final int failures;
  final int lapses;
  final int pressure;
}

final class GrammarEvidenceItem {
  const GrammarEvidenceItem({
    required this.itemId,
    required this.sourceText,
    required this.translationText,
    required this.facetType,
    required this.failures,
    required this.lapses,
    required this.pressure,
  });

  final String itemId;
  final String sourceText;
  final String translationText;
  final ReviewFacetType facetType;
  final int failures;
  final int lapses;
  final int pressure;
}
