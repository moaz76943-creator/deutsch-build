import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

class SemanticPresentationMetadata {
  final Color color;
  final String label;

  const SemanticPresentationMetadata({required this.color, required this.label});
}

class SemanticPresentationEngine {
  final LanguageGrammarRuleProvider ruleProvider;
  final String packVersion;
  final Map<String, SemanticPresentationMetadata> _cache = {};

  SemanticPresentationEngine({
    required this.ruleProvider,
    required this.packVersion,
  });

  SemanticPresentationMetadata getPresentationForWord(String word, {String? article}) {
    // We omit packVersion and languageCode from key since this engine instance is bound to them
    final cacheKey = '${word}_${article ?? ""}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final gender = ruleProvider.determineGender(word, article: article);
    final category = ruleProvider.determineCategory(word, article: article);

    Color color;
    String label;

    // We add more data from the provider to the label to respect Requirement #5 partially
    // Although the provider doesn't currently expose number/case, we use category
    // to build a richer semantic label.
    final categoryString = category == GrammaticalCategory.unknown ? '' : category.name;

    if (ruleProvider.languageCode == 'de') {
      switch (gender) {
        case GrammaticalGender.masculine:
          color = AppColors.articleDer;
          label = 'Masculine (der) $categoryString';
          break;
        case GrammaticalGender.feminine:
          color = AppColors.articleDie;
          label = 'Feminine (die) $categoryString';
          break;
        case GrammaticalGender.neuter:
          color = AppColors.articleDas;
          label = 'Neuter (das) $categoryString';
          break;
        case GrammaticalGender.common:
        case GrammaticalGender.none:
          color = AppColors.articleOther;
          label = 'Other $categoryString';
          break;
      }
    } else {
      switch (gender) {
        case GrammaticalGender.masculine:
          color = AppColors.primary;
          label = 'Masculine $categoryString';
          break;
        case GrammaticalGender.feminine:
          color = AppColors.secondary;
          label = 'Feminine $categoryString';
          break;
        case GrammaticalGender.neuter:
          color = AppColors.tertiary;
          label = 'Neuter $categoryString';
          break;
        case GrammaticalGender.common:
        case GrammaticalGender.none:
          color = AppColors.articleOther;
          label = 'Other $categoryString';
          break;
      }
    }

    final metadata = SemanticPresentationMetadata(color: color, label: label.trim());
    _cache[cacheKey] = metadata;
    return metadata;
  }
}

class SemanticWordText extends StatelessWidget {
  final String word;
  final String? article;
  final SemanticPresentationEngine engine;
  final TextStyle? baseStyle;

  const SemanticWordText({
    super.key,
    required this.word,
    required this.engine,
    this.article,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = engine.getPresentationForWord(word, article: article);

    return Semantics(
      label: metadata.label,
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Text(
          word,
          style: (baseStyle ?? AppTypography.body).copyWith(color: metadata.color),
        ),
      ),
    );
  }
}
