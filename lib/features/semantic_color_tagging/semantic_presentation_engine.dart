import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

class SemanticPresentationMetadata {
  final Color? color;
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

    final profile = ruleProvider.capabilityProfile;

    Color? color;
    final List<String> labelParts = [];

    // Gender
    final gender = ruleProvider.determineGender(word, article: article);
    if (profile.hasGender && gender != GrammaticalGender.none) {
      if (ruleProvider.languageCode == 'de') {
        switch (gender) {
          case GrammaticalGender.masculine:
            color = AppColors.articleDer;
            labelParts.add('Masculine');
            break;
          case GrammaticalGender.feminine:
            color = AppColors.articleDie;
            labelParts.add('Feminine');
            break;
          case GrammaticalGender.neuter:
            color = AppColors.articleDas;
            labelParts.add('Neuter');
            break;
          case GrammaticalGender.common:
            color = AppColors.articleOther;
            labelParts.add('Common');
            break;
          case GrammaticalGender.none:
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
            color = AppColors.articleOther;
            labelParts.add('Common');
            break;
          case GrammaticalGender.none:
            break;
        }
      }
    }

    // Noun Class
    if (profile.hasNounClasses) {
      final nounClass = ruleProvider.determineNounClass(word);
      if (nounClass != null && nounClass.isNotEmpty) {
        labelParts.add('Class $nounClass');
        color ??= AppColors.primary; // Assign fallback color if no gender color
      }
    }

    // Category
    final category = ruleProvider.determineCategory(word, article: article);
    if (category != GrammaticalCategory.unknown) {
      labelParts.add(category.name);
    }

    // Number
    if (profile.hasNumber) {
      final number = ruleProvider.determineNumber(word);
      if (number != null && number != GrammaticalNumber.unknown && number != GrammaticalNumber.none) {
        labelParts.add(number.name);
      }
    }

    // Case
    if (profile.hasCases) {
      final gramCase = ruleProvider.determineCase(word);
      if (gramCase != null && gramCase != GrammaticalCase.unknown && gramCase != GrammaticalCase.none) {
        labelParts.add(gramCase.name);
      }
    }

    // Person
    if (profile.hasPerson) {
      final person = ruleProvider.determinePerson(word);
      if (person != null && person != GrammaticalPerson.unknown && person != GrammaticalPerson.none) {
        labelParts.add(person.name);
      }
    }

    // Tense
    if (profile.hasTense) {
      final tense = ruleProvider.determineTense(word);
      if (tense != null && tense != Tense.unknown && tense != Tense.none) {
        labelParts.add(tense.name);
      }
    }

    // Aspect
    if (profile.hasAspect) {
      final aspect = ruleProvider.determineAspect(word);
      if (aspect != null && aspect != Aspect.unknown && aspect != Aspect.none) {
        labelParts.add(aspect.name);
      }
    }

    // Mood
    if (profile.hasMood) {
      final mood = ruleProvider.determineMood(word);
      if (mood != null && mood != Mood.unknown && mood != Mood.none) {
        labelParts.add(mood.name);
      }
    }

    final label = labelParts.isEmpty ? word : labelParts.join(' ');

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
          style: metadata.color != null
              ? (baseStyle ?? AppTypography.body).copyWith(color: metadata.color)
              : (baseStyle ?? AppTypography.body),
        ),
      ),
    );
  }
}
