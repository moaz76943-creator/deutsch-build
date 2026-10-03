enum NvvRegister { everyday, formalWorkplace, academicOfficial }

final class NvvChallengeItem {
  const NvvChallengeItem({
    required this.id,
    required this.register,
    required this.nominalPart,
    required this.correctVerb,
    required this.simpleEquivalent,
    required this.arabicTranslation,
    required this.arabicUsageExplanation,
    required this.trainingSentence,
    this.preposition,
    this.caseHint,
  })  : assert(id.length > 0),
        assert(nominalPart.length > 0),
        assert(correctVerb.length > 0),
        assert(simpleEquivalent.length > 0),
        assert(arabicTranslation.length > 0),
        assert(arabicUsageExplanation.length > 0),
        assert(trainingSentence.length > 0),
        assert(
          (preposition == null && caseHint == null) ||
              (preposition != null && caseHint != null),
        );

  final String id;
  final NvvRegister register;

  /// Nominal element including its determiner where natural.
  final String nominalPart;

  /// Infinitive of the verb that forms the fixed collocation.
  final String correctVerb;

  /// A simpler lexical equivalent, e.g. "entscheiden".
  final String simpleEquivalent;

  /// Optional governed preposition, e.g. "auf".
  final String? preposition;

  /// Case governed by [preposition], e.g. "Akkusativ" or "Dativ".
  final String? caseHint;

  final String arabicTranslation;
  final String arabicUsageExplanation;

  /// Realistic sentence containing "___" as the answer slot.
  final String trainingSentence;

  String? get grammarHint {
    final prep = preposition;
    final grammaticalCase = caseHint;
    if (prep == null || grammaticalCase == null) return null;
    return '$prep + $grammaticalCase';
  }
}
