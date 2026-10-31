import 'dart:async';

import 'package:deutsch_bilarabi/core/progress/duplicate_preventing_review_command_port.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingDelegate implements ReviewCommandPort {
  final List<ReviewCommand> received = <ReviewCommand>[];
  Future<void> Function(ReviewCommand)? onSubmit;

  @override
  Future<void> submit(ReviewCommand command) async {
    received.add(command);
    if (onSubmit != null) await onSubmit!(command);
  }
}

ReviewCommand _review(
  String eventId, {
  String card = 'card-1',
  ReviewRating rating = ReviewRating.good,
}) =>
    ReviewCommand(
      reviewId: eventId,
      sourceLanguageId: 'de',
      targetLanguageId: 'ar',
      semanticVersion: 'v2',
      cardId: card,
      facetKey: 'lexeme',
      pairEpoch: 1,
      rating: rating,
      hinted: false,
    );

void main() {
  test('recoverable write is retried and successful ID stays deduplicated',
      () async {
    final delegate = _RecordingDelegate();
    var fail = true;
    delegate.onSubmit = (_) async {
      if (fail) {
        fail = false;
        throw StateError('interrupted SQLite write');
      }
    };
    final port = DuplicatePreventingReviewCommandPort(
      delegate: delegate,
      expectedLanguagePairKey: 'de_ar',
    );

    final item = _review('retry');
    await expectLater(port.submit(item), throwsStateError);
    await port.submit(item);
    await port.submit(item);
    expect(delegate.received, hasLength(2));
  });

  test('duplicate pending caller awaits the durable write result', () async {
    final gate = Completer<void>();
    final delegate = _RecordingDelegate()..onSubmit = (_) => gate.future;
    final port = DuplicatePreventingReviewCommandPort(
      delegate: delegate,
      expectedLanguagePairKey: 'de_ar',
    );

    final first = port.submit(_review('pending'));
    final second = port.submit(_review('pending'));
    var secondCompleted = false;
    second.then((_) => secondCompleted = true);
    await Future<void>.delayed(Duration.zero);
    expect(delegate.received, hasLength(1));
    expect(secondCompleted, isFalse);
    gate.complete();
    await Future.wait(<Future<void>>[first, second]);
    expect(secondCompleted, isTrue);
  });

  test('pending failure is observable to both callers, then retry succeeds',
      () async {
    final gate = Completer<void>();
    final delegate = _RecordingDelegate()..onSubmit = (_) => gate.future;
    final port = DuplicatePreventingReviewCommandPort(
      delegate: delegate,
      expectedLanguagePairKey: 'de_ar',
    );
    final first = expectLater(port.submit(_review('failure')), throwsStateError);
    final second = expectLater(port.submit(_review('failure')), throwsStateError);
    gate.completeError(StateError('disk full'));
    await Future.wait(<Future<void>>[first, second]);
    delegate.onSubmit = (_) async {};
    await port.submit(_review('failure'));
    expect(delegate.received, hasLength(2));
  });

  test('conflicting same-ID payload is rejected pending and committed',
      () async {
    final gate = Completer<void>();
    final delegate = _RecordingDelegate()..onSubmit = (_) => gate.future;
    final port = DuplicatePreventingReviewCommandPort(
      delegate: delegate,
      expectedLanguagePairKey: 'de_ar',
    );
    final first = port.submit(_review('immutable'));
    await expectLater(
      port.submit(_review('immutable', card: 'card-2')),
      throwsStateError,
    );
    gate.complete();
    await first;
    await expectLater(
      port.submit(_review('immutable', rating: ReviewRating.hard)),
      throwsStateError,
    );
    expect(delegate.received, hasLength(1));
  });

  test('mismatched direction is rejected without touching storage', () async {
    final delegate = _RecordingDelegate();
    final port = DuplicatePreventingReviewCommandPort(
      delegate: delegate,
      expectedLanguagePairKey: 'de_ar',
    );
    const reverse = ReviewCommand(
      reviewId: 'reverse',
      sourceLanguageId: 'ar',
      targetLanguageId: 'de',
      semanticVersion: 'v2',
      cardId: 'card-1',
      facetKey: 'lexeme',
      pairEpoch: 1,
      rating: ReviewRating.good,
      hinted: false,
    );
    await expectLater(port.submit(reverse), throwsArgumentError);
    expect(delegate.received, isEmpty);
  });
}
