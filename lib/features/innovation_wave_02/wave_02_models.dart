class LateVerbExercise {
  final String promptClause;
  final List<String> verbOptions;
  final String correctVerb;
  final String explanation;

  const LateVerbExercise({
    required this.promptClause,
    required this.verbOptions,
    required this.correctVerb,
    required this.explanation,
  });
}

class CompoundWordPuzzle {
  final List<String> parts;
  final String combinedWord;
  final String gender;
  final String arabicMeaning;

  const CompoundWordPuzzle({
    required this.parts,
    required this.combinedWord,
    required this.gender,
    required this.arabicMeaning,
  });
}
