class ModalparticleExerciseItem {
  final String dialogueSnippet;      // مثال: "Komm [___] her!"
  final String correctParticle;      // "mal"
  final String pragmaticToneAr;      // "تلطيف الأمر وإضفاء نبرة الود"
  final List<String> options;        // ['mal', 'denn', 'doch', 'halt']
  final String translationAr;
  final String pedagogicalRuleAr;

  const ModalparticleExerciseItem({
    required this.dialogueSnippet,
    required this.correctParticle,
    required this.pragmaticToneAr,
    required this.options,
    required this.translationAr,
    required this.pedagogicalRuleAr,
  });
}

/// Offline exercise generator for German pragmatic modal particles in natural conversational contexts.
class ModalpartikelnExerciseGenerator {
  static const List<String> standardParticles = ['ja', 'doch', 'mal', 'denn', 'halt', 'eben', 'wohl'];

  /// توليد تمرين سياقي لاختيار أداة الخطاب المناسبة للنبرة التداولية
  ModalparticleExerciseItem generate({
    required String dialogueSnippet,
    required String correctParticle,
    required String pragmaticToneAr,
    required String translationAr,
    required String pedagogicalRuleAr,
    List<String>? candidateDistractors,
  }) {
    final opts = <String>{correctParticle};
    final pool = candidateDistractors ?? standardParticles;

    for (final p in pool) {
      if (opts.length >= 4) break;
      if (p.toLowerCase() != correctParticle.toLowerCase()) {
        opts.add(p);
      }
    }

    final shuffled = opts.toList()..shuffle();

    return ModalparticleExerciseItem(
      dialogueSnippet: dialogueSnippet,
      correctParticle: correctParticle,
      pragmaticToneAr: pragmaticToneAr,
      options: List.unmodifiable(shuffled),
      translationAr: translationAr,
      pedagogicalRuleAr: pedagogicalRuleAr,
    );
  }

  /// التحقق الفوري من إجابة المتعلم
  bool validateAnswer(String selectedParticle, String correctParticle) {
    return selectedParticle.trim().toLowerCase() == correctParticle.trim().toLowerCase();
  }
}
