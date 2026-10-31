import '../../../core/localization/german_article_style.dart';
import 'preposition_models.dart';

final class PrepositionCaseRules {
  const PrepositionCaseRules();

  GermanGrammaticalCase caseFor({
    required PrepositionItem preposition,
    required SpatialQuestion spatialQuestion,
  }) {
    return switch (preposition.type) {
      PrepositionType.accusative => GermanGrammaticalCase.accusative,
      PrepositionType.dative => GermanGrammaticalCase.dative,
      PrepositionType.twoWay => switch (spatialQuestion) {
          SpatialQuestion.wohin => GermanGrammaticalCase.accusative,
          SpatialQuestion.wo => GermanGrammaticalCase.dative,
          SpatialQuestion.none => throw StateError(
              'Two-way prepositions require a Wo/Wohin context.',
            ),
        },
    };
  }

  GermanArticleCaseForm articleForm({
    required GermanArticle baseArticle,
    required GermanGrammaticalCase grammaticalCase,
  }) {
    final surface = switch ((baseArticle, grammaticalCase)) {
      (GermanArticle.der, GermanGrammaticalCase.accusative) => 'den',
      (GermanArticle.der, GermanGrammaticalCase.dative) => 'dem',
      (GermanArticle.die, GermanGrammaticalCase.accusative) => 'die',
      (GermanArticle.die, GermanGrammaticalCase.dative) => 'der',
      (GermanArticle.das, GermanGrammaticalCase.accusative) => 'das',
      (GermanArticle.das, GermanGrammaticalCase.dative) => 'dem',
    };
    return GermanArticleCaseForm(
      baseArticle: baseArticle,
      grammaticalCase: grammaticalCase,
      surfaceArticle: surface,
    );
  }
}
