class RegisterLevel {
  final int level;
  final String phrase;
  final String context;

  const RegisterLevel({
    required this.level,
    required this.phrase,
    required this.context,
  });
}

class TOTWord {
  final String targetWord;
  final String visualStructure;
  final String rhymeHint;
  final String semanticHint;

  const TOTWord({
    required this.targetWord,
    required this.visualStructure,
    required this.rhymeHint,
    required this.semanticHint,
  });
}
