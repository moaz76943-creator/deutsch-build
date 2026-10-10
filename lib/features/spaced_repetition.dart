import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

/// واجهة توافق لمنع كسر الشاشات القائمة (مثل Flashcards)
/// مع توجيه الحفظ كلياً للسلطة المركزية بدلاً من SharedPreferences
class SpacedRepetitionService {
  static final SpacedRepetitionService instance = SpacedRepetitionService._internal();
  SpacedRepetitionService._internal();

  Future<void> submitResult({
    required String cardId,
    required bool isCorrect,
    int difficulty = 2,
  }) async {
    final rating = isCorrect ? (difficulty >= 3 ? 3 : 2) : 1;

    await SrsCompatBridge.instance.recordReviewCompat(
      contentKey: cardId,
      rating: rating,
      sourceIso: 'de',
      targetIso: 'ar',
    );
  }
}
