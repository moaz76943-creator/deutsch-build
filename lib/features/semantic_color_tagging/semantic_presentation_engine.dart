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

  SemanticPresentationMetadata getPresentationForWord(String word, {String? article, String? context}) {
    final cacheKey = '${ruleProvider.languageCode}_${packVersion}_${word}_${article ?? ""}_${context ?? ""}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final profile = ruleProvider.capabilityProfile;

    final category = ruleProvider.determineCategory(word, article: article);

    GrammaticalGender? gender;
    if (profile.hasGender) {
      gender = ruleProvider.determineGender(word, article: article);
    }

    GrammaticalNumber? number;
    if (profile.hasNumber) {
      number = ruleProvider.determineNumber(word);
    }

    GrammaticalCase? gCase;
    if (profile.hasCases) {
      gCase = ruleProvider.determineCase(word, context: context);
    }

    Tense? tense;
    if (profile.hasTense) {
      tense = ruleProvider.determineTense(word);
    }

    Aspect? aspect;
    if (profile.hasAspect) {
      aspect = ruleProvider.determineAspect(word);
    }

    Mood? mood;
    if (profile.hasMood) {
      mood = ruleProvider.determineMood(word);
    }

    GrammaticalPerson? person;
    if (profile.hasPerson) {
      person = ruleProvider.determinePerson(word);
    }

    String? nounClass;
    if (profile.hasNounClasses) {
      nounClass = ruleProvider.determineNounClass(word);
    }

    Color? color;

    // Determine Color based on gender
    if (gender != null && gender != GrammaticalGender.none) {
      if (ruleProvider.languageCode == 'de') {
        switch (gender) {
          case GrammaticalGender.masculine:
            color = AppColors.articleDer;
            break;
          case GrammaticalGender.feminine:
            color = AppColors.articleDie;
            break;
          case GrammaticalGender.neuter:
            color = AppColors.articleDas;
            break;
          case GrammaticalGender.common:
            color = AppColors.articleOther;
            break;
          case GrammaticalGender.none:
            break;
        }
      } else {
        switch (gender) {
          case GrammaticalGender.masculine:
            color = AppColors.primary;
            break;
          case GrammaticalGender.feminine:
            color = AppColors.secondary;
            break;
          case GrammaticalGender.neuter:
            color = AppColors.tertiary;
            break;
          case GrammaticalGender.common:
            color = AppColors.articleOther;
            break;
          case GrammaticalGender.none:
            break;
        }
      }
    }

    // Build the label
    final parts = <String>[];

    if (gender != null && gender != GrammaticalGender.none) {
      String genderLabel = gender.name;
      // Capitalize first letter
      genderLabel = genderLabel[0].toUpperCase() + genderLabel.substring(1);

      if (ruleProvider.languageCode == 'de') {
        if (gender == GrammaticalGender.masculine) genderLabel += ' (der)';
        if (gender == GrammaticalGender.feminine) genderLabel += ' (die)';
        if (gender == GrammaticalGender.neuter) genderLabel += ' (das)';
      }
      parts.add(genderLabel);
    }

    if (nounClass != null && nounClass.isNotEmpty) {
      parts.add('Class $nounClass');
    }

    if (category != GrammaticalCategory.unknown) {
      parts.add(category.name);
    }

    if (number != null && number != GrammaticalNumber.unknown && number != GrammaticalNumber.none) {
      parts.add(number.name);
    }

    if (gCase != null && gCase != GrammaticalCase.unknown && gCase != GrammaticalCase.none) {
      parts.add(gCase.name);
    }

    if (person != null && person != GrammaticalPerson.unknown && person != GrammaticalPerson.none) {
      parts.add(person.name);
    }

    if (tense != null && tense != Tense.unknown && tense != Tense.none) {
      parts.add(tense.name);
    }

    if (aspect != null && aspect != Aspect.unknown && aspect != Aspect.none) {
      parts.add(aspect.name);
    }

    if (mood != null && mood != Mood.unknown && mood != Mood.none) {
      parts.add(mood.name);
    }

    final label = parts.join(' ').trim();

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
          style: metadata.color != null ? (baseStyle ?? AppTypography.body).copyWith(color: metadata.color) : (baseStyle ?? AppTypography.body),
        ),
      ),
    );
  }
}
