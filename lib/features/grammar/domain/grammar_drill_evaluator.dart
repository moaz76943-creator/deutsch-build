import 'grammar_drill_models.dart';

final class GrammarEvaluation {
  final bool correct;
  final int score;
  final String feedbackAr;

  const GrammarEvaluation({
    required this.correct,
    required this.score,
    required this.feedbackAr,
  });
}

final class GrammarDrillEvaluator {
  const GrammarDrillEvaluator();

  GrammarEvaluation evaluate(GrammarDrill drill, Object answer) {
    return switch (drill) {
      SentenceReorderExercise exercise => _evaluateSentence(exercise, answer),
      VerbConjugationDrill exercise => _evaluateVerb(exercise, answer),
      CaseSelectionDrill exercise => _evaluateCase(exercise, answer),
    };
  }

  GrammarEvaluation _evaluateSentence(
    SentenceReorderExercise exercise,
    Object answer,
  ) {
    if (answer is! List<String>) {
      return const GrammarEvaluation(
        correct: false,
        score: 0,
        feedbackAr: 'رتّب جميع الكلمات أولًا ثم تحقّق من الجملة.',
      );
    }
    final expected = exercise.correctTokenIds;
    final correct = answer.length == expected.length &&
        List.generate(
          expected.length,
          (index) => answer[index] == expected[index],
        ).every((value) => value);

    return GrammarEvaluation(
      correct: correct,
      score: correct ? 100 : 0,
      feedbackAr: correct
          ? exercise.reinforcementAr
          : 'راجع ترتيب الجملة، وخصوصًا موقع الفعل وبداية الجملة.',
    );
  }

  GrammarEvaluation _evaluateVerb(
    VerbConjugationDrill exercise,
    Object answer,
  ) {
    final normalized = _normalize(answer.toString());
    final accepted = <String>{
      _normalize(exercise.expectedForm),
      ...exercise.acceptedForms.map(_normalize),
    };
    final correct = accepted.contains(normalized);

    return GrammarEvaluation(
      correct: correct,
      score: correct ? 100 : 0,
      feedbackAr: correct
          ? exercise.reinforcementAr
          : 'راجع التصريف مع الضمير ${exercise.pronoun}: '
              '${exercise.infinitive} → ${exercise.expectedForm}.',
    );
  }

  GrammarEvaluation _evaluateCase(
    CaseSelectionDrill exercise,
    Object answer,
  ) {
    final correct =
        _normalize(answer.toString()) == _normalize(exercise.expectedArticle);
    return GrammarEvaluation(
      correct: correct,
      score: correct ? 100 : 0,
      feedbackAr:
          correct ? exercise.reinforcementAr : exercise.explanationAr,
    );
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[.!?,;:،؛؟]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
