import 'dart:async';
import '../../srs_scheduler.dart';
import '../../progress/review_transaction_envelope.dart';

/// جسر توافق يمنع مسارات الظل ويوجه كافة المراجعات القديمة إلى السلطة المركزية
class SrsCompatBridge {
  static final SrsCompatBridge instance = SrsCompatBridge._internal();
  SrsCompatBridge._internal();

  final UnifiedSrsScheduler _scheduler = UnifiedSrsScheduler.instance;

  /// تسجيل مراجعة قادمة من شاشة قديمة وتوجيهها للمسار المركزي
  Future<void> recordReviewCompat({
    required String contentKey,
    required int rating, // 1: Hard, 2: Good, 3: Easy
    required String sourceIso,
    required String targetIso,
  }) async {
    final eventId = 'REV_${contentKey}_${DateTime.now().millisecondsSinceEpoch}';

    // تغليف المحاولة في غلاف المعاملة المركزي لمنع التكرار
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: eventId,
      learnerContentKey: contentKey,
      rating: rating,
      timestamp: DateTime.now().toUtc(),
      languagePairKey: '${sourceIso}_$targetIso',
    );

    // توجيه المحاولة للمجدول المركزي الموحد
    await _scheduler.processReviewTransaction(envelope);
  }
}
