import '../architecture/directed_pair_id.dart';
import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_persistence_port.dart';

/// Validates the immutable review contract before forwarding to one durable
/// transaction authority. Never independently updates progress or SRS.
class ReviewTransactionManager {
  // Pair keys use underscores as separators; locale/version components must
  // never contain them or two different directed pairs can share one key.
  static final RegExp _languageTagPattern =
      RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$');
  static final RegExp _versionPattern =
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9.+-]*$');

  final TransactionPersistencePort persistencePort;
  final DateTime Function() clock;

  ReviewTransactionManager(this.persistencePort, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  Future<ReviewCommitResult> processTransaction(ReviewCommand command) async {
    final source = command.sourceLanguageId;
    final target = command.targetLanguageId;
    final version = command.semanticVersion;
    if (command.reviewId.trim().isEmpty ||
        command.cardId.trim().isEmpty ||
        command.facetKey.trim().isEmpty ||
        source.isEmpty ||
        target.isEmpty ||
        source != source.trim() ||
        target != target.trim() ||
        version.trim().isEmpty ||
        version != version.trim() ||
        source == target ||
        command.pairEpoch < 0) {
      throw ArgumentError('Invalid review event, version, or directed pair');
    }
    final pair = DirectedPairId(
      sourceLocale: source,
      targetLocale: target,
      semanticVersion: version,
    );
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: command.rating.index,
      timestamp: clock().toUtc(),
      languagePairKey: pair.uniqueKey,
    );
    return persistencePort.commitOnce(command: command, envelope: envelope);
  }
}

/// Adapt the verified atomic manager to widgets without exposing DB internals.
class DurableReviewCommandPort implements ReviewCommandPort {
  final ReviewTransactionManager manager;
  const DurableReviewCommandPort(this.manager);

  @override
  Future<void> submit(ReviewCommand command) async {
    await manager.processTransaction(command);
  }
}

