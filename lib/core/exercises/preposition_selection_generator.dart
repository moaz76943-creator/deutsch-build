class PrepositionExerciseItem {
  final String sentenceWithBlank; // مثال: "Ich warte [___] den Bus."
  final String verb;              // warten
  final String correctPreposition;// auf
  final String requiredCase;      // Akkusativ
  final List<String> options;     // ['auf', 'an', 'für', 'über']
  final String translationAr;
  final String grammarExplanationAr;

  const PrepositionExerciseItem({
    required this.sentenceWithBlank,
    required this.verb,
    required this.correctPreposition,
    required this.requiredCase,
    required this.options,
    required this.translationAr,
    required this.grammarExplanationAr,
  });
}

/// Offline exercise generator for German verb-preposition valency drills.
class PrepositionSelectionExerciseGenerator {
  static const List<String> commonDistractorPrepositions = [
    'an', 'auf', 'für', 'über', 'von', 'zu', 'mit', 'in', 'nach'
  ];

  /// توليد تمرين تفاعلي لاختيار حرف الجر الملائم للفعل
  PrepositionExerciseItem generate({
    required String prefixContext,
    required String verb,
    required String suffixContext,
    required String correctPreposition,
    required String requiredCase,
    required String arabicTranslation,
    required String explanationAr,
    List<String>? customDistractors,
  }) {
    final sentenceWithBlank = '$prefixContext [___] $suffixContext';

    final opts = <String>{correctPreposition};
    final candidates = customDistractors ?? commonDistractorPrepositions;

    for (final p in candidates) {
      if (opts.length >= 4) break;
      if (p.toLowerCase() != correctPreposition.toLowerCase()) {
        opts.add(p);
      }
    }

    final shuffled = opts.toList()..shuffle();

    return PrepositionExerciseItem(
      sentenceWithBlank: sentenceWithBlank,
      verb: verb,
      correctPreposition: correctPreposition,
      requiredCase: requiredCase,
      options: List.unmodifiable(shuffled),
      translationAr: arabicTranslation,
      grammarExplanationAr: explanationAr,
    );
  }

  /// التحقق الفوري من إجابة المتعلم
  bool validateAnswer(String selectedPreposition, String correctPreposition) {
    return selectedPreposition.trim().toLowerCase() == correctPreposition.trim().toLowerCase();
  }
}
