import 'dart:async';
import 'dart:collection';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

enum TransactionState {
  pending,
  committed,
  failed,
  recoverable,
}

class ReviewTransactionStatus {
  final ReviewTransactionEnvelope envelope;
  final TransactionState state;
  final Object? error;

  const ReviewTransactionStatus({
    required this.envelope,
    required this.state,
    this.error,
  });
}

class IdempotentReviewTransactionManager {
  final LinkedHashMap<String, ReviewTransactionStatus> _history =
      LinkedHashMap();
  // Keep stale-review ordering independent for each directed pair and card.
  // A card key alone incorrectly rejects valid reverse-direction reviews.
  final LinkedHashMap<(String, String), DateTime> _lastContentTimestamps =
      LinkedHashMap();
  // One non-throwing completion tail per active directed pair/card.
  final Map<(String, String), Future<void>> _scopeTails = {};
  final int maxHistorySize = 1000;

  final Future<void> Function(ReviewTransactionEnvelope)? _persistencePort;

  IdempotentReviewTransactionManager({
    Future<void> Function(ReviewTransactionEnvelope)? persistencePort,
  }) : _persistencePort = persistencePort;

  Future<ReviewTransactionStatus> commitReview(
    ReviewTransactionEnvelope envelope, {
    required String activeLanguagePairKey,
  }) async {
    // 1. Validate identity contracts
    if (envelope.reviewEventId.isEmpty) {
      return ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.failed,
        error: 'Invalid reviewEventId',
      );
    }

    // 2. Enforce exact source/target identity (A->B isolated from B->A)
    if (envelope.languagePairKey != activeLanguagePairKey) {
      return ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.failed,
        error:
            'Pair mismatch. Active: $activeLanguagePairKey, Transaction: ${envelope.languagePairKey}',
      );
    }

    // 3. An event ID represents one immutable review. Never acknowledge a
    // different pair, card, rating, or instant as an already committed event.
    final existingStatus = _history[envelope.reviewEventId];
    if (existingStatus != null) {
      final previous = existingStatus.envelope;
      if (previous.learnerContentKey != envelope.learnerContentKey ||
          previous.languagePairKey != envelope.languagePairKey ||
          previous.rating != envelope.rating ||
          !previous.timestamp.isAtSameMomentAs(envelope.timestamp)) {
        return ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.failed,
          error: 'Conflicting reviewEventId payload',
        );
      }
      if (existingStatus.state == TransactionState.committed ||
          existingStatus.state == TransactionState.pending) {
        return existingStatus;
      }
    }

    // 4. Serialize writes for one directed pair/card. Without this queue,
    // a slow older persistence call can finish after a newer review and
    // overwrite the learner's durable schedule. Other cards and reverse
    // directions remain independent.
    final contentScope = (envelope.languagePairKey, envelope.learnerContentKey);
    final predecessor = _scopeTails[contentScope];
    final turn = Completer<void>();
    _scopeTails[contentScope] = turn.future;

    // Reserve the ID synchronously before yielding so duplicate submissions
    // cannot start a second persistence call while this turn is waiting.
    var status = ReviewTransactionStatus(
      envelope: envelope,
      state: TransactionState.pending,
    );
    _recordStatus(envelope.reviewEventId, status);

    try {
      if (predecessor != null) await predecessor;

      // Check staleness only after prior writes finish, not when queued.
      final lastTimestamp = _lastContentTimestamps[contentScope];
      if (lastTimestamp != null && envelope.timestamp.isBefore(lastTimestamp)) {
        status = ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.failed,
          error: 'Stale review command',
        );
        _recordStatus(envelope.reviewEventId, status);
        return status;
      }

      try {
        if (_persistencePort != null) {
          await _persistencePort!(envelope);
        }

        status = ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.committed,
        );
        _recordStatus(envelope.reviewEventId, status);
        _recordTimestamp(contentScope, envelope.timestamp);
        return status;
      } catch (e) {
        status = ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.recoverable,
          error: e,
        );
        _recordStatus(envelope.reviewEventId, status);
        return status;
      }
    } finally {
      if (identical(_scopeTails[contentScope], turn.future)) {
        _scopeTails.remove(contentScope);
      }
      turn.complete();
    }
  }

  void _recordStatus(String id, ReviewTransactionStatus status) {
    if (_history.containsKey(id)) {
      _history.remove(id); // remove to insert at end for LRU
    }
    _history[id] = status;
    if (_history.length > maxHistorySize) {
      _history.remove(_history.keys.first); // remove oldest
    }
  }

  void _recordTimestamp((String, String) contentScope, DateTime timestamp) {
    final previous = _lastContentTimestamps[contentScope];
    // A slower in-flight commit must not roll the stale guard backwards.
    if (previous != null && timestamp.isBefore(previous)) return;
    _lastContentTimestamps.remove(contentScope);
    _lastContentTimestamps[contentScope] = timestamp;
    if (_lastContentTimestamps.length > maxHistorySize) {
      _lastContentTimestamps.remove(_lastContentTimestamps.keys.first);
    }
  }

  List<ReviewTransactionStatus> getRecoverableTransactions() {
    return _history.values
        .where((status) => status.state == TransactionState.recoverable)
        .toList();
  }
}
