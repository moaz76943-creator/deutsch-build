import 'dart:math' as math;

class McqOptionItem {
  final String text;
  final bool isCorrect;

  const McqOptionItem({required this.text, required this.isCorrect});
}

class MultipleChoiceQuestion {
  final String prompt;
  final String correctMeaning;
  final List<String> options;
  final int correctIndex;
  final String pos;
  final String cefrLevel;

  const MultipleChoiceQuestion({
    required this.prompt,
    required this.correctMeaning,
    required this.options,
    required this.correctIndex,
    required this.pos,
    required this.cefrLevel,
  });
}

/// Offline exercise generator synthesizing smart multiple-choice items with semantic co-hyponym distractors.
class MultipleChoiceExerciseGenerator {
  /// Generates a 4-option multiple-choice question with POS-matched distractors.
  MultipleChoiceQuestion generate({
    required String lemma,
    required String correctMeaning,
    required String pos,
    required String cefrLevel,
    required List<String> candidateDistractors,
    int? deterministicSeed,
  }) {
    // 1. تصفية المشتتات لاستبعاد المعنى الصحيح وأي مدخلات فارغة
    final validDistractors = candidateDistractors
        .where((d) => d.trim().isNotEmpty && d.trim().toLowerCase() != correctMeaning.trim().toLowerCase())
        .toSet()
        .toList();

    // اختيار 3 مشتتات ذكية أو استخدام بدائل احتياطية
    final rng = math.Random(deterministicSeed ?? lemma.hashCode);
    validDistractors.shuffle(rng);

    final selectedDistractors = validDistractors.take(3).toList();
    while (selectedDistractors.length < 3) {
      selectedDistractors.add('خيار بديل ${selectedDistractors.length + 1}');
    }

    // 2. دمج الخيارات الأربعة وخلطها حتمياً
    final allOptions = [correctMeaning, ...selectedDistractors];
    allOptions.shuffle(rng);

    final correctIdx = allOptions.indexOf(correctMeaning);

    return MultipleChoiceQuestion(
      prompt: 'ما المعنى الصحيح لكلمة "$lemma"؟',
      correctMeaning: correctMeaning,
      options: List.unmodifiable(allOptions),
      correctIndex: correctIdx,
      pos: pos,
      cefrLevel: cefrLevel,
    );
  }
}
