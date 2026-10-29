class ClozeExerciseItem {
  final String sentenceWithBlank; // مثال: "Ich trinke einen kalt___ Kaffee."
  final String targetRoot;        // kalt
  final String correctEnding;     // en
  final List<String> endingOptions; // ['e', 'en', 'er', 'es']
  final String translationAr;
  final String ruleHint;

  const ClozeExerciseItem({
    required this.sentenceWithBlank,
    required this.targetRoot,
    required this.correctEnding,
    required this.endingOptions,
    required this.translationAr,
    required this.ruleHint,
  });
}

/// Offline exercise generator for grammar inflections (Adjective & N-Declension cloze tests).
class ClozeTestGenerator {
  static const List<String> standardAdjectiveEndings = ['e', 'en', 'er', 'es', 'em'];

  /// توليد تمرين ملء فراغ لنهايات الصفات
  ClozeExerciseItem generateAdjectiveCloze({
    required String prefixContext,
    required String baseAdjective,
    required String suffixContext,
    required String correctEnding,
    required String arabicTranslation,
    required String grammarHint,
  }) {
    final sentenceWithBlank = '$prefixContext $baseAdjective[___] $suffixContext';
    
    // إعداد الخيارات لتشمل الإجابة الصحيحة ومشتتات من نهايات الصفات القياسية
    final options = <String>{correctEnding};
    for (final ending in standardAdjectiveEndings) {
      if (options.length >= 4) break;
      options.add(ending);
    }

    final shuffledOptions = options.toList()..shuffle();

    return ClozeExerciseItem(
      sentenceWithBlank: sentenceWithBlank,
      targetRoot: baseAdjective,
      correctEnding: correctEnding,
      endingOptions: List.unmodifiable(shuffledOptions),
      translationAr: arabicTranslation,
      ruleHint: grammarHint,
    );
  }

  /// التحقق من إجابة المتعلم
  bool validateAnswer(String selectedEnding, String correctEnding) {
    return selectedEnding.trim().toLowerCase() == correctEnding.trim().toLowerCase();
  }
}
