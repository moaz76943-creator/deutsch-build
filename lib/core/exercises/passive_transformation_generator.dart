enum PassiveExerciseCategory {
  vorgangspassiv,   // werden + Partizip II
  zustandspassiv,    // sein + Partizip II
  passiversatzSichLassen, // sich lassen + Infinitiv
  passiversatzSeinZu,     // sein + zu + Infinitiv
}

class PassiveExerciseItem {
  final String activeOrInputSentence;
  final PassiveExerciseCategory category;
  final String prompt;
  final String correctPassiveForm;
  final List<String> options;
  final String arabicTranslation;
  final String grammaticalRuleAr;

  const PassiveExerciseItem({
    required this.activeOrInputSentence,
    required this.category,
    required this.prompt,
    required this.correctPassiveForm,
    required this.options,
    required this.arabicTranslation,
    required this.grammaticalRuleAr,
  });
}

/// Offline exercise generator for German active-passive transformations and Passiversatz drills.
class PassiveTransformationExerciseGenerator {
  /// توليد تمرين تحويل إلى المبني للمجهول مع مشتتات تصريفية ذكية
  PassiveExerciseItem generate({
    required String activeSentence,
    required PassiveExerciseCategory category,
    required String correctPassiveForm,
    required List<String> plausibleDistractors,
    required String arabicTranslation,
    required String ruleAr,
  }) {
    final opts = <String>{correctPassiveForm};
    for (final d in plausibleDistractors) {
      if (opts.length >= 4) break;
      if (d.trim().isNotEmpty && d.trim().toLowerCase() != correctPassiveForm.toLowerCase()) {
        opts.add(d.trim());
      }
    }

    final shuffled = opts.toList()..shuffle();

    return PassiveExerciseItem(
      activeOrInputSentence: activeSentence,
      category: category,
      prompt: 'حول الجملة التالية إلى الصيغة المقابلة في المبني للمجهول:\n"$activeSentence"',
      correctPassiveForm: correctPassiveForm,
      options: List.unmodifiable(shuffled),
      arabicTranslation: arabicTranslation,
      grammaticalRuleAr: ruleAr,
    );
  }

  /// التحقق الفوري من إجابة المتعلم
  bool validateAnswer(String selectedForm, String correctForm) {
    return selectedForm.trim().toLowerCase() == correctForm.trim().toLowerCase();
  }
}
