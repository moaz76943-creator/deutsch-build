import 'package:deutsch_bilarabi/features/daily_drill/data/srs_daily_drill_repository.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = SrsDailyDrillRepository();

  const table = ContentItem(
    id: 'noun.tisch',
    german: 'Tisch',
    arabic: 'طاولة',
    sentence: 'Der Tisch ist groß.',
    sentenceAr: 'الطاولة كبيرة.',
    topic: 'home',
    skill: 'vocabulary',
    article: 'der',
  );
  const bag = ContentItem(
    id: 'noun.tasche',
    german: 'Tasche',
    arabic: 'حقيبة',
    sentence: 'Die Tasche ist neu.',
    sentenceAr: 'الحقيبة جديدة.',
    topic: 'daily',
    skill: 'vocabulary',
    article: 'die',
  );
  const book = ContentItem(
    id: 'noun.buch',
    german: 'Buch',
    arabic: 'كتاب',
    sentence: 'Das Buch ist interessant.',
    sentenceAr: 'الكتاب ممتع.',
    topic: 'study',
    skill: 'vocabulary',
    article: 'das',
  );

  test('returns only due canonical meaning-review cards', () {
    final now = DateTime.utc(2026, 10, 3, 17);
    final state = LearnerState(
      updatedAt: now,
      reviewCards: <String, ReviewCard>{
        table.id: ReviewCard(
          itemId: table.id,
          dueAt: now.subtract(const Duration(days: 2)),
          lapses: 2,
          failures: 3,
        ),
        bag.id: ReviewCard(
          itemId: bag.id,
          dueAt: now.subtract(const Duration(hours: 1)),
        ),
        book.id: ReviewCard(
          itemId: book.id,
          dueAt: now.add(const Duration(hours: 4)),
        ),
      },
    );

    final due = repository.dueReviews(
      state: state,
      corpus: const <ContentItem>[table, bag, book],
      now: now,
      limit: 10,
    );

    expect(due.map((entry) => entry.item.id), <String>[table.id, bag.id]);
    expect(due.every((entry) => !entry.dueAt.isAfter(now)), isTrue);
  });

  test('uses the canonical memory priority and respects session limit', () {
    final now = DateTime.utc(2026, 10, 3, 17);
    final state = LearnerState(
      updatedAt: now,
      reviewCards: <String, ReviewCard>{
        table.id: ReviewCard(
          itemId: table.id,
          dueAt: now.subtract(const Duration(minutes: 5)),
        ),
        bag.id: ReviewCard(
          itemId: bag.id,
          dueAt: now.subtract(const Duration(days: 1)),
          lapses: 3,
          failures: 4,
        ),
      },
    );

    final due = repository.dueReviews(
      state: state,
      corpus: const <ContentItem>[table, bag],
      now: now,
      limit: 1,
    );

    expect(due, hasLength(1));
    expect(due.single.item.id, bag.id);
    expect(due.single.reviewReason.name, isNotEmpty);
  });

  test('skips stale SRS ids that are absent from the active corpus', () {
    final now = DateTime.utc(2026, 10, 3, 17);
    final state = LearnerState(
      updatedAt: now,
      reviewCards: <String, ReviewCard>{
        'missing.item': ReviewCard(
          itemId: 'missing.item',
          dueAt: now.subtract(const Duration(days: 1)),
        ),
      },
    );

    final due = repository.dueReviews(
      state: state,
      corpus: const <ContentItem>[table],
      now: now,
      limit: 10,
    );

    expect(due, isEmpty);
  });
}
