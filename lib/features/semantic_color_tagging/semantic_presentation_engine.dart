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
    // Cache key now includes language code and pack version to fulfill "Recompute presentation when the admitted pack version changes"
    // Also "Cache only small, version-qualified presentation metadata."
    final cacheKey = '${ruleProvider.languageCode}_${packVersion}_${word}_${article ?? ""}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final capabilityProfile = ruleProvider.capabilityProfile;

    // Use capabilities
    final gender = capabilityProfile.hasGender ? ruleProvider.determineGender(word, article: article) : null;
    final category = ruleProvider.determineCategory(word, article: article);

    Color? color;
    List<String> labelParts = [];

    // 1. Gender & Noun Class Color & Label
    if (capabilityProfile.hasGender && gender != null) {
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
    } else if (capabilityProfile.hasNounClasses) {
      final nounClass = ruleProvider.determineNounClass(word);
      if (nounClass != null) {
          color = AppColors.articleOther;
          labelParts.add('Noun Class $nounClass');
      }
    }

    // 2. Category
    if (category != GrammaticalCategory.unknown) {
        labelParts.add(category.name);
    }

    // 3. Other capabilities: Case, Aspect, Number, Agreement(Person, etc)
    if (capabilityProfile.hasCases) {
       final gCase = ruleProvider.determineCase(word);
       if (gCase != null && gCase != GrammaticalCase.unknown && gCase != GrammaticalCase.none) {
           labelParts.add(gCase.name);
       }
    }

    if (capabilityProfile.hasAspect) {
        final aspect = ruleProvider.determineAspect(word);
        if (aspect != null && aspect != Aspect.unknown && aspect != Aspect.none) {
            labelParts.add(aspect.name);
        }
    }

    if (capabilityProfile.hasNumber) {
        final number = ruleProvider.determineNumber(word);
        if (number != null && number != GrammaticalNumber.unknown && number != GrammaticalNumber.none) {
            labelParts.add(number.name);
        }
    }

    if (capabilityProfile.hasPerson) {
        final person = ruleProvider.determinePerson(word);
        if (person != null && person != GrammaticalPerson.unknown && person != GrammaticalPerson.none) {
            labelParts.add(person.name);
        }
    }

    if (capabilityProfile.hasTense) {
        final tense = ruleProvider.determineTense(word);
        if (tense != null && tense != Tense.unknown && tense != Tense.none) {
            labelParts.add(tense.name);
        }
    }

    if (capabilityProfile.hasMood) {
        final mood = ruleProvider.determineMood(word);
        if (mood != null && mood != Mood.unknown && mood != Mood.none) {
            labelParts.add(mood.name);
        }
    }

    // Join label parts safely
    String label = labelParts.join(' ').trim();

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

    Color colorToUse = metadata.color ?? baseStyle?.color ?? AppTypography.body.color ?? Colors.black;
    TextStyle styleToUse = (baseStyle ?? AppTypography.body).copyWith(color: colorToUse);

    // If metadata.label is empty, we still provide a Semantics node, but without a label
    // it's not very useful, but we follow standard practice.
    Widget textWidget = Directionality(
        textDirection: Directionality.of(context),
        child: Text(
          word,
          style: styleToUse,
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
