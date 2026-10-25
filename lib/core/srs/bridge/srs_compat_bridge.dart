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
      rating: rating,
      timestamp: timestamp,
      languagePairKey: '${sourceIso}_${targetIso}',
    );

    await _scheduler.processReviewTransaction(envelope);
  }
}
