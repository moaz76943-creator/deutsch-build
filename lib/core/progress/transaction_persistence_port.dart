import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';

enum TransactionCommitOutcome { applied, alreadyCommitted }

/// Required durable-store contract, NOT an in-memory journal.
///
/// An implementation MUST, in one durable SQLite write transaction:
/// 1. Validate uniqueness of reviewId globally and compare the complete
///    command payload (pair direction, epoch, facet, card, rating, hint).
/// 2. If identical and previously committed, do not advance any counters.
/// 3. Otherwise update SRS, progress, streak/XP and store the envelope
///    together, then commit. Roll back ALL updates on any exception.
/// 4. Never return [TransactionCommitOutcome.applied] before commit is durable.
///
/// A replay after process death or after a lost acknowledgment must therefore
/// return [TransactionCommitOutcome.alreadyCommitted]. Any ID collision with
/// different content MUST throw without writes. The caller cannot enforce this
/// by checking and writing in two separate asynchronous calls.
abstract interface class TransactionPersistencePort {
  Future<TransactionCommitOutcome> commitReviewAtomically({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  });
}
