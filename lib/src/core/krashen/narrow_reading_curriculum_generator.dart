enum ThematicDomain {
  astronomyAndNavigation, // فلك وملاحة
  islamicArchitectureAndGeometry, // عمارة وهندسة
  botanyAndHerbalMedicine, // نبات وطب الأعشاب
  ethicalCommerceAndTrade, // تجارة وأخلاق التعامل
  travelAndGeography, // رحلات وجغرافيا
}

class NarrowReadingArticle {
  final String id;
  final ThematicDomain domain;
  final String title;
  final String passageText;
  final List<String> targetThematicLemmas;
  final String languageCode;

  const NarrowReadingArticle({
    required this.id,
    required this.domain,
    required this.title,
    required this.passageText,
    required this.targetThematicLemmas,
    required this.languageCode,
  });
}

class NarrowReadingCluster {
  final ThematicDomain domain;
  final String languageCode;
  final List<NarrowReadingArticle> articles;
  final double vocabularyRecyclingRate; // Percentage of shared core vocabulary across articles

  const NarrowReadingCluster({
    required this.domain,
    required this.languageCode,
    required this.articles,
    required this.vocabularyRecyclingRate,
  });
}

/// Sovereign on-device Krashen Narrow Reading Curriculum Generator.
/// Implements Stephen Krashen's Narrow Reading hypothesis ("reading repeatedly within
/// the same topic allows natural vocabulary recycling and rapid cognitive ease").
class NarrowReadingCurriculumGenerator {
  final Map<ThematicDomain, List<NarrowReadingArticle>> _articlesByDomain = {};

  NarrowReadingCurriculumGenerator();

  void registerArticle(NarrowReadingArticle article) {
    _articlesByDomain.putIfAbsent(article.domain, () => []).add(article);
  }

  /// Builds a cohesive narrow reading cluster with high lexical recycling rate.
  NarrowReadingCluster buildCluster({
    required ThematicDomain domain,
    required String languageCode,
    int maxArticles = 3,
  }) {
    final pool = _articlesByDomain[domain]
            ?.where((a) => a.languageCode == languageCode)
            .toList() ??
        [];

    if (pool.isEmpty) {
      return NarrowReadingCluster(
        domain: domain,
        languageCode: languageCode,
        articles: const [],
        vocabularyRecyclingRate: 0.0,
      );
    }

    final selected = pool.take(maxArticles).toList();

    // Compute pairwise vocabulary overlap across articles
    double totalRecycleScore = 0.0;
    int comparisons = 0;

    for (int i = 0; i < selected.length; i++) {
      final setA = selected[i].targetThematicLemmas.toSet();
      for (int j = i + 1; j < selected.length; j++) {
        final setB = selected[j].targetThematicLemmas.toSet();
        if (setA.isNotEmpty && setB.isNotEmpty) {
          final common = setA.intersection(setB).length;
          final union = setA.union(setB).length;
          totalRecycleScore += (common / union);
          comparisons++;
        }
      }
    }

    final avgRecycle = comparisons > 0 ? (totalRecycleScore / comparisons) * 100.0 : 100.0;

    return NarrowReadingCluster(
      domain: domain,
      languageCode: languageCode,
      articles: selected,
      vocabularyRecyclingRate: avgRecycle,
    );
  }
}
