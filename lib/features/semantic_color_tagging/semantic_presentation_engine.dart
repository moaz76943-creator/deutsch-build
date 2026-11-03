import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

class SemanticPresentationMetadata {
  final Color? color;
  final String label;

  const SemanticPresentationMetadata({this.color, required this.label});
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
    final cacheKey = '${word}_${article ?? ""}_$packVersion';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    Color? color;
    List<String> labelParts = [];

    final capabilities = ruleProvider.capabilityProfile;

    if (capabilities.hasGender) {
      final gender = ruleProvider.determineGender(word, article: article);
      if (ruleProvider.languageCode == 'de') {
        switch (gender) {
          case GrammaticalGender.masculine:
            color = AppColors.articleDer;
            labelParts.add('Masculine (der)');
            break;
          case GrammaticalGender.feminine:
            color = AppColors.articleDie;
            labelParts.add('Feminine (die)');
            break;
          case GrammaticalGender.neuter:
            color = AppColors.articleDas;
            labelParts.add('Neuter (das)');
            break;
          case GrammaticalGender.common:
          case GrammaticalGender.none:
            color = AppColors.articleOther;
            labelParts.add('Other');
            break;
        }
      } else {
        switch (gender) {
          case GrammaticalGender.masculine:
            color = AppColors.primary;
            labelParts.add('Masculine');
            break;
          case GrammaticalGender.feminine:
            color = AppColors.secondary;
            labelParts.add('Feminine');
            break;
          case GrammaticalGender.neuter:
            color = AppColors.tertiary;
            labelParts.add('Neuter');
            break;
          case GrammaticalGender.common:
          case GrammaticalGender.none:
            color = AppColors.articleOther;
            labelParts.add('Other');
            break;
        }
      }
    } else if (capabilities.hasNounClasses) {
      final nounClass = ruleProvider.determineNounClass(word);
      if (nounClass != null) {
        color = AppColors.primary; // default color for noun classes when not German
        labelParts.add('Class $nounClass');
      }
    }

    final category = ruleProvider.determineCategory(word, article: article);
    if (category != GrammaticalCategory.unknown) {
      labelParts.add(category.name);
    }

    if (capabilities.hasCases) {
      final grammaticalCase = ruleProvider.determineCase(word);
      if (grammaticalCase != null && grammaticalCase != GrammaticalCase.none && grammaticalCase != GrammaticalCase.unknown) {
        labelParts.add(grammaticalCase.name);
      }
    }

    if (capabilities.hasNumber) {
      final number = ruleProvider.determineNumber(word);
      if (number != null && number != GrammaticalNumber.none && number != GrammaticalNumber.unknown) {
        labelParts.add(number.name);
      }
    }

    if (capabilities.hasTense) {
      final tense = ruleProvider.determineTense(word);
      if (tense != null && tense != Tense.none && tense != Tense.unknown) {
        labelParts.add(tense.name);
      }
    }

    if (capabilities.hasAspect) {
      final aspect = ruleProvider.determineAspect(word);
      if (aspect != null && aspect != Aspect.none && aspect != Aspect.unknown) {
        labelParts.add(aspect.name);
      }
    }

    if (capabilities.hasMood) {
      final mood = ruleProvider.determineMood(word);
      if (mood != null && mood != Mood.none && mood != Mood.unknown) {
        labelParts.add(mood.name);
      }
    }

    String finalLabel = labelParts.isEmpty ? word : labelParts.join(' ');

    final metadata = SemanticPresentationMetadata(color: color, label: finalLabel);
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
          style: metadata.color != null
              ? (baseStyle ?? AppTypography.body).copyWith(color: metadata.color)
              : (baseStyle ?? AppTypography.body),
        ),
      ),
    );
  }
}
