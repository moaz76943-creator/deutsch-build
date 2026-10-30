/// Grammatical case in four-case inflected languages (e.g. German).
enum GrammaticalCase { nominative, accusative, dative, genitive }
enum GrammaticalGender { masculine, feminine, neuter, plural }

/// Verification of determiner-adjective-noun agreement.
class NounPhraseAgreementReport {
  final bool isValid;
  final String rawPhrase;
  final GrammaticalCase targetCase;
  final GrammaticalGender targetGender;
  final String correctedPhrase;
  final String errorExplanation;

  const NounPhraseAgreementReport({
    required this.isValid,
    required this.rawPhrase,
    required this.targetCase,
    required this.targetGender,
    required this.correctedPhrase,
    required this.errorExplanation,
  });
}

/// Guards against case-ending errors across definite and indefinite German determiners.
class CaseAgreementConformanceGuard {
  /// Validates a Determiner + Adjective + Noun phrase.
  NounPhraseAgreementReport validateDefiniteNounPhrase({
    required String article,
    required String adjective,
    required String noun,
    required GrammaticalCase expectedCase,
    required GrammaticalGender expectedGender,
  }) {
    final art = article.trim().toLowerCase();
    final adj = adjective.trim().toLowerCase();
    final raw = '$article $adjective $noun';

    String correctArt;
    String correctAdjEnding;

    // Standard German weak declension table after definite article (der/die/das)
    switch (expectedCase) {
      case GrammaticalCase.nominative:
        switch (expectedGender) {
          case GrammaticalGender.masculine:
            correctArt = 'der';
            correctAdjEnding = 'e';
            break;
          case GrammaticalGender.feminine:
            correctArt = 'die';
            correctAdjEnding = 'e';
            break;
          case GrammaticalGender.neuter:
            correctArt = 'das';
            correctAdjEnding = 'e';
            break;
          case GrammaticalGender.plural:
            correctArt = 'die';
            correctAdjEnding = 'en';
            break;
        }
        break;
      case GrammaticalCase.accusative:
        switch (expectedGender) {
          case GrammaticalGender.masculine:
            correctArt = 'den';
            correctAdjEnding = 'en';
            break;
          case GrammaticalGender.feminine:
            correctArt = 'die';
            correctAdjEnding = 'e';
            break;
          case GrammaticalGender.neuter:
            correctArt = 'das';
            correctAdjEnding = 'e';
            break;
          case GrammaticalGender.plural:
            correctArt = 'die';
            correctAdjEnding = 'en';
            break;
        }
        break;
      case GrammaticalCase.dative:
        switch (expectedGender) {
          case GrammaticalGender.masculine:
          case GrammaticalGender.neuter:
            correctArt = 'dem';
            correctAdjEnding = 'en';
            break;
          case GrammaticalGender.feminine:
            correctArt = 'der';
            correctAdjEnding = 'en';
            break;
          case GrammaticalGender.plural:
            correctArt = 'den';
            correctAdjEnding = 'en';
            break;
        }
        break;
      case GrammaticalCase.genitive:
        switch (expectedGender) {
          case GrammaticalGender.masculine:
          case GrammaticalGender.neuter:
            correctArt = 'des';
            correctAdjEnding = 'en';
            break;
          case GrammaticalGender.feminine:
          case GrammaticalGender.plural:
            correctArt = 'der';
            correctAdjEnding = 'en';
            break;
        }
        break;
    }

    // Extract base adjective stem (assuming ending was attempted)
    String stem = adj;
    if (stem.endsWith('en')) {
      stem = stem.substring(0, stem.length - 2);
    } else if (stem.endsWith('e')) {
      stem = stem.substring(0, stem.length - 1);
    } else if (stem.endsWith('em') || stem.endsWith('er') || stem.endsWith('es')) {
      stem = stem.substring(0, stem.length - 2);
    }

    final expectedAdj = '$stem$correctAdjEnding';
    final isArtMatch = art == correctArt;
    final isAdjMatch = adj == expectedAdj;
    final isValid = isArtMatch && isAdjMatch;

    String explanation = 'Agreement correct.';
    if (!isValid) {
      explanation = 'Morphosyntactic Agreement Mismatch: Expected $correctArt $expectedAdj for '
          '${expectedGender.name} ${expectedCase.name}.';
    }

    return NounPhraseAgreementReport(
      isValid: isValid,
      rawPhrase: raw,
      targetCase: expectedCase,
      targetGender: expectedGender,
      correctedPhrase: '$correctArt $expectedAdj $noun',
      errorExplanation: explanation,
    );
  }
}
