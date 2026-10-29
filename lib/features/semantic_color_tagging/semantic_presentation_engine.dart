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

  void clearCache() {
    _cache.clear();
  }

  SemanticPresentationMetadata getPresentationForWord(String word, {String? article}) {
    // We omit packVersion and languageCode from key since this engine instance is bound to them
    final cacheKey = '${word}_${article ?? ""}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final profile = ruleProvider.capabilityProfile;

    Color? color;
    final List<String> labels = [];

    // Gender
    if (profile.hasGender) {
      final gender = ruleProvider.determineGender(word, article: article);
      if (gender != GrammaticalGender.none) {
        if (ruleProvider.languageCode == 'de') {
          switch (gender) {
            case GrammaticalGender.masculine:
              color = AppColors.articleDer;
              labels.add('Masculine (der)');
              break;
            case GrammaticalGender.feminine:
              color = AppColors.articleDie;
              labels.add('Feminine (die)');
              break;
            case GrammaticalGender.neuter:
              color = AppColors.articleDas;
              labels.add('Neuter (das)');
              break;
            case GrammaticalGender.common:
              color = AppColors.articleOther;
              labels.add('Common');
              break;
            case GrammaticalGender.none:
              break;
          }
        } else {
          switch (gender) {
            case GrammaticalGender.masculine:
              color = AppColors.primary;
              labels.add('Masculine');
              break;
            case GrammaticalGender.feminine:
              color = AppColors.secondary;
              labels.add('Feminine');
              break;
            case GrammaticalGender.neuter:
              color = AppColors.tertiary;
              labels.add('Neuter');
              break;
            case GrammaticalGender.common:
              color = AppColors.articleOther;
              labels.add('Common');
              break;
            case GrammaticalGender.none:
              break;
          }
        }
      }
    }

    // Noun classes
    if (profile.hasNounClasses) {
      final nounClass = ruleProvider.determineNounClass(word);
      if (nounClass != null) {
         labels.add('Class $nounClass');
         color ??= AppColors.primaryDark; // fallback color for classes if no gender color
      }
    }

    // Category
    final category = ruleProvider.determineCategory(word, article: article);
    if (category != GrammaticalCategory.unknown) {
       labels.add(category.name);
    }

    // Case
    if (profile.hasCases) {
      final gCase = ruleProvider.determineCase(word);
      if (gCase != null && gCase != GrammaticalCase.unknown && gCase != GrammaticalCase.none) {
        labels.add(gCase.name);
      }
    }

    // Number
    if (profile.hasNumber) {
      final number = ruleProvider.determineNumber(word);
      if (number != null && number != GrammaticalNumber.unknown && number != GrammaticalNumber.none) {
        labels.add(number.name);
      }
    }

    // Person
    if (profile.hasPerson) {
      final person = ruleProvider.determinePerson(word);
      if (person != null && person != GrammaticalPerson.unknown && person != GrammaticalPerson.none) {
        labels.add(person.name);
      }
    }

    // Tense
    if (profile.hasTense) {
      final tense = ruleProvider.determineTense(word);
      if (tense != null && tense != Tense.unknown && tense != Tense.none) {
        labels.add(tense.name);
      }
    }

    // Aspect
    if (profile.hasAspect) {
      final aspect = ruleProvider.determineAspect(word);
      if (aspect != null && aspect != Aspect.unknown && aspect != Aspect.none) {
        labels.add(aspect.name);
      }
    }

    // Mood
    if (profile.hasMood) {
      final mood = ruleProvider.determineMood(word);
      if (mood != null && mood != Mood.unknown && mood != Mood.none) {
        labels.add(mood.name);
      }
    }

    final label = labels.isEmpty ? word : labels.join(' ');

    final metadata = SemanticPresentationMetadata(color: color, label: label);
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
