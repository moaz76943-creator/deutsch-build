class FvgExerciseItem {
  final String sentenceWithBlank;     // مثال: "Wir müssen heute eine Entscheidung [___]."
  final String nounPhrase;            // "eine Entscheidung"
  final String correctFunctionVerb;   // "treffen"
  final String simpleVerbEquivalent;  // "entscheiden"
  final List<String> verbOptions;     // ['treffen', 'machen', 'nehmen', 'stellen']
  final String translationAr;
  final String explanationAr;

  const FvgExerciseItem({
    required this.sentenceWithBlank,
    required this.nounPhrase,
    required this.correctFunctionVerb,
    required this.simpleVerbEquivalent,
    required this.verbOptions,
    required this.translationAr,
    required this.explanationAr,
  });
}

/// Offline exercise generator for German noun-verb collocations (Funktionsverbgefüge drills).
class FvgCollocationExerciseGenerator {
  static const List<String> commonFvgVerbs = [
    'treffen', 'stellen', 'stehen', 'nehmen', 'bringen', 'führen', 'üben', 'kommen'
  ];

  /// توليد تمرين متلازمة FVG مع مشتتات لأفعال وظيفية شائعة
  FvgExerciseItem generate({
    required String prefixContext,
    required String nounPhrase,
    required String suffixContext,
    required String correctFunctionVerb,
    required String simpleVerbEquivalent,
    required String translationAr,
    required String explanationAr,
    List<String>? plausibleDistractors,
  }) {
    final sentenceWithBlank = '$prefixContext $nounPhrase [___] $suffixContext'.trim();

    final opts = <String>{correctFunctionVerb};
    final candidates = plausibleDistractors ?? commonFvgVerbs;

    for (final v in candidates) {
      if (opts.length >= 4) break;
      if (v.toLowerCase() != correctFunctionVerb.toLowerCase()) {
        opts.add(v);
      }
    }

    final shuffled = opts.toList()..shuffle();

    return FvgExerciseItem(
      sentenceWithBlank: sentenceWithBlank,
      nounPhrase: nounPhrase,
      correctFunctionVerb: correctFunctionVerb,
      simpleVerbEquivalent: simpleVerbEquivalent,
      verbOptions: List.unmodifiable(shuffled),
      translationAr: translationAr,
      explanationAr: explanationAr,
    );
  }

  /// التحقق الفوري من إجابة المتعلم
  bool validateAnswer(String selectedVerb, String correctFunctionVerb) {
    return selectedVerb.trim().toLowerCase() == correctFunctionVerb.trim().toLowerCase();
  }
}
