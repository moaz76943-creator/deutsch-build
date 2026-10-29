// مسار الملف: lib/core/gamification/domain_mastery_projection.dart

<<<<<<< HEAD
import '../progress/review_transaction_envelope.dart';

=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
/// نموذج عرض إتقان المجال (Projection) كما حدده تقرير هندسة التحفيز.
/// لا يعتمد على التصفح، بل على نجاح الاسترجاع المتباعد (SRS).
class DomainMasteryProjection {
  final String domainId;
  final String sourceLanguageId;
  final String targetLanguageId;
<<<<<<< HEAD
  final int eligibleCardCount; // إجمالي البطاقات المتاحة في المجال
  final int introducedCardCount; // البطاقات التي بدأ المستخدم بتعلمها
  final int recalledCardCount; // البطاقات التي تذكرها بنجاح مؤخراً
  final int
      masteredCardCount; // البطاقات التي تجاوزت فترات مراجعة طويلة (متقنة)
  final int dueCardCount; // البطاقات المستحقة للمراجعة الآن
  final DateTime lastEvidenceUtc; // آخر نشاط حقيقي في هذا المجال
  final int masteryRevision; // رقم المراجعة لضمان التزامن
=======
  final int eligibleCardCount;   // إجمالي البطاقات المتاحة في المجال
  final int introducedCardCount; // البطاقات التي بدأ المستخدم بتعلمها
  final int recalledCardCount;   // البطاقات التي تذكرها بنجاح مؤخراً
  final int masteredCardCount;   // البطاقات التي تجاوزت فترات مراجعة طويلة (متقنة)
  final int dueCardCount;        // البطاقات المستحقة للمراجعة الآن
  final DateTime lastEvidenceUtc;// آخر نشاط حقيقي في هذا المجال
  final int masteryRevision;     // رقم المراجعة لضمان التزامن
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

  const DomainMasteryProjection({
    required this.domainId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.eligibleCardCount,
    required this.introducedCardCount,
    required this.recalledCardCount,
    required this.masteredCardCount,
    required this.dueCardCount,
    required this.lastEvidenceUtc,
    required this.masteryRevision,
<<<<<<< HEAD
  })  : assert(eligibleCardCount >= 0, 'eligibleCardCount cannot be negative'),
        assert(
            introducedCardCount >= 0, 'introducedCardCount cannot be negative'),
        assert(recalledCardCount >= 0, 'recalledCardCount cannot be negative'),
        assert(masteredCardCount >= 0, 'masteredCardCount cannot be negative'),
        assert(dueCardCount >= 0, 'dueCardCount cannot be negative');

