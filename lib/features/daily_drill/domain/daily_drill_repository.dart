import '../../../core/content_contract.dart';
import '../../../models/learner.dart';
import 'daily_drill_models.dart';

abstract interface class DailyDrillRepository {
  List<FlashcardReviewItem> dueReviews({
    required LearnerState state,
    required Iterable<LearningContent> corpus,
    required DateTime now,
    int limit = 10,
  });
}

abstract interface class DailyDrillReviewSink {
  Future<DailyDrillReviewReceipt> record({
    required LearningContent item,
    required bool correct,
    required int seconds,
  });
}
