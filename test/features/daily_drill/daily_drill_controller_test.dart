import 'package:deutsch_bilarabi/core/content_contract.dart';
import 'package:deutsch_bilarabi/core/memory.dart';
import 'package:deutsch_bilarabi/features/daily_drill/application/daily_drill_controller.dart';
import 'package:deutsch_bilarabi/features/daily_drill/domain/daily_drill_models.dart';
import 'package:deutsch_bilarabi/features/daily_drill/domain/daily_drill_repository.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements DailyDrillRepository {
  _FakeRepository(this.items);

  final List<FlashcardReviewItem> items;

  @override
  List<FlashcardReviewItem> dueReviews({
    required LearnerState state,
    required Iterable<LearningContent> corpus,
    required DateTime now,
    int limit = 10,
  }) =>
      items.take(limit).toList(growable: false);
}

final class _FakeSink implements DailyDrillReviewSink {
  final List<bool> answers = <bool>[];

  @override
  Future<DailyDrillReviewReceipt> record({
    required LearningContent item,
    required bool correct,
    required int seconds,
  }) async {
    answers.add(correct);
    return DailyDrillReviewReceipt(
      currentStreak: 4 + answers.length,
      sessionXp: answers.length * 6,
    );
  }
}

void main() {
  const first = ContentItem(
    id: 'noun.tisch',
    german: 'Tisch',
    arabic: 'طاولة',
    sentence: 'Der Tisch steht im Zimmer.',
    sentenceAr: 'الطاولة موجودة في الغرفة.',
    topic: 'home',
    skill: 'vocabulary',
    article: 'der',
  );
  const second = ContentItem(
    id: 'noun.buch',
    german: 'Buch',
    arabic: 'كتاب',
    sentence: 'Das Buch liegt hier.',
    sentenceAr: 'الكتاب موجود هنا.',
    topic: 'study',
    skill: 'vocabulary',
    article: 'das',
  );

  FlashcardReviewItem card(ContentItem item) => FlashcardReviewItem(
        item: item,
        dueAt: DateTime.utc(2026, 10, 3, 8),
        memoryState: MemoryState.learning,
        successRate: .5,
        reviewReason: MemoryReviewReason.due,
      );

  test('starts a bounded quick session and requires reveal before grading', () {
    final sink = _FakeSink();
    final controller = DailyDrillController(
      repository: _FakeRepository(<FlashcardReviewItem>[
        card(first),
        card(second),
      ]),
      reviewSink: sink,
    );
    final now = DateTime.utc(2026, 10, 3, 17);

    controller.start(
      learnerState: LearnerState(updatedAt: now),
      corpus: const <LearningContent>[first, second],
      now: now,
    );

    expect(controller.state.status, DailyDrillStatus.active);
    expect(controller.state.session?.items, hasLength(2));
    expect(controller.state.currentItem?.item.id, first.id);
    expect(controller.state.revealed, isFalse);
    expect(
      () => controller.gradeCurrent(
        correct: true,
        elapsed: const Duration(seconds: 2),
      ),
      throwsStateError,
    );
  });

  test('records each card once, advances, and computes completion metrics', () async {
    final sink = _FakeSink();
    final controller = DailyDrillController(
      repository: _FakeRepository(<FlashcardReviewItem>[
        card(first),
        card(second),
      ]),
      reviewSink: sink,
    );
    final now = DateTime.utc(2026, 10, 3, 17);
    controller.start(
      learnerState: LearnerState(updatedAt: now),
      corpus: const <LearningContent>[first, second],
      now: now,
    );

    controller.reveal();
    await controller.gradeCurrent(
      correct: true,
      elapsed: const Duration(seconds: 2),
    );

    expect(controller.state.currentIndex, 1);
    expect(controller.state.correctCount, 1);
    expect(controller.state.revealed, isFalse);

    controller.reveal();
    await controller.gradeCurrent(
      correct: false,
      elapsed: const Duration(seconds: 4),
    );

    expect(sink.answers, <bool>[true, false]);
    expect(controller.state.status, DailyDrillStatus.completed);
    expect(controller.state.summary?.reviewedCards, 2);
    expect(controller.state.summary?.correctCards, 1);
    expect(controller.state.summary?.accuracy, .5);
    expect(controller.state.summary?.averageSecondsPerCard, 3);
    expect(controller.state.summary?.currentStreak, 6);
    expect(controller.state.summary?.sessionXp, 12);
  });

  test('empty due queue completes without manufacturing new cards', () {
    final controller = DailyDrillController(
      repository: _FakeRepository(const <FlashcardReviewItem>[]),
      reviewSink: _FakeSink(),
    );
    final now = DateTime.utc(2026, 10, 3, 17);

    controller.start(
      learnerState: LearnerState(updatedAt: now),
      corpus: const <LearningContent>[first],
      now: now,
    );

    expect(controller.state.status, DailyDrillStatus.completed);
    expect(controller.state.summary?.reviewedCards, 0);
    expect(controller.state.currentItem, isNull);
  });
}
