import 'package:sqflite/sqflite.dart';

import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_persistence_port.dart';

/// An opt-in adapter for the EXISTING canonical application Database.
/// The caller must pass the SAME database/worker owning SRS and progress.
/// Never open a second progress database or create a second authority.
typedef AtomicReviewMutation = Future<void> Function(
  Transaction transaction,
  ReviewCommand command,
);

/// SQLite UNIQUE-event journal and the caller's canonical progress/SRS writes
/// commit or roll back together in one SQFlite transaction.
class SqliteReviewTransactionPort implements TransactionPersistencePort {
  final Database database;
  final AtomicReviewMutation applyReview;

  const SqliteReviewTransactionPort({
    required this.database,
    required this.applyReview,
  });

  static const String tableName = 'srs_review_event_journal_v2';
  static const String _createTable = '''
CREATE TABLE IF NOT EXISTS srs_review_event_journal_v2 (
  review_id TEXT PRIMARY KEY NOT NULL,
  source_language_id TEXT NOT NULL,
  target_language_id TEXT NOT NULL,
  semantic_version TEXT NOT NULL,
  language_pair_key TEXT NOT NULL,
  pair_epoch INTEGER NOT NULL,
  card_id TEXT NOT NULL,
  facet_key TEXT NOT NULL,
  rating INTEGER NOT NULL,
  hinted INTEGER NOT NULL,
  occurred_at_utc TEXT NOT NULL
)
''';

  @override
  Future<ReviewCommitResult> commitOnce({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  }) async {
    if (envelope.reviewEventId != command.reviewId ||
        envelope.learnerContentKey != command.cardId ||
        envelope.rating != command.rating.index ||
        envelope.languagePairKey !=
            '${command.sourceLanguageId}_${command.targetLanguageId}_${command.semanticVersion}') {
      throw ArgumentError('Envelope and immutable review command disagree');
    }

    return database.transaction<ReviewCommitResult>((txn) async {
      await txn.execute(_createTable);
      final existing = await txn.query(
        tableName,
        where: 'review_id = ?',
        whereArgs: <Object>[command.reviewId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final row = existing.first;
        final matches = row['source_language_id'] == command.sourceLanguageId &&
            row['target_language_id'] == command.targetLanguageId &&
            row['semantic_version'] == command.semanticVersion &&
            row['language_pair_key'] == envelope.languagePairKey &&
            row['pair_epoch'] == command.pairEpoch &&
            row['card_id'] == command.cardId &&
            row['facet_key'] == command.facetKey &&
            row['rating'] == command.rating.index &&
            row['hinted'] == (command.hinted ? 1 : 0);
        if (!matches) {
          throw StateError('Review event ID reused with a conflicting payload');
        }
        return ReviewCommitResult.alreadyCommitted;
      }

      await txn.insert(tableName, <String, Object>{
        'review_id': command.reviewId,
        'source_language_id': command.sourceLanguageId,
        'target_language_id': command.targetLanguageId,
        'semantic_version': command.semanticVersion,
        'language_pair_key': envelope.languagePairKey,
        'pair_epoch': command.pairEpoch,
        'card_id': command.cardId,
        'facet_key': command.facetKey,
        'rating': command.rating.index,
        'hinted': command.hinted ? 1 : 0,
        'occurred_at_utc': envelope.timestamp.toUtc().toIso8601String(),
      });
      // A callback using `database` instead of `txn` would violate atomicity.
      // Runtime owner must wire the real SRS/progress DAO using this txn only.
      await applyReview(txn, command);
      return ReviewCommitResult.committed;
    });
  }

  /// Read only durable, committed events for a versioned directed pair.
  /// Consumers such as local analytics must never use the in-memory journal.
  Future<List<ReviewTransactionEnvelope>> readCommittedReviews({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String semanticVersion,
    int limit = 50000,
  }) async {
    if (sourceLanguageId.trim().isEmpty ||
        targetLanguageId.trim().isEmpty ||
        semanticVersion.trim().isEmpty ||
        sourceLanguageId == targetLanguageId ||
        limit < 1 ||
        limit > 50000) {
      throw ArgumentError('Invalid directed pair or bounded read limit');
    }
    final key = '${sourceLanguageId}_${targetLanguageId}_$semanticVersion';
    await database.execute(_createTable);
    final rows = await database.query(
      tableName,
      columns: <String>[
        'review_id',
        'card_id',
        'rating',
        'occurred_at_utc',
        'language_pair_key',
      ],
      where: 'language_pair_key = ?',
      whereArgs: <Object>[key],
      // Newest records first so bounded history cannot hide recent learning.
      orderBy: 'occurred_at_utc DESC, review_id DESC',
      limit: limit,
    );
    return List<ReviewTransactionEnvelope>.unmodifiable(
      rows.map((row) => ReviewTransactionEnvelope(
            reviewEventId: row['review_id'] as String,
            learnerContentKey: row['card_id'] as String,
            rating: row['rating'] as int,
            timestamp: DateTime.parse(row['occurred_at_utc'] as String).toUtc(),
            languagePairKey: row['language_pair_key'] as String,
          )),
    );
  }
}
