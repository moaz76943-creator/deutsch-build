import 'dart:async';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

class SrsCompatBridge {
  static final SrsCompatBridge instance = SrsCompatBridge._internal();
  SrsCompatBridge._internal();

  final UnifiedSrsScheduler _scheduler = UnifiedSrsScheduler.instance;

  Future<void> recordReviewCompat({
    required String contentKey,
    required int rating,
    required String sourceIso,
    required String targetIso,
  }) async {
    final eventId = 'REV_${contentKey}_${DateTime.now().millisecondsSinceEpoch}';

    final envelope = ReviewTransactionEnvelope(
      reviewEventId: eventId,
      learnerContentKey: contentKey,
      rating: rating,
      timestamp: DateTime.now().toUtc(),
      languagePairKey: '${sourceIso}_$targetIso',
    );

    await _scheduler.processReviewTransaction(envelope);
  }
}
