/// Session-local cognitive signals, not evidence of certified CEFR proficiency.
class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency;
  final int hesitationTaps;
  final bool isCorrect;
  final DateTime recordedAt;
  final String languagePair;
  final String? cefrLevel;
  final bool isCefrVerified;
  final double reviewDifficulty;

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
    this.languagePair = 'default',
    this.cefrLevel,
    this.isCefrVerified = false,
    this.reviewDifficulty = 0.0,
  });

  bool get isUsable =>
      sessionEventId.trim().isNotEmpty &&
      contentKey.trim().isNotEmpty &&
      languagePair.trim().isNotEmpty &&
      !responseLatency.isNegative &&
      hesitationTaps >= 0 &&
      reviewDifficulty.isFinite &&
      reviewDifficulty >= 0.0 &&
      reviewDifficulty <= 1.0;

  double get cognitiveStrainIndex {
    if (responseLatency.isNegative) return 1.0;
    if (!isUsable) return 0.0;
    final latency = responseLatency.inMilliseconds;
    var strain = latency > 5000 ? 0.4 : (latency > 3000 ? 0.2 : 0.0);
    if (hesitationTaps > 1) strain += 0.3;
    if (!isCorrect) strain += 0.3;
    final difficulty = reviewDifficulty.isFinite
        ? reviewDifficulty.clamp(0.0, 1.0).toDouble()
        : 0.0;
    return (strain + difficulty * 0.2).clamp(0.0, 1.0).toDouble();
  }
}
