import '../../services/database_service.dart';
import '../srs_scheduler.dart';
import '../progress/review_transaction_envelope.dart';

/// هوية المراجعة والتقييم لضمان عدم ازدواجية احتساب النقاط (XP)
/// ولضمان ارتباطها بالزوج اللغوي الموجه الصحيح.
enum ReviewRating { again, hard, good, easy }

class ReviewCommand {
  final String reviewId;
  final String sourceLanguageId;
  final String targetLanguageId;
  final String cardId;
  final String facetKey;
  final int pairEpoch;
  final ReviewRating rating;
  final bool hinted;

  const ReviewCommand({
    required this.reviewId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.cardId,
    required this.facetKey,
    required this.pairEpoch,
    required this.rating,
    required this.hinted,
  });
}

abstract interface class ReviewCommandPort {
  /// ترسل أمر التقييم إلى UnifiedSrsScheduler
  /// ليتم تنفيذه عبر Persistent CPU Worker وتخزينه كـ Atomic Transaction.
  Future<void> submit(ReviewCommand command);
}

/// التنفيذ المعتمد لمنفذ أوامر التقييم:
/// يحقق المعالجة الذرية، ومنع التكرار (Idempotency)، وعزل الزوج اللغوي،
/// والتخزين الأحادي المعتمد في SQLite.
class UnifiedReviewCommandAdapter implements ReviewCommandPort {
  const UnifiedReviewCommandAdapter({DatabaseService? databaseService})
      : _databaseService = databaseService;

  final DatabaseService? _databaseService;

  DatabaseService get _db => _databaseService ?? DatabaseService.instance;

  static int ratingToGrade(ReviewRating rating) {
    switch (rating) {
      case ReviewRating.again:
        return 0;
      case ReviewRating.hard:
        return 2;
      case ReviewRating.good:
        return 3;
      case ReviewRating.easy:
        return 4;
    }
  }

  @override
  Future<void> submit(ReviewCommand command) async {
    final grade = ratingToGrade(command.rating);
    final now = DateTime.now().toUtc();

    // 1. معالجة الحدث عبر سجل المراجعات الموحد مع منع التكرار
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: grade,
      timestamp: now,
      languagePairKey: '${command.sourceLanguageId}_${command.targetLanguageId}',
    );
    await UnifiedSrsScheduler.instance.processReviewTransaction(envelope);

    // 2. الحفظ الذري كـ Single-writer في SQLite مع فحص المفتاح لمنع التكرار
    await _db.gradeAndPersistSrs(
      lexemeId: command.cardId,
      languageCode: command.targetLanguageId,
      grade: grade,
      reviewedAt: now,
      reviewEventId: command.reviewId,
    );
  }
}
