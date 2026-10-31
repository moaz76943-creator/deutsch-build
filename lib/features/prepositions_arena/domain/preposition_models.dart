import '../../../core/localization/german_article_style.dart';

enum PrepositionType { accusative, dative, twoWay }

enum GermanGrammaticalCase { accusative, dative }

enum SpatialQuestion { none, wohin, wo }

enum PrepositionChallengeKind { prepositionChoice, articleChoice }

final class PrepositionItem {
  const PrepositionItem({
    required this.id,
    required this.preposition,
    required this.type,
    required this.meaningAr,
    required this.level,
  });

  final String id;
  final String preposition;
  final PrepositionType type;
  final String meaningAr;
  final String level;
}

final class GermanArticleCaseForm {
  const GermanArticleCaseForm({
    required this.baseArticle,
    required this.grammaticalCase,
    required this.surfaceArticle,
  });

  final GermanArticle baseArticle;
  final GermanGrammaticalCase grammaticalCase;
  final String surfaceArticle;
}

final class PrepositionChallenge {
  PrepositionChallenge({
    required this.id,
    required this.kind,
    required this.sentenceTemplate,
    required this.translationAr,
    required this.prepositionId,
    required List<String> options,
    required this.explanationAr,
    required this.level,
    this.correctPreposition,
    this.baseArticle,
    this.spatialQuestion = SpatialQuestion.none,
  }) : options = List<String>.unmodifiable(options) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (!sentenceTemplate.contains('___')) {
      throw ArgumentError('sentenceTemplate must contain ___');
    }
    if (this.options.length < 2) {
      throw ArgumentError('challenge requires at least two options');
    }
    if (kind == PrepositionChallengeKind.prepositionChoice &&
        (correctPreposition == null || correctPreposition!.trim().isEmpty)) {
      throw ArgumentError('preposition challenge requires correctPreposition');
    }
    if (kind == PrepositionChallengeKind.articleChoice &&
        baseArticle == null) {
      throw ArgumentError('article challenge requires baseArticle');
    }
  }

  final String id;
  final PrepositionChallengeKind kind;
  final String sentenceTemplate;
  final String translationAr;
  final String prepositionId;
  final String? correctPreposition;
  final GermanArticle? baseArticle;
  final SpatialQuestion spatialQuestion;
  final List<String> options;
  final String explanationAr;
  final String level;
}

final class PrepositionAnswerResult {
  const PrepositionAnswerResult({
    required this.isCorrect,
    required this.selectedAnswer,
    required this.expectedAnswer,
    required this.explanationAr,
    this.grammaticalCase,
    this.articleForm,
  });

  final bool isCorrect;
  final String selectedAnswer;
  final String expectedAnswer;
  final String explanationAr;
  final GermanGrammaticalCase? grammaticalCase;
  final GermanArticleCaseForm? articleForm;
}
