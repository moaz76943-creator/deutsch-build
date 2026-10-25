import 'dart:async';

import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingReviewPort implements ReviewCommandPort {
  final List<ReviewCommand> received = <ReviewCommand>[];
  Future<void> Function(ReviewCommand)? onSubmit;

  @override
  Future<void> submit(ReviewCommand command) async {
    received.add(command);
    if (onSubmit != null) await onSubmit!(command);
  }
}

ReviewCommand _review(
  String id, {
  String source = 'de',
  String target = 'ar',
  ReviewRating rating = ReviewRating.good,
}) =>
    ReviewCommand(
      reviewId: id,
      sourceLanguageId: source,
      targetLanguageId: target,
      semanticVersion: 'v2',
      cardId: 'shared-card',
      facetKey: 'lexeme',
      pairEpoch: 1,
      rating: rating,
      hinted: false,
    );

void main() {
  test('failed storage write allows identical review to retry', () async {
    final delegate = _RecordingReviewPort();
    var fail = true;
    delegate.onSubmit = (_) async {
      if (fail) {
        fail = false;
        throw StateError('simulated SQLite write failure');
      }
    };
    final port = IdempotentReviewCommandPort(delegate);
    final item = _review('failed-write');

    await expectLater(port.submit(item), throwsStateError);
    expect(delegate.received, hasLength(1));
    await port.submit(item);
    expect(delegate.received, hasLength(2));
    await port.submit(item);
    expect(delegate.received, hasLength(2),
        reason: 'A successful retry must not advance SRS twice');
  });

  test('concurrent identical submissions await the same write', () async {
    final pendingWrite = Completer<void>();
    final delegate = _RecordingReviewPort()
      ..onSubmit = (_) => pendingWrite.future;
    final port = IdempotentReviewCommandPort(delegate);
    final item = _review('same-event');

    final first = port.submit(item);
    final second = port.submit(item);
    var secondCompleted = false;
    second.then((_) => secondCompleted = true);
    await Future<void>.delayed(Duration.zero);

    expect(delegate.received, hasLength(1));
    expect(secondCompleted, isFalse,
        reason: 'Duplicate callers must not be told success before storage');
    pendingWrite.complete();
    await Future.wait(<Future<void>>[first, second]);
    expect(secondCompleted, isTrue);
  });

  test('failed in-flight write fails both callers and remains retryable',
      () async {
    final pendingWrite = Completer<void>();
    final delegate = _RecordingReviewPort()
      ..onSubmit = (_) => pendingWrite.future;
    final port = IdempotentReviewCommandPort(delegate);
    final item = _review('concurrent-failure');

    final firstFailure = expectLater(port.submit(item), throwsStateError);
    final secondFailure = expectLater(port.submit(item), throwsStateError);
    pendingWrite.completeError(StateError('SQLite busy'));
    await Future.wait(<Future<void>>[firstFailure, secondFailure]);
    expect(delegate.received, hasLength(1));

    delegate.onSubmit = (_) async {};
    await port.submit(item);
    expect(delegate.received, hasLength(2));
  });

  test('same ID with a different directed pair or rating fails closed',
      () async {
    final delegate = _RecordingReviewPort();
    final port = IdempotentReviewCommandPort(delegate);

    await port.submit(_review('immutable'));
    await expectLater(
      port.submit(_review('immutable', source: 'ar', target: 'de')),
      throwsStateError,
    );
    await expectLater(
      port.submit(_review('immutable', rating: ReviewRating.hard)),
      throwsStateError,
    );
    expect(delegate.received, hasLength(1));
  });

  test('a conflicting same-ID payload is rejected while pending', () async {
    final pendingWrite = Completer<void>();
    final delegate = _RecordingReviewPort()
      ..onSubmit = (_) => pendingWrite.future;
    final port = IdempotentReviewCommandPort(delegate);

    final forward = port.submit(_review('pending-id'));
    await expectLater(
      port.submit(_review('pending-id', source: 'ar', target: 'de')),
      throwsStateError,
    );
    pendingWrite.complete();
    await forward;
    expect(delegate.received, hasLength(1));
  });

  test('different review IDs in opposite directions persist independently',
      () async {
    final delegate = _RecordingReviewPort();
    final port = IdempotentReviewCommandPort(delegate);
    await Future.wait(<Future<void>>[
      port.submit(_review('de-to-ar', source: 'de', target: 'ar')),
      port.submit(_review('ar-to-de', source: 'ar', target: 'de')),
    ]);
    expect(delegate.received, hasLength(2));
    expect(delegate.received.map((item) => item.reviewId).toSet(),
        <String>{'de-to-ar', 'ar-to-de'});
  });
}
