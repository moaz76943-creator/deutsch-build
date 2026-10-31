import 'dart:async';

import '../srs/review_command_port.dart';
import 'review_transaction_state.dart';

class DuplicatePreventingReviewCommandPort implements ReviewCommandPort {
  final ReviewCommandPort _delegate;
  final String expectedLanguagePairKey;

  final Map<String, ReviewTransactionState> _transactionStates = {};

  DuplicatePreventingReviewCommandPort({
    required ReviewCommandPort delegate,
    required this.expectedLanguagePairKey,
  }) : _delegate = delegate;

  @override
  Future<void> submit(ReviewCommand command) async {
    final commandPairKey = '${command.sourceLanguageId}_${command.targetLanguageId}';
    if (commandPairKey != expectedLanguagePairKey) {
      throw ArgumentError(
        'Language pair mismatch. Expected: $expectedLanguagePairKey, Got: $commandPairKey',
      );
    }

    final currentState = _transactionStates[command.reviewId];

    if (currentState == ReviewTransactionState.committed ||
        currentState == ReviewTransactionState.pending) {
      // Idempotency: skip processing if already handled or in progress
      return;
    }

    _transactionStates[command.reviewId] = ReviewTransactionState.pending;

    try {
      await _delegate.submit(command);
      _transactionStates[command.reviewId] = ReviewTransactionState.committed;
    } catch (e) {
      // In a real scenario, we might want to differentiate between
      // recoverable errors (e.g. network timeout) and non-recoverable (e.g. invalid data).
      // Here, to fulfill the requirement, we'll mark as recoverable to allow retries.
      _transactionStates[command.reviewId] = ReviewTransactionState.recoverable;
      rethrow;
    }
  }
}
