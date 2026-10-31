import 'dart:math' as math;

class ScrambledSentenceExercise {
  final String originalSentence;
  final String arabicTranslation;
  final List<String> scrambledTokens;
  final List<String> expectedSequence;
  final String cefrLevel;

  const ScrambledSentenceExercise({
    required this.originalSentence,
    required this.arabicTranslation,
    required this.scrambledTokens,
    required this.expectedSequence,
    required this.cefrLevel,
  });
}

/// Offline exercise generator creating interactive sentence-scramble puzzles.
class SentenceScrambleExerciseGenerator {
  /// Scrambles sentence tokens deterministically while ensuring the prompt is not accidentally in order.
  ScrambledSentenceExercise generate({
    required String germanSentence,
    required String arabicTranslation,
    required String cefrLevel,
    int? deterministicSeed,
  }) {
    // استخراج الكلمات كرموز منفصلة
    final tokens = germanSentence
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'[,.!?]'), '').trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final expectedSequence = List<String>.unmodifiable(tokens);
    final scrambled = List<String>.from(tokens);

    final rng = math.Random(deterministicSeed ?? germanSentence.hashCode);

    // خلط الكلمات مع التأكد من عدم بقائها بالترتيب الأصلي إذا كانت أكثر من كلمتين
    if (scrambled.length > 2) {
      int attempts = 0;
      do {
        scrambled.shuffle(rng);
        attempts++;
      } while (_isIdentical(scrambled, expectedSequence) && attempts < 10);
    }

    return ScrambledSentenceExercise(
      originalSentence: germanSentence,
      arabicTranslation: arabicTranslation,
      scrambledTokens: List.unmodifiable(scrambled),
      expectedSequence: expectedSequence,
      cefrLevel: cefrLevel,
    );
  }

  /// التحقق من صحة ترتيب المتعلم
  bool validateLearnerAnswer(List<String> learnerTokens, List<String> expectedSequence) {
    if (learnerTokens.length != expectedSequence.length) return false;
    for (int i = 0; i < expectedSequence.length; i++) {
      if (learnerTokens[i].toLowerCase() != expectedSequence[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  bool _isIdentical(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
