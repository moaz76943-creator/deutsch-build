import '../../models/learner.dart';
import '../memory.dart';

final class QuickReviewCorpusItem {
  const QuickReviewCorpusItem({
    required this.id,
    required this.sourceText,
    required this.translationText,
    required this.exampleText,
    required this.exampleTranslationText,
    required this.grammaticalMarker,
    required this.pluralForm,
  });

  final String id;
  final String sourceText;
  final String translationText;
  final String exampleText;
  final String exampleTranslationText;
  final String grammaticalMarker;
  final String pluralForm;
}

final class QuickReviewCard {
  const QuickReviewCard({
    required this.contentId,
    required this.sourceText,
    required this.translationText,
    required this.exampleText,
    required this.exampleTranslationText,
    required this.grammaticalMarker,
    required this.pluralForm,
    required this.dueAt,
    required this.memoryState,
    required this.reason,
    required this.intervalDays,
    required this.lapses,
  });

  final String contentId;
  final String sourceText;
  final String translationText;
  final String exampleText;
  final String exampleTranslationText;
  final String grammaticalMarker;
  final String pluralForm;
  final DateTime dueAt;
  final MemoryState memoryState;
  final MemoryReviewReason reason;
  final int intervalDays;
  final int lapses;
}

final class QuickReviewSession {
  QuickReviewSession({
    required DateTime createdAt,
    required this.limit,
    required Iterable<QuickReviewCard> cards,
  })  : createdAt = createdAt.toUtc(),
        cards = List<QuickReviewCard>.unmodifiable(cards);

  final DateTime createdAt;
  final int limit;
  final List<QuickReviewCard> cards;

  bool get isEmpty => cards.isEmpty;
  int get length => cards.length;
}
