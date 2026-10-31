enum CefrLevel { A1, A2, B1, B2, C1, C2 }

class CefrComplexityMetrics {
  final CefrLevel estimatedLevel;
  final double readabilityScore; // 0.0 (الأسهل A1) إلى 100.0 (الأصعب C1/C2)
  final int wordCount;
  final double averageWordLength;
  final List<String> advancedSyntacticMarkers;

  const CefrComplexityMetrics({
    required this.estimatedLevel,
    required this.readabilityScore,
    required this.wordCount,
    required this.averageWordLength,
    required this.advancedSyntacticMarkers,
  });
}

/// Offline linguistic engine calculating text difficulty and CEFR classification using heuristic and readability metrics.
class CefrDifficultyCalculatorEngine {
  // مؤشرات نحوية متقدمة تدل على مستوى B2-C1
  static const Map<String, CefrLevel> _syntacticClues = {
    'wäre': CefrLevel.B1,
    'hätte': CefrLevel.B1,
    'würde': CefrLevel.B1,
    'könnte': CefrLevel.B1,
    'obwohl': CefrLevel.B1,
    'trotzdem': CefrLevel.B1,
    'dessen': CefrLevel.B2,
    'deren': CefrLevel.B2,
    'denen': CefrLevel.B2,
    'infolgedessen': CefrLevel.C1,
    'demzufolge': CefrLevel.C1,
    'gewährleistet': CefrLevel.B2,
    'berücksichtigt': CefrLevel.B2,
  };

  /// حساب تقييم مستوى الصعوبة للنص الألماني
  CefrComplexityMetrics analyze(String text) {
    final tokens = text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) {
      return const CefrComplexityMetrics(
        estimatedLevel: CefrLevel.A1,
        readabilityScore: 0.0,
        wordCount: 0,
        averageWordLength: 0.0,
        advancedSyntacticMarkers: [],
      );
    }

    int totalChars = 0;
    int multiSyllableWords = 0;
    final detectedMarkers = <String>[];
    CefrLevel highestMarkerLevel = CefrLevel.A1;

    for (final token in tokens) {
      final clean = token.replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜß]'), '').toLowerCase();
      totalChars += clean.length;

      // الكلمات الطويلة (> 7 أحرف) تعكس كلمات مركبة أو متقدمة
      if (clean.length >= 7) multiSyllableWords++;

      if (_syntacticClues.containsKey(clean)) {
        detectedMarkers.add(token);
        final level = _syntacticClues[clean]!;
        if (level.index > highestMarkerLevel.index) {
          highestMarkerLevel = level;
        }
      }
    }

    final avgWordLen = totalChars / tokens.length;
    final wordCount = tokens.length;

    // حساب درجة التعقيد الهجينة (توليف من Wiener Sachtextformel ومؤشرات النحو)
    double score = (avgWordLen * 6.0) + (multiSyllableWords / tokens.length * 40.0);
    if (wordCount > 15) score += 15.0;
    score += (highestMarkerLevel.index * 12.0);

    if (score > 100.0) score = 100.0;

    // تعيين المستوى بناءً على النتيجة الإجمالية والمؤشرات المكتشفة
    CefrLevel finalLevel;
    if (score < 28.0) {
      finalLevel = CefrLevel.A1;
    } else if (score < 45.0) {
      finalLevel = CefrLevel.A2;
    } else if (score < 65.0) {
      finalLevel = CefrLevel.B1;
    } else if (score < 82.0) {
      finalLevel = CefrLevel.B2;
    } else {
      finalLevel = CefrLevel.C1;
    }

    // لا يمكن أن يكون المستوى أقل من أعلى مؤشر نحوي قطعي تم رصده
    if (highestMarkerLevel.index > finalLevel.index) {
      finalLevel = highestMarkerLevel;
    }

    return CefrComplexityMetrics(
      estimatedLevel: finalLevel,
      readabilityScore: double.parse(score.toStringAsFixed(1)),
      wordCount: wordCount,
      averageWordLength: double.parse(avgWordLen.toStringAsFixed(1)),
      advancedSyntacticMarkers: detectedMarkers,
    );
  }
}
