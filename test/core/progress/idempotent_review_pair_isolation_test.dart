import 'dart:async';

import 'package:deutsch_bilarabi/core/progress/idempotent_review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

ReviewTransactionEnvelope review(
  String id, {
  required String pair,
  required DateTime at,
  String card = 'shared-card',
  int rating = 3,
}) =>
    ReviewTransactionEnvelope(
      reviewEventId: id,
      learnerContentKey: card,
      rating: rating,
      timestamp: at,
      languagePairKey: pair,
    );

void main() {
  final early = DateTime.utc(2026, 10, 25, 1);
  final late = early.add(const Duration(minutes: 1));

  test('stale checks are isolated by directed pair, not just card', () async {
    final committed = <ReviewTransactionEnvelope>[];
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (event) async { committed.add(event); },
    );

    final forward = await manager.commitReview(
      review('forward-new', pair: 'de_ar', at: late),
      activeLanguagePairKey: 'de_ar',
    );
    final reverse = await manager.commitReview(
      review('reverse-older', pair: 'ar_de', at: early),
      activeLanguagePairKey: 'ar_de',
    );

    expect(forward.state, TransactionState.committed);
    expect(reverse.state, TransactionState.committed);
    expect(committed.map((event) => event.reviewEventId).toList(),
        <String>['forward-new', 'reverse-older']);
  });

  test('older reviews within the same directed pair remain stale', () async {
    var commits = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async { commits++; },
    );
    expect(
      (await manager.commitReview(
        review('new', pair: 'de_ar', at: late),
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.committed,
    );
    expect(
      (await manager.commitReview(
        review('old', pair: 'de_ar', at: early),
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.failed,
    );
    expect(commits, 1);
  });

  test('reusing a committed ID with another directed pair fails closed',
      () async {
    var commits = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async { commits++; },
    );
    expect(
      (await manager.commitReview(
        review('shared-id', pair: 'de_ar', at: early),
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.committed,
    );
    final conflict = await manager.commitReview(
      review('shared-id', pair: 'ar_de', at: early),
      activeLanguagePairKey: 'ar_de',
    );
    expect(conflict.state, TransactionState.failed);
    expect(conflict.error, isNotNull);
    expect(commits, 1);
  });

  test('reusing a committed ID with changed rating fails closed', () async {
    var commits = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async { commits++; },
    );
    await manager.commitReview(
      review('rating-id', pair: 'de_ar', at: early),
      activeLanguagePairKey: 'de_ar',
    );
    final conflict = await manager.commitReview(
      review('rating-id', pair: 'de_ar', at: early, rating: 1),
      activeLanguagePairKey: 'de_ar',
    );
    expect(conflict.state, TransactionState.failed);
    expect(commits, 1);
  });

  test('out-of-order persistence completion cannot rewind stale guard',
      () async {
    final releaseEarly = Completer<void>();
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (event) async {
        if (event.reviewEventId == 'slow-early') {
          await releaseEarly.future;
        }
      },
    );
    final slowEarly = manager.commitReview(
      review('slow-early', pair: 'de_ar', at: early),
      activeLanguagePairKey: 'de_ar',
    );
    expect(
      (await manager.commitReview(
        review('fast-late', pair: 'de_ar', at: late),
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.committed,
    );
    releaseEarly.complete();
    expect((await slowEarly).state, TransactionState.committed);

    final middle = await manager.commitReview(
      review('middle', pair: 'de_ar',
          at: early.add(const Duration(seconds: 30))),
      activeLanguagePairKey: 'de_ar',
    );
    expect(middle.state, TransactionState.failed);
  });

  test('an identical committed retry remains idempotent', () async {
    var commits = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async { commits++; },
    );
    final envelope = review('retry-id', pair: 'de_ar', at: early);
    expect(
      (await manager.commitReview(
        envelope,
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.committed,
    );
    expect(
      (await manager.commitReview(
        envelope,
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.committed,
    );
    expect(commits, 1);
  });
}
