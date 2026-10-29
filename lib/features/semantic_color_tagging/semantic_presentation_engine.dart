import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

class SemanticPresentationMetadata {
  final Color? color;
  final Color? darkColor;
  final String label;

  const SemanticPresentationMetadata({
    this.color,
    this.darkColor,
    required this.label,
  });
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
    final cacheKey = '${packVersion}_${word}_${article ?? ""}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final gender = ruleProvider.determineGender(word, article: article);
    final category = ruleProvider.determineCategory(word, article: article);

    Color? color;
    Color? darkColor;

    List<String> labelParts = [];

    // Base colors
    if (ruleProvider.languageCode == 'de') {
      switch (gender) {
        case GrammaticalGender.masculine:
          color = AppColors.articleDer;
          darkColor = AppColors.articleDer;
          labelParts.add('Masculine (der)');
          break;
        case GrammaticalGender.feminine:
          color = AppColors.articleDie;
          darkColor = AppColors.articleDie;
          labelParts.add('Feminine (die)');
          break;
        case GrammaticalGender.neuter:
          color = AppColors.articleDas;
          darkColor = AppColors.articleDas;
          labelParts.add('Neuter (das)');
          break;
        case GrammaticalGender.common:
        case GrammaticalGender.none:
          if (category != GrammaticalCategory.unknown) {
            color = AppColors.articleOther;
            darkColor = AppColors.articleOther;
          }
          break;
      }
    } else {
      switch (gender) {
        case GrammaticalGender.masculine:
          color = AppColors.primary;
          darkColor = AppColors.primaryDark;
          labelParts.add('Masculine');
          break;
        case GrammaticalGender.feminine:
          color = AppColors.secondary;
          darkColor = AppColors.secondaryDark;
          labelParts.add('Feminine');
          break;
        case GrammaticalGender.neuter:
          color = AppColors.tertiary;
          darkColor = AppColors.tertiaryDark;
          labelParts.add('Neuter');
          break;
        case GrammaticalGender.common:
        case GrammaticalGender.none:
          if (category != GrammaticalCategory.unknown) {
            color = AppColors.articleOther;
            darkColor = AppColors.articleOther; // Using articleOther for both since no other mapping exists
          }
          break;
      }
    }

    if (category != GrammaticalCategory.unknown) {
      labelParts.add(category.name);
    }

    final profile = ruleProvider.capabilityProfile;

    if (profile.hasNounClasses) {
      final nounClass = ruleProvider.determineNounClass(word);
      if (nounClass != null && nounClass.isNotEmpty) {
        labelParts.add('Class $nounClass');
      }
    }

    if (profile.hasCases) {
      final grammaticalCase = ruleProvider.determineCase(word);
      if (grammaticalCase != null && grammaticalCase != GrammaticalCase.unknown && grammaticalCase != GrammaticalCase.none) {
        labelParts.add(grammaticalCase.name);
      }
    }

    if (profile.hasNumber) {
      final number = ruleProvider.determineNumber(word);
      if (number != null && number != GrammaticalNumber.unknown && number != GrammaticalNumber.none) {
        labelParts.add(number.name);
      }
    }

    if (profile.hasPerson) {
      final person = ruleProvider.determinePerson(word);
      if (person != null && person != GrammaticalPerson.unknown && person != GrammaticalPerson.none) {
        labelParts.add('${person.name} person');
      }
    }

    if (profile.hasTense) {
      final tense = ruleProvider.determineTense(word);
      if (tense != null && tense != Tense.unknown && tense != Tense.none) {
        labelParts.add(tense.name);
      }
    }

    if (profile.hasAspect) {
      final aspect = ruleProvider.determineAspect(word);
      if (aspect != null && aspect != Aspect.unknown && aspect != Aspect.none) {
        labelParts.add(aspect.name);
      }
    }

    if (profile.hasMood) {
      final mood = ruleProvider.determineMood(word);
      if (mood != null && mood != Mood.unknown && mood != Mood.none) {
        labelParts.add(mood.name);
      }
    }

    final metadata = SemanticPresentationMetadata(
      color: color,
      darkColor: darkColor,
      label: labelParts.join(' ').trim(),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? metadata.darkColor : metadata.color;

    Widget textWidget = Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: Text(
        word,
        style: (baseStyle ?? AppTypography.body).copyWith(color: activeColor),
      ),
    );

    if (metadata.label.isNotEmpty) {
      return Semantics(
        label: metadata.label,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
