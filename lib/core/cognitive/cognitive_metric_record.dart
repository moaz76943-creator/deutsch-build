class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency;
  final int hesitationTaps;
  final bool isCorrect;
  final DateTime recordedAt;

  // Pass the exact directed-pair identity for newly generated records.
  // 'default' exists only for compatibility with older call sites.
  final String languagePair;
  final double reviewDifficulty;

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
    this.languagePair = 'default',
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

  /// Informal, local task-load estimate; NOT a CEFR score or certification.
  double get cognitiveStrainIndex {
    if (!isUsable) return 0.0;
    var strain = 0.0;
    final latency = responseLatency.inMilliseconds;
    if (latency > 5000) {
      strain += 0.4;
    } else if (latency > 3000) {
      strain += 0.2;
    }
    if (hesitationTaps > 1) strain += 0.3;
    if (!isCorrect) strain += 0.3;
    strain += reviewDifficulty * 0.2;
    return strain.clamp(0.0, 1.0).toDouble();
  }
}
