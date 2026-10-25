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

  test('same-card writes finish in submission order, never stale last',
      () async {
    final releaseEarly = Completer<void>();
    final persisted = <String>[];
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (event) async {
        if (event.reviewEventId == 'slow-early') {
          await releaseEarly.future;
        }
        persisted.add(event.reviewEventId);
      },
    );
    final slowEarly = manager.commitReview(
      review('slow-early', pair: 'de_ar', at: early),
      activeLanguagePairKey: 'de_ar',
    );
    final fastLate = manager.commitReview(
      review('fast-late', pair: 'de_ar', at: late),
      activeLanguagePairKey: 'de_ar',
    );
    await Future<void>.delayed(Duration.zero);
    expect(persisted, isEmpty,
        reason: 'A newer write must wait for the earlier in-flight write');
    releaseEarly.complete();
    expect((await slowEarly).state, TransactionState.committed);
    expect((await fastLate).state, TransactionState.committed);
    expect(persisted, <String>['slow-early', 'fast-late']);

    final middle = await manager.commitReview(
      review('middle', pair: 'de_ar',
          at: early.add(const Duration(seconds: 30))),
      activeLanguagePairKey: 'de_ar',
    );
    expect(middle.state, TransactionState.failed);
    expect(persisted, hasLength(2));
  });

  test('older queued review is rejected after newer durable review', () async {
    final releaseNewer = Completer<void>();
    final persisted = <String>[];
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (event) async {
        if (event.reviewEventId == 'newer') await releaseNewer.future;
        persisted.add(event.reviewEventId);
      },
    );
    final newer = manager.commitReview(
      review('newer', pair: 'de_ar', at: late),
      activeLanguagePairKey: 'de_ar',
    );
    final older = manager.commitReview(
      review('older', pair: 'de_ar', at: early),
      activeLanguagePairKey: 'de_ar',
    );
    await Future<void>.delayed(Duration.zero);
    expect(persisted, isEmpty);
    releaseNewer.complete();
    expect((await newer).state, TransactionState.committed);
    expect((await older).state, TransactionState.failed);
    expect(persisted, <String>['newer']);
  });

  test('reverse pair persists while forward pair is blocked', () async {
    final releaseForward = Completer<void>();
    final persisted = <String>[];
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (event) async {
        if (event.reviewEventId == 'forward') await releaseForward.future;
        persisted.add(event.reviewEventId);
      },
    );
    final forward = manager.commitReview(
      review('forward', pair: 'de_ar', at: late),
      activeLanguagePairKey: 'de_ar',
    );
    final reverse = await manager.commitReview(
      review('reverse', pair: 'ar_de', at: early),
      activeLanguagePairKey: 'ar_de',
    );
    expect(reverse.state, TransactionState.committed);
    expect(persisted, <String>['reverse']);
    releaseForward.complete();
    expect((await forward).state, TransactionState.committed);
    expect(persisted, <String>['reverse', 'forward']);
  });

  test('recoverable same-payload review retries after storage failure',
      () async {
    var failStorage = true;
    var commits = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async {
        if (failStorage) throw StateError('temporary storage failure');
        commits++;
      },
    );
    final envelope = review('recoverable-id', pair: 'de_ar', at: early);
    expect(
      (await manager.commitReview(
        envelope,
        activeLanguagePairKey: 'de_ar',
      ))
          .state,
      TransactionState.recoverable,
    );
    failStorage = false;
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

  test('concurrent identical retries wait for durable success', () async {
    final release = Completer<void>();
    var writes = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async {
        writes++;
        await release.future;
      },
    );
    final envelope = review('pending-success', pair: 'de_ar', at: early);
    final first = manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
    final duplicate =
        manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
    var duplicateFinished = false;
    duplicate.then((_) => duplicateFinished = true);
    await Future<void>.delayed(Duration.zero);
    expect(duplicateFinished, isFalse,
        reason: 'Pending persistence must never be acknowledged as complete');
    expect(writes, 1);
    release.complete();
    final results = await Future.wait([first, duplicate]);
    expect(results.every((result) => result.state == TransactionState.committed),
        isTrue);
    expect(writes, 1);
  });

  test('concurrent identical retries receive storage failure and can retry',
      () async {
    final release = Completer<void>();
    var attempts = 0;
    var fail = true;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async {
        attempts++;
        if (fail) {
          await release.future;
          throw StateError('temporary storage failure');
        }
      },
    );
    final envelope = review('pending-failure', pair: 'de_ar', at: early);
    final first = manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
    final duplicate =
        manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
    release.complete();
    final results = await Future.wait([first, duplicate]);
    expect(results.every((result) => result.state == TransactionState.recoverable),
        isTrue);
    expect(attempts, 1);
    fail = false;
    expect(
      (await manager.commitReview(envelope, activeLanguagePairKey: 'de_ar'))
          .state,
      TransactionState.committed,
    );
    expect(attempts, 2);
  });

  test('conflicting pending event ID fails without another write', () async {
    final release = Completer<void>();
    var writes = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async {
        writes++;
        await release.future;
      },
    );
    final first = manager.commitReview(
      review('pending-conflict', pair: 'de_ar', at: early),
      activeLanguagePairKey: 'de_ar',
    );
    final conflict = await manager.commitReview(
      review('pending-conflict', pair: 'de_ar', at: early, rating: 1),
      activeLanguagePairKey: 'de_ar',
    );
    expect(conflict.state, TransactionState.failed);
    expect(writes, 1);
    release.complete();
    expect((await first).state, TransactionState.committed);
  });

  test('pending dedup survives bounded history eviction', () async {
    final release = Completer<void>();
    var writes = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async {
        writes++;
        await release.future;
      },
    );
    final original = review('oldest-pending', pair: 'de_ar', at: early);
    final first = manager.commitReview(original, activeLanguagePairKey: 'de_ar');
    final others = <Future<ReviewTransactionStatus>>[];
    for (var index = 0; index < 1001; index++) {
      others.add(manager.commitReview(
        review('other-$index', pair: 'de_ar', at: early, card: 'card-$index'),
        activeLanguagePairKey: 'de_ar',
      ));
    }
    final duplicate =
        manager.commitReview(original, activeLanguagePairKey: 'de_ar');
    var settled = false;
    duplicate.then((_) => settled = true);
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse);
    expect(writes, 1002,
        reason: 'The evicted pending ID must not start a second write');
    release.complete();
    expect((await first).state, TransactionState.committed);
    expect((await duplicate).state, TransactionState.committed);
    expect((await Future.wait(others))
        .every((result) => result.state == TransactionState.committed), isTrue);
    expect(writes, 1002);
  });


  test('invalid ratings and malformed review identities cannot persist', () async {
    var writes = 0;
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (_) async { writes++; },
    );
    final malformed = <ReviewTransactionEnvelope>[
      review('negative-grade', pair: 'de_ar', at: early, rating: -1),
      review('oversized-grade', pair: 'de_ar', at: early, rating: 4),
      review('blank-card', pair: 'de_ar', at: early, card: ' '),
      review('untrimmed-card', pair: 'de_ar', at: early, card: ' card'),
      review(' ', pair: 'de_ar', at: early),
      review('untrimmed-id ', pair: 'de_ar', at: early),
      review('blank-pair', pair: ' ', at: early),
    ];

    for (final envelope in malformed) {
      final result = await manager.commitReview(
        envelope,
        activeLanguagePairKey: envelope.languagePairKey,
      );
      expect(result.state, TransactionState.failed,
          reason: 'Malformed review must fail before the persistence port');
      expect(result.error, isNotNull);
    }
    expect(writes, 0);

    // Rejected payloads must not reserve an ID or poison a corrected retry.
    final corrected = await manager.commitReview(
      review('oversized-grade', pair: 'de_ar', at: early, rating: 3),
      activeLanguagePairKey: 'de_ar',
    );
    expect(corrected.state, TransactionState.committed);
    expect(writes, 1);
  });

  test('never acknowledges a review without a persistence writer', () async {
    final manager = IdempotentReviewTransactionManager();
    final envelope = review('missing-writer', pair: 'de_ar', at: early);

    final first = await manager.commitReview(
      envelope,
      activeLanguagePairKey: 'de_ar',
    );
    final retry = await manager.commitReview(
      envelope,
      activeLanguagePairKey: 'de_ar',
    );

    expect(first.state, TransactionState.failed);
    expect(first.error, isNotNull);
    expect(retry.state, TransactionState.failed);
    expect(retry.error, isNotNull);
    expect(manager.getRecoverableTransactions(), isEmpty);
  });

  test('stale guard survives bounded history and card churn', () async {
    final persistedIds = <String>[];
    final manager = IdempotentReviewTransactionManager(
      persistencePort: (event) async {
        persistedIds.add(event.reviewEventId);
      },
    );
    const originalCard = 'first-reviewed-card';
    final newest = await manager.commitReview(
      review('first-newest', pair: 'de_ar', at: late, card: originalCard),
      activeLanguagePairKey: 'de_ar',
    );
    expect(newest.state, TransactionState.committed);

    // Exceed the 1,000-entry status cache without ending the session.
    // Evicting a card's last committed timestamp must not authorize
    // an older write to overwrite its canonical SRS schedule.
    for (var index = 0; index < 1001; index++) {
      final result = await manager.commitReview(
        review('churn-$index', pair: 'de_ar', at: late,
            card: 'other-card-$index'),
        activeLanguagePairKey: 'de_ar',
      );
      expect(result.state, TransactionState.committed);
    }

    final stale = await manager.commitReview(
      review('first-stale', pair: 'de_ar', at: early, card: originalCard),
      activeLanguagePairKey: 'de_ar',
    );
    expect(stale.state, TransactionState.failed);
    expect(persistedIds, isNot(contains('first-stale')));
  });

}
