import 'dart:math';

/// Pronunciation proficiency grade for individual phonemes.
enum PhonemeGrade {
  excellent,  // Score >= 85 (Green)
  good,       // Score 70 - 84 (Teal)
  acceptable, // Score 50 - 69 (Yellow)
  poor,       // Score < 50 (Red - requires drill)
}

/// Evaluation score for a single phoneme segment.
class PhonemeScore {
  final String phoneme;
  final double score; // 0.0 to 100.0
  final PhonemeGrade grade;

  const PhonemeScore({
    required this.phoneme,
    required this.score,
    required this.grade,
  });
}

/// Comprehensive pronunciation assessment report for a word or sentence.
class PronunciationReport {
  final String targetWord;
  final double overallScore;
  final List<PhonemeScore> phonemeScores;
  final bool isPass;

  const PronunciationReport({
    required this.targetWord,
    required this.overallScore,
    required this.phonemeScores,
    required this.isPass,
  });
}

/// Calculates Goodness of Pronunciation (GoP) scores based on acoustic feature divergence.
class GopPronunciationScorer {
  const GopPronunciationScorer();

  /// Computes GoP score comparing learner acoustic distance against phoneme model.
  PronunciationReport evaluate({
    required String targetWord,
    required List<String> expectedPhonemes,
    required List<double> acousticDistances,
  }) {
    final List<PhonemeScore> scores = [];
    double total = 0.0;

    for (int i = 0; i < expectedPhonemes.length; i++) {
      final distance = (i < acousticDistances.length) ? acousticDistances[i] : 1.0;
      // GoP transformation: Lower distance yields higher accuracy score
      final double normalizedScore = (100.0 * exp(-distance * 1.5)).clamp(0.0, 100.0);

      PhonemeGrade grade;
      if (normalizedScore >= 85) {
        grade = PhonemeGrade.excellent;
      } else if (normalizedScore >= 70) {
        grade = PhonemeGrade.good;
      } else if (normalizedScore >= 50) {
        grade = PhonemeGrade.acceptable;
      } else {
        grade = PhonemeGrade.poor;
      }

      scores.add(PhonemeScore(
        phoneme: expectedPhonemes[i],
        score: double.parse(normalizedScore.toStringAsFixed(1)),
        grade: grade,
      ));
      total += normalizedScore;
    }

    final double avg = expectedPhonemes.isNotEmpty ? total / expectedPhonemes.length : 0.0;

    return PronunciationReport(
      targetWord: targetWord,
      overallScore: double.parse(avg.toStringAsFixed(1)),
      phonemeScores: scores,
      isPass: avg >= 65.0,
    );
  }
}
