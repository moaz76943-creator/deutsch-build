// مسار الملف: lib/core/gamification/domain_mastery_projection.dart

/// نموذج عرض إتقان المجال (Projection) كما حدده تقرير هندسة التحفيز.
/// لا يعتمد على التصفح، بل على نجاح الاسترجاع المتباعد (SRS).
class DomainMasteryProjection {
  final String domainId;
  final String sourceLanguageId;
  final String targetLanguageId;
  final int eligibleCardCount;   // إجمالي البطاقات المتاحة في المجال
  final int introducedCardCount; // البطاقات التي بدأ المستخدم بتعلمها
  final int recalledCardCount;   // البطاقات التي تذكرها بنجاح مؤخراً
  final int masteredCardCount;   // البطاقات التي تجاوزت فترات مراجعة طويلة (متقنة)
  final int dueCardCount;        // البطاقات المستحقة للمراجعة الآن
  final DateTime lastEvidenceUtc;// آخر نشاط حقيقي في هذا المجال
  final int masteryRevision;     // رقم المراجعة لضمان التزامن

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
  });

  /// حساب نسبة الإتقان الحقيقية للمجال (0.0 إلى 1.0)
  double get masteryPercentage {
    if (eligibleCardCount == 0) return 0.0;
    // الإتقان يعتمد على البطاقات المتقنة فعلياً مقارنة بإجمالي البطاقات
    return (masteredCardCount / eligibleCardCount).clamp(0.0, 1.0);
  }
  
  /// تقييم حالة شجرة الإتقان للمجال (مغلق، متاح، قيد التقدم، متقن)
  DomainMasteryState get masteryState {
    if (introducedCardCount == 0) return DomainMasteryState.available;
    if (masteredCardCount == eligibleCardCount && eligibleCardCount > 0) {
      return DomainMasteryState.mastered;
    }
    return DomainMasteryState.inProgress;
  }
}

enum DomainMasteryState {
  locked,      // يتطلب إنجاز مجالات سابقة
  available,   // متاح للبدء
  inProgress,  // قيد التعلم
  mastered     // تم إتقان جميع بطاقاته
}
