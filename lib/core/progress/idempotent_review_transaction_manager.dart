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
  final LinkedHashMap<String, DateTime> _lastContentTimestamps =
      LinkedHashMap();
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

    // 3. Reject duplicate review commands based on history LRU cache
    if (_history.containsKey(envelope.reviewEventId)) {
      final existingStatus = _history[envelope.reviewEventId]!;
      // If already committed or pending, return existing status
      if (existingStatus.state == TransactionState.committed ||
          existingStatus.state == TransactionState.pending) {
        return existingStatus;
      }
    }

    // 4. Reject stale commands
    final lastTimestamp = _lastContentTimestamps[envelope.learnerContentKey];
    if (lastTimestamp != null && envelope.timestamp.isBefore(lastTimestamp)) {
      return ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.failed,
        error: 'Stale review command',
      );
    }

    // Transition to pending
    var status = ReviewTransactionStatus(
      envelope: envelope,
      state: TransactionState.pending,
    );
    _recordStatus(envelope.reviewEventId, status);

    try {
      if (_persistencePort != null) {
        await _persistencePort!(envelope);
      }

      // Transition to committed
      status = ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.committed,
      );
      _recordStatus(envelope.reviewEventId, status);
      // Update last successful interaction timestamp for this content
      _recordTimestamp(envelope.learnerContentKey, envelope.timestamp);
      return status;
    } catch (e) {
      // Transition to recoverable
      status = ReviewTransactionStatus(
        envelope: envelope,
        state: TransactionState.recoverable,
        error: e,
      );
      _recordStatus(envelope.reviewEventId, status);
      return status;
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

  void _recordTimestamp(String contentKey, DateTime timestamp) {
    if (_lastContentTimestamps.containsKey(contentKey)) {
      _lastContentTimestamps.remove(contentKey);
    }
    _lastContentTimestamps[contentKey] = timestamp;
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
