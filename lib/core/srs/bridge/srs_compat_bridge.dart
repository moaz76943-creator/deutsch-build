import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

class SrsCompatBridge {
  SrsCompatBridge({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  static final SrsCompatBridge instance = SrsCompatBridge();

  final UnifiedSrsScheduler _scheduler = UnifiedSrsScheduler.instance;
  final DateTime Function() _clock;

  // The compatibility journal deduplicates by reviewEventId. Millisecond
  // timestamps alone silently discard rapid reviews of the same card,
  // including reviews in opposite language directions. Use a monotonic
  // in-process microsecond identity even when the wall clock stalls or moves
  // backwards. This does not change persisted learner progress or SRS keys.
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
        sourceIso == targetIso) {
      throw ArgumentError('Invalid SRS content or directed pair');
    }
    // The legacy flashcard surface emits 4 for "correct", but canonical
    // ReviewRating is 0..3 (easy == 3). Never persist an invalid grade.
    final canonicalRating = rating == 4 ? 3 : rating;
    if (canonicalRating < 0 || canonicalRating > 3) {
      throw ArgumentError.value(rating, 'rating', 'Expected a grade from 0 to 4');
    }

    final timestamp = _clock().toUtc();
    final wallMicros = timestamp.microsecondsSinceEpoch;
    final eventMicros = wallMicros > _lastIssuedEventMicros
        ? wallMicros
        : _lastIssuedEventMicros + 1;
    _lastIssuedEventMicros = eventMicros;

    final envelope = ReviewTransactionEnvelope(
      reviewEventId:
          'REV_${eventMicros}_${sourceIso}_${targetIso}_${contentKey}',
      learnerContentKey: contentKey,
      rating: canonicalRating,
      timestamp: timestamp,
      languagePairKey: '${sourceIso}_${targetIso}',
    );

    await _scheduler.processReviewTransaction(envelope);
  }
}
