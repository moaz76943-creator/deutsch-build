import 'package:sqflite/sqflite.dart';
import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_persistence_port.dart';

typedef ReviewMutation = Future<void> Function(
  Transaction transaction,
  ReviewCommand command,
);

/// Durable, single-transaction application of one directed-pair review.
///
/// The caller MUST supply an [applyReview] implementation that performs all
/// SRS/progress/XP updates with the given [Transaction] (never the parent DB).
/// This adapter does not assume any particular learner-state table layout.
/// A new namespaced table is added non-destructively; existing user tables
/// and historical review data are not modified.
class SqliteReviewTransactionPort implements TransactionPersistencePort {
  final Database database;
  final ReviewMutation applyReview;

  const SqliteReviewTransactionPort(
    this.database, {
    required this.applyReview,
  });

  static const String _eventTable = 'learning_atomic_review_events_v1';

  @override
  Future<TransactionCommitOutcome> commitReviewAtomically({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  }) {
    if (envelope.reviewEventId != command.reviewId ||
        envelope.learnerContentKey != command.cardId ||
        envelope.rating != command.rating.index ||
        envelope.languagePairKey !=
            command.sourceLanguageId + '_' + command.targetLanguageId ||
        command.reviewId.trim().isEmpty ||
        command.cardId.trim().isEmpty ||
        command.sourceLanguageId.trim().isEmpty ||
        command.targetLanguageId.trim().isEmpty ||
        command.sourceLanguageId == command.targetLanguageId ||
        command.pairEpoch < 0 ||
        command.facetKey.trim().isEmpty) {
      throw ArgumentError('Conflicting or malformed review transaction');
    }

    return database.transaction<TransactionCommitOutcome>((tx) async {
      await tx.execute('CREATE TABLE IF NOT EXISTS $_eventTable ('
          'event_id TEXT PRIMARY KEY NOT NULL, '
          'card_id TEXT NOT NULL, '
          'source_locale TEXT NOT NULL, '
          'target_locale TEXT NOT NULL, '
          'pair_epoch INTEGER NOT NULL, '
          'facet_key TEXT NOT NULL, '
          'rating INTEGER NOT NULL, '
          'hinted INTEGER NOT NULL, '
          'occurred_at_utc TEXT NOT NULL)');

      final existing = await tx.query(
        _eventTable,
        columns: const [
          'card_id', 'source_locale', 'target_locale', 'pair_epoch',
          'facet_key', 'rating', 'hinted',
        ],
        where: 'event_id = ?',
        whereArgs: [command.reviewId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final row = existing.single;
        if (row['card_id'] != command.cardId ||
            row['source_locale'] != command.sourceLanguageId ||
            row['target_locale'] != command.targetLanguageId ||
            row['pair_epoch'] != command.pairEpoch ||
            row['facet_key'] != command.facetKey ||
            row['rating'] != command.rating.index ||
            row['hinted'] != (command.hinted ? 1 : 0)) {
          throw StateError('Review event ID was reused with different content');
        }
        return TransactionCommitOutcome.alreadyCommitted;
      }

      await tx.insert(_eventTable, {
        'event_id': command.reviewId,
        'card_id': command.cardId,
        'source_locale': command.sourceLanguageId,
        'target_locale': command.targetLanguageId,
        'pair_epoch': command.pairEpoch,
        'facet_key': command.facetKey,
        'rating': command.rating.index,
        'hinted': command.hinted ? 1 : 0,
        'occurred_at_utc': envelope.timestamp.toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      // Any failure rolls back both marker and all transaction-scoped writes.
      await applyReview(tx, command);
      return TransactionCommitOutcome.applied;
    });
  }
}
