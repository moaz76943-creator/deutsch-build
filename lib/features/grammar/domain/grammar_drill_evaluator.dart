import 'grammar_drill_models.dart';

final class GrammarEvaluation {
  GrammarEvaluation({
    required this.correct,
    required this.score,
    required this.reasonCode,
    Map<String, String> reasonArguments = const <String, String>{},
  }) : reasonArguments =
            Map<String, String>.unmodifiable(reasonArguments);

  final bool correct;
  final int score;
  final String reasonCode;
  final Map<String, String> reasonArguments;
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
      return GrammarEvaluation(
        correct: false,
        score: 0,
        reasonCode: 'grammar.input.incomplete',
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
      reasonCode: exercise.reasonCode,
      reasonArguments: exercise.reasonArguments,
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
      reasonCode: exercise.reasonCode,
      reasonArguments: <String, String>{
        ...exercise.reasonArguments,
        'pronoun': exercise.pronoun,
        'infinitive': exercise.infinitive,
        'expected': exercise.expectedForm,
      },
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
      reasonCode: exercise.reasonCode,
      reasonArguments: <String, String>{
        ...exercise.reasonArguments,
        'caseLabel': exercise.targetCase.label,
        'noun': exercise.noun,
        'expected': exercise.expectedArticle,
      },
    );
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[.!?,;:،؛؟]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
