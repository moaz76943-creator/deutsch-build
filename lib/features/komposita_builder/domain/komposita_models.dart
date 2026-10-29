import '../../../core/localization/german_article_style.dart';

enum LinkingElement { none, s, es, n, en, er }

extension LinkingElementSurface on LinkingElement {
  String get surface => switch (this) {
        LinkingElement.none => '',
        LinkingElement.s => 's',
        LinkingElement.es => 'es',
        LinkingElement.n => 'n',
        LinkingElement.en => 'en',
        LinkingElement.er => 'er',
      };
}

final class CompoundWordPart {
  const CompoundWordPart({
    required this.word,
    required this.arabicMeaning,
    required this.originalArticle,
  })  : assert(word.length > 0),
        assert(arabicMeaning.length > 0);

  final String word;
  final String arabicMeaning;
  final GermanArticle originalArticle;
}

final class KompositaChallengeItem {
  KompositaChallengeItem({
    required this.id,
    required this.compoundWord,
    required List<CompoundWordPart> parts,
    required this.linkingElement,
    required this.finalArticle,
    required this.articleRuleAr,
    required this.overallMeaningAr,
    required this.derivationExplanationAr,
    required this.level,
  }) : parts = List<CompoundWordPart>.unmodifiable(parts) {
    if (id.trim().isEmpty || id.length > 160) {
      throw ArgumentError.value(id, 'id', 'invalid challenge id');
    }
    if (compoundWord.trim().isEmpty || compoundWord.length > 120) {
      throw ArgumentError.value(
        compoundWord,
        'compoundWord',
        'invalid compound word',
      );
    }
    if (this.parts.length < 2) {
      throw ArgumentError('a compound challenge requires at least two parts');
    }
    if (this.parts.last.originalArticle != finalArticle) {
      throw ArgumentError(
        'finalArticle must match the article of the final compound part',
      );
    }
    if (!const <String>{'A1', 'A2', 'B1'}.contains(level)) {
      throw ArgumentError.value(level, 'level', 'must be A1, A2 or B1');
    }
  }

  static const String canonicalArticleRuleAr =
      'الأداة تحددها الكلمة الأخيرة دائماً.';

  final String id;
  final String compoundWord;
  final List<CompoundWordPart> parts;
  final LinkingElement linkingElement;
  final GermanArticle finalArticle;
  final String articleRuleAr;
  final String overallMeaningAr;
  final String derivationExplanationAr;
  final String level;

  String get displayWithArticle =>
      '${finalArticle.name} ${compoundWord.trim()}';

  List<String> get orderedPartWords => List<String>.unmodifiable(
        parts.map((part) => part.word),
      );
}
