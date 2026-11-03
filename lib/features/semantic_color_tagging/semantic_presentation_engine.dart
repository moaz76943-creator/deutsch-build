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
    final cacheKey = '${packVersion}_${word}_${article ?? ""}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final profile = ruleProvider.capabilityProfile;
    final List<String> labels = [];
    Color? color;

    bool hasAnyGrammarData = false;

    // Noun classes
    if (profile.hasNounClasses) {
      final nounClass = ruleProvider.determineNounClass(word);
      if (nounClass != null && nounClass.isNotEmpty) {
        labels.add('Class $nounClass');
        hasAnyGrammarData = true;
        color = AppColors.tertiary; // Give noun classes a specific color
      }
    }

    // Gender
    if (profile.hasGender) {
      final gender = ruleProvider.determineGender(word, article: article);
      if (gender != GrammaticalGender.none) {
        hasAnyGrammarData = true;
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
            default:
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
            default:
              break;
          }
        }
      }
    }

    // Category
    final category = ruleProvider.determineCategory(word, article: article);
    if (category != GrammaticalCategory.unknown) {
      hasAnyGrammarData = true;
      labels.add(category.name);
    }

    // Case
    if (profile.hasCases) {
      final gCase = ruleProvider.determineCase(word);
      if (gCase != null && gCase != GrammaticalCase.none && gCase != GrammaticalCase.unknown) {
        hasAnyGrammarData = true;
        labels.add(gCase.name);
      }
    }

    // Number
    if (profile.hasNumber) {
      final number = ruleProvider.determineNumber(word);
      if (number != null && number != GrammaticalNumber.none && number != GrammaticalNumber.unknown) {
        hasAnyGrammarData = true;
        labels.add(number.name);
      }
    }

    // Person
    if (profile.hasPerson) {
      final person = ruleProvider.determinePerson(word);
      if (person != null && person != GrammaticalPerson.none && person != GrammaticalPerson.unknown) {
        hasAnyGrammarData = true;
        labels.add(person.name);
      }
    }

    // Tense
    if (profile.hasTense) {
      final tense = ruleProvider.determineTense(word);
      if (tense != null && tense != Tense.none && tense != Tense.unknown) {
        hasAnyGrammarData = true;
        labels.add(tense.name);
      }
    }

    // Aspect
    if (profile.hasAspect) {
      final aspect = ruleProvider.determineAspect(word);
      if (aspect != null && aspect != Aspect.none && aspect != Aspect.unknown) {
        hasAnyGrammarData = true;
        labels.add(aspect.name);
      }
    }

    // Mood
    if (profile.hasMood) {
      final mood = ruleProvider.determineMood(word);
      if (mood != null && mood != Mood.none && mood != Mood.unknown) {
        hasAnyGrammarData = true;
        labels.add(mood.name);
      }
    }

    String finalLabel = labels.join(' ').trim();

    // Fallback logic
    if (!hasAnyGrammarData) {
      color = null; // Use uncolored text when no grammar info
    } else {
      color ??= AppColors.articleOther;
    }

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
      label: metadata.label.isNotEmpty ? metadata.label : word,
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Text(
          word,
          style: metadata.color != null
              ? (baseStyle ?? AppTypography.body).copyWith(color: metadata.color)
              : baseStyle ?? AppTypography.body,
        ),
      ),
    );
  }
}
