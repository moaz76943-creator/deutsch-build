import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';

enum ReviewCommitResult { committed, alreadyCommitted }

/// Required DB/worker boundary: the UNIQUE reviewId constraint, validated
/// command payload, progress advance, SRS advance and committed event MUST
/// persist together in ONE atomic transaction. A collision with a different
/// command payload must throw, not return alreadyCommitted.
///
/// Implementations must not perform non-transactional external side effects.
/// On interruption before commit, retry applies once; after commit, retry
/// returns alreadyCommitted. No production implementation is supplied here
/// until the canonical persistence owner exposes the transaction primitive.
abstract interface class TransactionPersistencePort {
  Future<ReviewCommitResult> commitOnce({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  });
}
