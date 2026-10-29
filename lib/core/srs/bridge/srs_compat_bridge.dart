import 'dart:async';
import 'dart:math';

import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

/// Must complete only after the app-owned canonical learner/SRS transaction
/// commits durably. Never use a memory-only journal or a content-pack database.
typedef SrsDurableReviewWriter = Future<void> Function(
  ReviewTransactionEnvelope envelope,
);

class SrsCompatBridge {
  SrsCompatBridge({
    DateTime Function()? clock,
    SrsDurableReviewWriter? durableWriter,
  })  : _clock = clock ?? DateTime.now,
        _durableWriter = durableWriter;

  static final SrsCompatBridge instance = SrsCompatBridge();

  // Underscore separates the directed pair in persisted identity. Allowing
  // it inside either BCP-47-like language tag makes distinct directions
  // collide (de_ar + fr == de + ar_fr). Do not silently rewrite stored keys.
  static final RegExp _languageCodePattern =
      RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$');

  final UnifiedSrsScheduler _scheduler = UnifiedSrsScheduler.instance;
  final DateTime Function() _clock;
  SrsDurableReviewWriter? _durableWriter;
  // Review ordering is based on the instant assigned to each submission,
  // not the device wall clock alone. Clock rollback must not cause a newer
  // user action to be rejected by the canonical stale-review guard.
  // Keep this instance-local so separate bridges do not share test/owner state.
  int? _lastAssignedTimestampMicros;
  // Keep the write order for one directed pair/card. A slow earlier write
  // must not finish after a newer one and overwrite its durable schedule.
  // This is an in-process ordering guard, not a SQLite transaction authority.
  final Map<(String, String), Future<void>> _writeTails = {};

  /// Called by the canonical persistence owner after it has opened and
  /// verified the learner database. A second owner must not replace it.
  void bindCanonicalWriter(SrsDurableReviewWriter writer) {
    if (_durableWriter != null) {
      throw StateError('Canonical SRS writer already bound');
    }
    _durableWriter = writer;
  }

  // The compatibility journal deduplicates by reviewEventId. Millisecond
  // timestamps alone silently discard rapid reviews of the same card,
  // including reviews in opposite language directions. Use a monotonic
  // in-process microsecond identity even when the wall clock stalls or moves
  // backwards. This does not change persisted learner progress or SRS keys.
  // Monotonic microseconds prevent same-process collisions, but a fresh
  // process/isolate resets that counter. If the device clock moves backwards,
  // a clock-only ID can collide with an already committed durable review and
  // incorrectly deduplicate new learner progress. One random 128-bit nonce
  // per isolate distinguishes restart epochs without changing stored IDs.
  static final String _isolateNonce = _newIsolateNonce();
  static String _newIsolateNonce() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static int _lastIssuedEventMicros = -1;

  Future<void> recordReviewCompat({
    required String contentKey,
    required int rating,
    required String sourceIso,
    required String targetIso,
  }) async {
    if (contentKey.trim().isEmpty ||
        contentKey != contentKey.trim() ||
        sourceIso.trim().isEmpty ||
        targetIso.trim().isEmpty ||
        sourceIso != sourceIso.trim() ||
        targetIso != targetIso.trim() ||
        !_languageCodePattern.hasMatch(sourceIso) ||
        !_languageCodePattern.hasMatch(targetIso) ||
        sourceIso.toLowerCase() == targetIso.toLowerCase()) {
      throw ArgumentError('Invalid SRS content or directed pair');
    }
    // The legacy flashcard surface emits 4 for "correct", but canonical
    // ReviewRating is 0..3 (easy == 3). Never persist an invalid grade.
    final canonicalRating = rating == 4 ? 3 : rating;
    if (canonicalRating < 0 || canonicalRating > 3) {
      throw ArgumentError.value(rating, 'rating', 'Expected a grade from 0 to 4');
    }

    // The legacy scheduler below is only an in-process projection. Without
    // an app-owned atomic SQLite writer, returning success loses the review
    // on process death. Fail closed rather than acknowledging phantom progress.
    final writer = _durableWriter;
    if (writer == null) {
      throw StateError('Canonical SRS persistence writer is not bound');
    }

    final wallMicros = _clock().toUtc().microsecondsSinceEpoch;
    final previousMicros = _lastAssignedTimestampMicros;
    final reviewMicros = previousMicros != null && wallMicros <= previousMicros
        ? previousMicros + 1
        : wallMicros;
    _lastAssignedTimestampMicros = reviewMicros;
    final timestamp = DateTime.fromMicrosecondsSinceEpoch(
      reviewMicros,
      isUtc: true,
    );

    // Keep event IDs unique across bridge instances as well as across
    // repeated/rolled-back clock ticks. The isolate nonce covers restarts.
    final eventMicros = reviewMicros > _lastIssuedEventMicros
        ? reviewMicros
        : _lastIssuedEventMicros + 1;
    _lastIssuedEventMicros = eventMicros;

    final envelope = ReviewTransactionEnvelope(
      reviewEventId:
          'REV_${_isolateNonce}_${eventMicros}_${sourceIso}_${targetIso}_${contentKey}',
      learnerContentKey: contentKey,
      rating: canonicalRating,
      timestamp: timestamp,
      languagePairKey: '${sourceIso}_${targetIso}',
    );

    // The writer owns durable idempotency and the SRS/progress transaction.
    // Serialize only this directed pair/card so an older in-flight review
    // cannot overwrite a newer durable schedule. Other cards and reverse
    // directions proceed independently.
    final scope = (envelope.languagePairKey, envelope.learnerContentKey);
    final predecessor = _writeTails[scope];
    final turn = Completer<void>();
    _writeTails[scope] = turn.future;
    try {
      if (predecessor != null) await predecessor;
      // Never project or acknowledge a review before the durable write.
      await writer(envelope);
      await _scheduler.processReviewTransaction(envelope);
    } finally {
      if (identical(_writeTails[scope], turn.future)) {
        _writeTails.remove(scope);
      }
      // A failed write must release later submissions without propagating
      // its failure to their queue. The failed caller still sees its error.
      turn.complete();
    }
  }
}
