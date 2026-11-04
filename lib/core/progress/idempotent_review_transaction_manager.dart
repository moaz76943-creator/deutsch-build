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

// Keep the final result available to exact concurrent retries until the
// underlying persistence operation finishes, even if bounded history evicts
// the pending entry.
class _InFlightReview {
  final ReviewTransactionEnvelope envelope;
  final Completer<ReviewTransactionStatus> completion =
      Completer<ReviewTransactionStatus>();

  _InFlightReview(this.envelope);
}

class IdempotentReviewTransactionManager {
  final LinkedHashMap<String, ReviewTransactionStatus> _history =
      LinkedHashMap();
  final Map<String, _InFlightReview> _inFlight = {};
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
    // 1. Reject malformed review identities and grades before reserving an
    // event ID or calling the canonical writer. The SRS grade contract is 0..3.
    // This also permits a corrected retry with the same previously rejected ID.
    if (envelope.reviewEventId.trim().isEmpty ||
        envelope.reviewEventId != envelope.reviewEventId.trim() ||
        envelope.learnerContentKey.trim().isEmpty ||
        envelope.learnerContentKey != envelope.learnerContentKey.trim() ||
        envelope.languagePairKey.trim().isEmpty ||
        envelope.languagePairKey != envelope.languagePairKey.trim() ||
        envelope.rating < 0 ||
        envelope.rating > 3) {
      return ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.failed,
        error: 'Invalid review identity or rating (expected 0..3)',
      );
    }

    // 2. Enforce exact source/target identity (A->B isolated from B->A)
    if (envelope.languagePairKey != activeLanguagePairKey) {
      return ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.failed,
        error: 'Pair mismatch. Active: $activeLanguagePairKey, Transaction: ${envelope.languagePairKey}',
      );
    }

    // Never report a review as committed when no durable writer was wired.
    // An in-memory acknowledgement would silently lose learner progress on
    // restart. Do not reserve the event ID or advance the stale watermark.
    if (_persistencePort == null) {
      return ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.failed,
        error: 'Review persistence writer unavailable',
      );
    }

    // 3. Exact retries share the eventual durable outcome, not a premature
    // pending acknowledgement. Check in-flight IDs before bounded history:
    // history eviction must not admit a second write of a pending event.
    final inFlight = _inFlight[envelope.reviewEventId];
    if (inFlight != null) {
      if (!_samePayload(inFlight.envelope, envelope)) {
        return ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.failed,
          error: 'Conflicting reviewEventId payload',
        );
      }
      return inFlight.completion.future;
    }

    // An event ID represents one immutable review. Never acknowledge a
    // different pair, card, rating, or instant as an already committed event.
    final existingStatus = _history[envelope.reviewEventId];
    if (existingStatus != null) {
      if (!_samePayload(existingStatus.envelope, envelope)) {
        return ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.failed,
          error: 'Conflicting reviewEventId payload',
        );
      }
      if (existingStatus.state == TransactionState.committed) {
        return existingStatus;
      }
      // A pending entry without its completion handle is inconsistent state.
      // Fail closed rather than telling a caller that its write succeeded.
      if (existingStatus.state == TransactionState.pending) {
        return ReviewTransactionStatus(
          envelope: envelope,
          state: TransactionState.failed,
          error: 'Pending review missing completion state',
        );
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

    // Reserve the ID and its completion synchronously before yielding.
    final reservation = _InFlightReview(envelope);
    _inFlight[envelope.reviewEventId] = reservation;
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
        await _persistencePort!(envelope);

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
    } catch (e) {
      // Also settle waiters if an unexpected queue/guard failure occurs.
      status = ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.recoverable,
        error: e,
      );
      _recordStatus(envelope.reviewEventId, status);
      return status;
    } finally {
      if (identical(_inFlight[envelope.reviewEventId], reservation)) {
        _inFlight.remove(envelope.reviewEventId);
      }
      reservation.completion.complete(status);
      if (identical(_scopeTails[contentScope], turn.future)) {
        _scopeTails.remove(contentScope);
      }
      turn.complete();
    }
  }

  static bool _samePayload(
    ReviewTransactionEnvelope previous,
    ReviewTransactionEnvelope incoming,
  ) =>
      previous.learnerContentKey == incoming.learnerContentKey &&
      previous.languagePairKey == incoming.languagePairKey &&
      previous.rating == incoming.rating &&
      previous.timestamp.isAtSameMomentAs(incoming.timestamp);

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
    // Never evict a committed watermark during this manager's lifetime.
    // Bounded status history is safe to discard, but losing the per-card
    // timestamp lets a delayed older review overwrite newer durable progress
    // after the learner has reviewed more than maxHistorySize other cards.
    // The canonical SQLite writer remains responsible for restart safety.
    _lastContentTimestamps[contentScope] = timestamp;
  }

  List<ReviewTransactionStatus> getRecoverableTransactions() {
    return _history.values
        .where((status) => status.state == TransactionState.recoverable)
        .toList();
  }
}
