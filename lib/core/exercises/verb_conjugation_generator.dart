enum TenseExerciseMode { present, perfekt, konjunktiv2 }

class VerbConjugationExercise {
  final String infinitiv;
  final String pronoun;
  final TenseExerciseMode mode;
  final String prompt;
  final String correctForm;
  final List<String> options;
  final String grammarExplanationAr;

  const VerbConjugationExercise({
    required this.infinitiv,
    required this.pronoun,
    required this.mode,
    required this.prompt,
    required this.correctForm,
    required this.options,
    required this.grammarExplanationAr,
  });
}

/// Offline exercise generator for German verb conjugations across tenses and moods.
class VerbConjugationExerciseGenerator {
  /// توليد تمرين تصريف أفعال تفاعلي مع 4 خيارات تتضمن أخطاء تصريفية شائعة كمشتتات
  VerbConjugationExercise generate({
    required String infinitiv,
    required String pronoun,
    required TenseExerciseMode mode,
    required String correctForm,
    required List<String> plausibleDistractors,
    required String explanationAr,
  }) {
    final opts = <String>{correctForm};
    for (final d in plausibleDistractors) {
      if (opts.length >= 4) break;
      if (d.trim().isNotEmpty && d.trim().toLowerCase() != correctForm.toLowerCase()) {
        opts.add(d.trim());
      }
    }

    final shuffled = opts.toList()..shuffle();

    String modeTitle = 'المضارع (Präsens)';
    if (mode == TenseExerciseMode.perfekt) modeTitle = 'الماضي التام (Perfekt)';
    if (mode == TenseExerciseMode.konjunktiv2) modeTitle = 'صيغة الاحتمال والتمني (Konjunktiv II)';

    return VerbConjugationExercise(
      infinitiv: infinitiv,
      pronoun: pronoun,
      mode: mode,
      prompt: 'اختر التصريف الصحيح للفعل "$infinitiv" مع الضمير ($pronoun) في $modeTitle:',
      correctForm: correctForm,
      options: List.unmodifiable(shuffled),
      grammarExplanationAr: explanationAr,
    );
  }

  /// التحقق الفوري من صحة إجابة المتعلم
  bool validateAnswer(String selectedOption, String correctForm) {
    return selectedOption.trim().toLowerCase() == correctForm.trim().toLowerCase();
  }
}
