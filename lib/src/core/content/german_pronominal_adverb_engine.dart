/// Entity reference type (animate person vs inanimate concept).
enum EntityReferenceType { personAnimate, conceptInanimate }

/// Analysis descriptor of pronominal adverb question and response pairs.
class PronominalAdverbStructure {
  final String preposition;
  final EntityReferenceType referenceType;
  final bool hasEpentheticR;
  final String demonstrativeForm; // e.g. "daran", "dafür", "an ihn"
  final String interrogativeForm;  // e.g. "woran", "wofür", "an wen"
  final String sampleQuestion;
  final String sampleAnswer;

  PronominalAdverbStructure({
    required this.preposition,
    required this.referenceType,
    required this.hasEpentheticR,
    required this.demonstrativeForm,
    required this.interrogativeForm,
    required this.sampleQuestion,
    required this.sampleAnswer,
  });

  Map<String, dynamic> toJson() => {
        'preposition': preposition,
        'reference': referenceType.name,
        'epenthesis': hasEpentheticR,
        'demonstrative': demonstrativeForm,
        'interrogative': interrogativeForm,
        'question': sampleQuestion,
        'answer': sampleAnswer,
      };
}

/// Offline rule engine constructing and validating German Pronominal Adverbs (Pronominaladverbien).
/// Enforces the epenthetic "-r-" rule when prepositions start with vowels (da+an -> daran, wo+auf -> worauf),
/// and cleanly separates prepositional questions for persons (An wen? Mit wem?) from things (Woran? Womit?).
class GermanPronominalAdverbEngine {
  static const Set<String> _vowelInitialPrepositions = {
    'an', 'auf', 'aus', 'in', 'ueber', 'über', 'unter', 'um'
  };

  static const Set<String> _supportedPrepositions = {
    'an', 'auf', 'aus', 'bei', 'durch', 'fuer', 'für', 'gegen', 'hinter',
    'in', 'mit', 'nach', 'ueber', 'über', 'unter', 'um', 'von', 'vor', 'zu', 'zwischen'
  };

  /// Build demonstrative and interrogative forms for a preposition.
  static PronominalAdverbStructure buildForms({
    required String preposition,
    required EntityReferenceType referenceType,
    required String governingVerb, // e.g. "denken", "warten", "sprechen"
  }) {
    final cleanPrep = preposition.trim().toLowerCase()
        .replaceAll('ü', 'ue');

    if (!_supportedPrepositions.contains(cleanPrep)) {
      throw ArgumentError('Unsupported preposition for pronominal adverb: $preposition');
    }

    final startsWithVowel = _vowelInitialPrepositions.contains(cleanPrep);
    final connective = startsWithVowel ? 'r' : '';

    String demoForm = '';
    String interrForm = '';
    String question = '';
    String answer = '';

    if (referenceType == EntityReferenceType.conceptInanimate) {
      // Inanimate: da(r) + prep / wo(r) + prep
      demoForm = 'da$connective$cleanPrep';
      interrForm = 'wo$connective$cleanPrep';

      question = '${interrForm[0].toUpperCase()}${interrForm.substring(1)} $governingVerb du?';
      answer = 'Ich $governingVerb $demoForm.';
    } else {
      // Animate person: Prep + Acc/Dat question word (wen/wem)
      final isDativ = cleanPrep == 'mit' || cleanPrep == 'von' || cleanPrep == 'zu' || cleanPrep == 'aus' || cleanPrep == 'bei';
      final questionWord = isDativ ? 'wem' : 'wen';
      final pronounPerson = isDativ ? 'ihm' : 'ihn';

      demoForm = '$cleanPrep $pronounPerson';
      interrForm = '$cleanPrep $questionWord';

      question = '${cleanPrep[0].toUpperCase()}${cleanPrep.substring(1)} $questionWord $governingVerb du?';
      answer = 'Ich $governingVerb $cleanPrep $pronounPerson.';
    }

    return PronominalAdverbStructure(
      preposition: preposition,
      referenceType: referenceType,
      hasEpentheticR: startsWithVowel,
      demonstrativeForm: demoForm,
      interrogativeForm: interrForm,
      sampleQuestion: question,
      sampleAnswer: answer,
    );
  }
}
