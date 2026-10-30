enum GrammarErrorType {
  subjectVerbAgreement,
  subordinateClauseWordOrder,
  caseGenderMismatch,
  modalVerbBracket,
}

class GrammarCorrection {
  final GrammarErrorType errorType;
  final String originalSegment;
  final String correctedSegment;
  final String correctedFullSentence;
  final String ruleExplanation;
  final double confidence;

  const GrammarCorrection({
    required this.errorType,
    required this.originalSegment,
    required this.correctedSegment,
    required this.correctedFullSentence,
    required this.ruleExplanation,
    this.confidence = 0.95,
  });

  Map<String, dynamic> toJson() => {
    'errorType': errorType.name,
    'originalSegment': originalSegment,
    'correctedSegment': correctedSegment,
    'correctedFullSentence': correctedFullSentence,
    'ruleExplanation': ruleExplanation,
    'confidence': confidence,
  };
}

class GrammaticalErrorCorrectionEngine {
  const GrammaticalErrorCorrectionEngine();

  /// Analyzes an utterance for core grammatical errors in real time.
  List<GrammarCorrection> analyzeSentence(String sentence) {
    final corrections = <GrammarCorrection>[];
    final trimmed = sentence.trim();

    // 1. Subordinate clause verb position (weil / dass / wenn)
    // Error pattern: "weil ich gehe nach Hause" -> Correct: "weil ich nach Hause gehe"
    final weilRegex = RegExp(r'\b(weil|dass|obwohl|wenn)\s+([a-zA-ZäöüÄÖÜß]+)\s+([a-zA-ZäöüÄÖÜß]+)\s+([a-zA-ZäöüÄÖÜß\s]+)', caseSensitive: false);
    final match = weilRegex.firstMatch(trimmed);
    if (match != null) {
      final conjunction = match.group(1)!;
      final subject = match.group(2)!;
      final verb = match.group(3)!;
      final remainder = match.group(4)!.trim();

      // If verb appears immediately after subject instead of at the end of clause
      if (_isCommonFiniteVerb(verb) && remainder.isNotEmpty && !remainder.endsWith(verb)) {
        final correctedClause = '$conjunction $subject $remainder $verb';
        final fullCorrected = trimmed.replaceRange(match.start, match.end, correctedClause);
        corrections.add(GrammarCorrection(
          errorType: GrammarErrorType.subordinateClauseWordOrder,
          originalSegment: match.group(0)!,
          correctedSegment: correctedClause,
          correctedFullSentence: fullCorrected,
          ruleExplanation: 'In subordinate clauses introduced by "$conjunction", the finite verb must go to the very end.',
        ));
      }
    }

    // 2. Direct Subject-Verb Agreement check
    if (RegExp(r'\bich\s+geht\b', caseSensitive: false).hasMatch(trimmed)) {
      corrections.add(GrammarCorrection(
        errorType: GrammarErrorType.subjectVerbAgreement,
        originalSegment: 'ich geht',
        correctedSegment: 'ich gehe',
        correctedFullSentence: trimmed.replaceAll(RegExp(r'\bich\s+geht\b', caseSensitive: false), 'ich gehe'),
        ruleExplanation: 'First-person singular ("ich") takes "-e" ending: "ich gehe".',
      ));
    } else if (RegExp(r'\bdu\s+geht\b', caseSensitive: false).hasMatch(trimmed)) {
      corrections.add(GrammarCorrection(
        errorType: GrammarErrorType.subjectVerbAgreement,
        originalSegment: 'du geht',
        correctedSegment: 'du gehst',
        correctedFullSentence: trimmed.replaceAll(RegExp(r'\bdu\s+geht\b', caseSensitive: false), 'du gehst'),
        ruleExplanation: 'Second-person singular ("du") takes "-st" ending: "du gehst".',
      ));
    }

    // 3. Masculine Akkusativ case check: "Ich sehe der Mann" -> "Ich sehe den Mann"
    if (RegExp(r'\b(sehe|brauche|kaufe|habe)\s+der\b', caseSensitive: false).hasMatch(trimmed)) {
      corrections.add(GrammarCorrection(
        errorType: GrammarErrorType.caseGenderMismatch,
        originalSegment: 'der',
        correctedSegment: 'den',
        correctedFullSentence: trimmed.replaceAll(RegExp(r'\bder\b', caseSensitive: false), 'den'),
        ruleExplanation: 'Direct objects in the masculine accusative take "den" instead of "der".',
      ));
    }

    return corrections;
  }

  bool _isCommonFiniteVerb(String word) {
    const commonVerbs = {'gehe', 'bin', 'habe', 'fahre', 'esse', 'trinke', 'mag', 'kann', 'muss', 'will'};
    return commonVerbs.contains(word.toLowerCase());
  }
}
