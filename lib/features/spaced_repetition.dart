import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';

/// Spaced Repetition Service with Dynamic Polyglot 100-Language Pair Support (10/10)
class SpacedRepetitionService {
  static final SpacedRepetitionService instance =
      SpacedRepetitionService._internal();
  SpacedRepetitionService._internal();

  Future<void> submitResult({
    required String cardId,
    required bool isCorrect,
    int difficulty = 2,
    String sourceIso = "de",
    String targetIso = "ar",
  }) async {
    final rating = isCorrect ? (difficulty >= 3 ? 3 : 2) : 1;

    await SrsCompatBridge.instance.recordReviewCompat(
      contentKey: cardId,
      rating: rating,
      sourceIso: sourceIso,
      targetIso: targetIso,
    );
  }
}
