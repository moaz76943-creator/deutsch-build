import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

class SemanticPresentationMetadata {
  final Color color;
  final String label;
  final bool isAttested;
  const SemanticPresentationMetadata({
    required this.color, required this.label, required this.isAttested,
  });
}

/// Presentation only. This optional callback must be backed by an admitted
/// corpus; the engine never asserts linguistic evidence by guessing articles.
class SemanticPresentationEngine {
  final LanguageGrammarRuleProvider ruleProvider;
  final String packVersion;
  final bool Function(String word, String? article)? isAdmittedEvidence;
  final int maxCacheEntries;

  final LinkedHashMap<(String, String?, String, String),
      SemanticPresentationMetadata> _cache = LinkedHashMap();

  SemanticPresentationEngine({
    required this.ruleProvider,
    required this.packVersion,
    this.isAdmittedEvidence,
    this.maxCacheEntries = 256,
  }) {
    if (packVersion.isEmpty || maxCacheEntries < 1) {
      throw ArgumentError('Pack revision and positive cache bounds required');
    }
  }

  SemanticPresentationMetadata getPresentationForWord(
    String word, {
    String? article,
  }) {
    const unknown = SemanticPresentationMetadata(
      color: AppColors.articleOther,
      label: 'Grammar not verified',
      isAttested: false,
    );
    // Long user-generated strings never become persistent cache keys.
    if (word.length > 512 || (article?.length ?? 0) > 128) {
      return unknown;
    }

    final key = (word, article, ruleProvider.languageCode, packVersion);
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }

    var attested = false;
    GrammaticalGender gender = GrammaticalGender.none;
    GrammaticalCategory category = GrammaticalCategory.unknown;
    try {
      attested = isAdmittedEvidence?.call(word, article) == true;
      if (attested) {
        gender = ruleProvider.determineGender(word, article: article);
        category = ruleProvider.determineCategory(word, article: article);
      }
    } catch (_) {
      // An incomplete/corrupt local pack must not crash rendering.
      attested = false;
    }

    Color color = AppColors.articleOther;
    String label = 'Grammar not verified';
    if (attested) {
      final suffix = category == GrammaticalCategory.unknown
          ? '' : ' (${category.name})';
      switch (gender) {
        case GrammaticalGender.masculine:
          color = ruleProvider.languageCode == 'de'
              ? AppColors.articleDer : AppColors.primary;
          label = 'Masculine$suffix';
          break;
        case GrammaticalGender.feminine:
          color = ruleProvider.languageCode == 'de'
              ? AppColors.articleDie : AppColors.secondary;
          label = 'Feminine$suffix';
          break;
        case GrammaticalGender.neuter:
          color = ruleProvider.languageCode == 'de'
              ? AppColors.articleDas : AppColors.tertiary;
          label = 'Neuter$suffix';
          break;
        case GrammaticalGender.common:
          label = 'Common gender$suffix';
          break;
        case GrammaticalGender.none:
          label = category == GrammaticalCategory.unknown
              ? 'Grammar unknown' : category.name;
          break;
      }
    }
    final result = SemanticPresentationMetadata(
      color: color, label: label, isAttested: attested,
    );
    _cache[key] = result;
    if (_cache.length > maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    return result;
  }

  void clear() => _cache.clear();
  int get cacheSize => _cache.length;
}

class SemanticWordText extends StatelessWidget {
  final String word;
  final String? article;
  final SemanticPresentationEngine engine;
  final TextStyle? baseStyle;
  final TextDirection? textDirection;

  const SemanticWordText({
    super.key,
    required this.word,
    required this.engine,
    this.article,
    this.baseStyle,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = engine.getPresentationForWord(
      word, article: article,
    );
    final direction = textDirection ?? Directionality.of(context);
    return Semantics(
      label: '$word, ${presentation.label}',
      child: ExcludeSemantics(
        child: Text(
          word,
          textDirection: direction,
          style: (baseStyle ?? AppTypography.body)
              .copyWith(color: presentation.color),
        ),
      ),
    );
  }
}