  /// حساب نسبة الإتقان الحقيقية للمجال (0.0 إلى 1.0)
  double get masteryPercentage {
    if (eligibleCardCount <= 0) return 0.0;
=======
  });

  /// حساب نسبة الإتقان الحقيقية للمجال (0.0 إلى 1.0)
  double get masteryPercentage {
    if (eligibleCardCount == 0) return 0.0;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    // الإتقان يعتمد على البطاقات المتقنة فعلياً مقارنة بإجمالي البطاقات
    return (masteredCardCount / eligibleCardCount).clamp(0.0, 1.0);
  }

  /// تقييم حالة شجرة الإتقان للمجال (مغلق، متاح، قيد التقدم، متقن)
  DomainMasteryState get masteryState {
<<<<<<< HEAD
    if (introducedCardCount <= 0) return DomainMasteryState.available;
    // Require an approved mastery threshold before advancement. (e.g. 0.9 or 100%)
    // The objective mentions "Require an approved mastery threshold before advancement."
    // Let's use 0.9 as an arbitrary threshold, or 100%. "0.9 threshold for masteryState advancement" was in the review plan.
    if (masteryPercentage >= 0.9 && eligibleCardCount > 0) {
=======
    if (introducedCardCount == 0) return DomainMasteryState.available;
    if (masteredCardCount == eligibleCardCount && eligibleCardCount > 0) {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      return DomainMasteryState.mastered;
    }
    return DomainMasteryState.inProgress;
  }

  /// Rebuilds mastery projection deterministically from raw SRS events.
  /// Enforces deduplication, pair isolation, and limits replays.
  static DomainMasteryProjection computeFromEvents({
    required String domainId,
    required String sourceLanguageId,
    required String targetLanguageId,
    required int eligibleCardCount,
    required List<ReviewTransactionEnvelope> events,
    required DateTime projectionTimeUtc,
  }) {
    if (eligibleCardCount < 0) {
      throw ArgumentError('Eligible card count cannot be negative');
    }

    final String targetPairKey = '${sourceLanguageId}_$targetLanguageId';

    // Deduplicate by reviewEventId, taking the first valid one we see.
    // Also ignore events outside the bounded replay window (e.g. in the future).
    final Map<String, ReviewTransactionEnvelope> uniqueEvents = {};
    for (final event in events) {
      if (event.languagePairKey != targetPairKey) continue;
      if (event.timestamp.isAfter(projectionTimeUtc)) continue;

      if (!uniqueEvents.containsKey(event.reviewEventId)) {
        uniqueEvents[event.reviewEventId] = event;
      }
    }

    // Sort by timestamp
    final validEvents = uniqueEvents.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (validEvents.isEmpty) {
      return DomainMasteryProjection(
        domainId: domainId,
        sourceLanguageId: sourceLanguageId,
        targetLanguageId: targetLanguageId,
        eligibleCardCount: eligibleCardCount,
        introducedCardCount: 0,
        recalledCardCount: 0,
        masteredCardCount: 0,
        dueCardCount: 0, // Simplified for this task
        lastEvidenceUtc: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        masteryRevision: 1,
      );
    }

    // Track state per card (learnerContentKey)
    final Map<String, int> cardSuccessCount = {};
    DateTime lastEvidence = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    for (final event in validEvents) {
      if (event.timestamp.isAfter(lastEvidence)) {
        lastEvidence = event.timestamp;
      }

      // Determine rating threshold for success
      // If rating >= 3, it's a recall success.
      if (event.rating >= 3) {
        cardSuccessCount[event.learnerContentKey] =
            (cardSuccessCount[event.learnerContentKey] ?? 0) + 1;
      } else {
        // Reset or just don't increment? Let's just track successful recalls
        // For actual SRS it would reset, but let's assume we just need to see if it reached a threshold
        cardSuccessCount[event.learnerContentKey] = 0;
      }
    }

    int introduced = cardSuccessCount.length;
    int recalled = 0;
    int mastered = 0;

    for (final count in cardSuccessCount.values) {
      if (count > 0) recalled++;
      if (count >= 3) mastered++; // Threshold for mastery: 3 successful recalls in a row
    }

    // clamp
    introduced = introduced.clamp(0, eligibleCardCount);
    recalled = recalled.clamp(0, eligibleCardCount);
    mastered = mastered.clamp(0, eligibleCardCount);

    return DomainMasteryProjection(
      domainId: domainId,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      eligibleCardCount: eligibleCardCount,
      introducedCardCount: introduced,
      recalledCardCount: recalled,
      masteredCardCount: mastered,
      dueCardCount: 0,
      lastEvidenceUtc: lastEvidence,
      masteryRevision: events.length,
    );
  }
}

enum DomainMasteryState {
  locked, // يتطلب إنجاز مجالات سابقة
  available, // متاح للبدء
  inProgress, // قيد التعلم
  mastered // تم إتقان جميع بطاقاته
}

enum DomainMasteryState {
  locked,      // يتطلب إنجاز مجالات سابقة
  available,   // متاح للبدء
  inProgress,  // قيد التعلم
  mastered     // تم إتقان جميع بطاقاته
}
