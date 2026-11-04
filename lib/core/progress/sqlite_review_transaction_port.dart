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
  // Validate again at the durable boundary: callers may invoke this port
  // without ReviewTransactionManager. Underscores would alias pair identities.
  static final RegExp _languageTagPattern =
      RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$');
  static final RegExp _versionPattern =
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9.+-]*$');

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
    if (command.reviewId.trim().isEmpty ||
        command.reviewId != command.reviewId.trim() ||
        command.cardId.trim().isEmpty ||
        command.cardId != command.cardId.trim() ||
        command.facetKey.trim().isEmpty ||
        command.facetKey != command.facetKey.trim() ||
        !_languageTagPattern.hasMatch(command.sourceLanguageId) ||
        !_languageTagPattern.hasMatch(command.targetLanguageId) ||
        command.sourceLanguageId.toLowerCase() ==
            command.targetLanguageId.toLowerCase() ||
        !_versionPattern.hasMatch(command.semanticVersion) ||
        command.pairEpoch < 0) {
      throw ArgumentError('Invalid immutable review command identity');
    }
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
        // An event ID alone is not evidence of a sound durable commit.
        // A damaged timestamp must not turn a retry into a false success.
        // This journal writes UTC ISO-8601 strings exclusively.
        final storedInstant = row['occurred_at_utc'];
        if (storedInstant is! String ||
            !storedInstant.endsWith('Z') ||
            DateTime.tryParse(storedInstant) == null) {
          throw StateError('Committed review has invalid durable timestamp');
        }
        return ReviewCommitResult.alreadyCommitted;
      }


      // The in-memory stale guard is lost on process death. Enforce the
      // same ordering at the durable transaction boundary, before touching
      // progress/SRS, using only the committed journal for this exact pair,
      // epoch and card. Never compare opposite directions or pack databases.
      final latest = await txn.query(
        tableName,
        columns: <String>['occurred_at_utc'],
        // Each SRS facet is an independent schedule for the same card.
        // A newer meaning review must not reject an older spelling review.
        where: 'language_pair_key = ? AND source_language_id = ? '
            'AND target_language_id = ? AND semantic_version = ? '
            'AND pair_epoch = ? AND card_id = ? AND facet_key = ?',
        whereArgs: <Object>[
          envelope.languagePairKey,
          command.sourceLanguageId,
          command.targetLanguageId,
          command.semanticVersion,
          command.pairEpoch,
          command.cardId,
          command.facetKey,
        ],
        // Dart ISO-8601 UTC uses either .mmmZ or .mmmuuuZ. Raw lexical
        // DESC sorts .000Z after .000001Z, so compare millisecond prefix
        // first, then prefer the longer microsecond representation.
        orderBy: 'substr(occurred_at_utc, 1, 23) DESC, '
            'length(occurred_at_utc) DESC, occurred_at_utc DESC',
        limit: 1,
      );
      if (latest.isNotEmpty &&
          envelope.timestamp.toUtc().isBefore(
            DateTime.parse(latest.single['occurred_at_utc'] as String).toUtc(),
          )) {
        throw StateError('Stale review command after durable commit');
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
    if (!_languageTagPattern.hasMatch(sourceLanguageId) ||
        !_languageTagPattern.hasMatch(targetLanguageId) ||
        !_versionPattern.hasMatch(semanticVersion) ||
        sourceLanguageId.toLowerCase() == targetLanguageId.toLowerCase() ||
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
      // A legacy/corrupt row can carry a matching serialized key but
      // different stored components. Verify both identities on every read.
      where: 'language_pair_key = ? AND source_language_id = ? '
          'AND target_language_id = ? AND semantic_version = ?',
      whereArgs: <Object>[
        key, sourceLanguageId, targetLanguageId, semanticVersion,
      ],
      // ISO UTC uses .mmmZ for whole milliseconds and .mmmuuuZ for
      // microseconds. Lexical DESC alone places .000Z above .000001Z,
      // hiding the newer review when a bounded history limit is applied.
      // Match the durable stale guard's chronological ordering.
      orderBy: 'substr(occurred_at_utc, 1, 23) DESC, '
          'length(occurred_at_utc) DESC, occurred_at_utc DESC, '
          'review_id DESC',
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

