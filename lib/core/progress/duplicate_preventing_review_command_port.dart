import 'dart:async';

import '../srs/review_command_port.dart';
import 'review_transaction_state.dart';

class DuplicatePreventingReviewCommandPort implements ReviewCommandPort {
  final ReviewCommandPort _delegate;
  final String expectedLanguagePairKey;

  final Map<String, ReviewTransactionState> _transactionStates = {};
  final Map<String, ReviewCommand> _commandsById = {};
  final Map<String, Future<void>> _pendingWrites = {};

  DuplicatePreventingReviewCommandPort({
    required ReviewCommandPort delegate,
    required this.expectedLanguagePairKey,
  }) : _delegate = delegate;

  @override
  Future<void> submit(ReviewCommand command) {
    final commandPairKey =
        '${command.sourceLanguageId}_${command.targetLanguageId}';
    if (commandPairKey != expectedLanguagePairKey) {
      return Future<void>.error(ArgumentError(
        'Language pair mismatch. Expected: $expectedLanguagePairKey, Got: $commandPairKey',
      ));
    }

    // The review ID is an immutable event identity, not merely a cache key.
    // Checking a committed/pending flag before comparing payloads would
    // silently discard a distinct rating or card using the same ID.
    final original = _commandsById[command.reviewId];
    if (original != null && !original.samePayloadAs(command)) {
      return Future<void>.error(
        StateError('Review ID reused with a conflicting payload'),
      );
    }

    if (_transactionStates[command.reviewId] ==
        ReviewTransactionState.committed) {
      return Future<void>.value();
    }

    // A duplicate must await the actual storage result, including a failure.
    final pending = _pendingWrites[command.reviewId];
    if (pending != null) return pending;

    final completion = Completer<void>();
    _commandsById[command.reviewId] = command;
    _transactionStates[command.reviewId] = ReviewTransactionState.pending;
    _pendingWrites[command.reviewId] = completion.future;
    _submitAndTrack(command, completion);
    return completion.future;
  }

  Future<void> _submitAndTrack(
    ReviewCommand command,
    Completer<void> completion,
  ) async {
    try {
      await _delegate.submit(command);
      _transactionStates[command.reviewId] = ReviewTransactionState.committed;
      completion.complete();
    } catch (error, stackTrace) {
      // Do not acknowledge an incomplete write; permit an identical retry.
      _transactionStates[command.reviewId] = ReviewTransactionState.recoverable;
      completion.completeError(error, stackTrace);
    } finally {
      _pendingWrites.remove(command.reviewId);
    }
  }
}
