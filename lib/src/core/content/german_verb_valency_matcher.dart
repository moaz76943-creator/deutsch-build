/// Case required by the prepositional object.
enum PrepositionalCase { accusative, dative }

/// Verb valency descriptor detailing governing preposition and required case.
class VerbValencyRule {
  final String verbInfinitive;
  final String requiredPreposition;
  final PrepositionalCase requiredCase;
  final String sampleSentence;

  const VerbValencyRule({
    required this.verbInfinitive,
    required this.requiredPreposition,
    required this.requiredCase,
    required this.sampleSentence,
  });
}

/// Offline rule engine checking German verbs with fixed prepositions (Verben mit Präpositionen).
class GermanVerbValencyMatcher {
  static const List<VerbValencyRule> _valencyRegistry = [
    VerbValencyRule(
      verbInfinitive: 'warten',
      requiredPreposition: 'auf',
      requiredCase: PrepositionalCase.accusative,
      sampleSentence: 'Ich warte auf den Bus.',
    ),
    VerbValencyRule(
      verbInfinitive: 'interessieren',
      requiredPreposition: 'fuer',
      requiredCase: PrepositionalCase.accusative,
      sampleSentence: 'Ich interessiere mich für Sprachen.',
    ),
    VerbValencyRule(
      verbInfinitive: 'gehoeren',
      requiredPreposition: 'zu',
      requiredCase: PrepositionalCase.dative,
      sampleSentence: 'Das Buch gehört zu dem Kurs.',
    ),
    VerbValencyRule(
      verbInfinitive: 'teilnehmen',
      requiredPreposition: 'an',
      requiredCase: PrepositionalCase.dative,
      sampleSentence: 'Er nimmt an dem Unterricht teil.',
    ),
    VerbValencyRule(
      verbInfinitive: 'traeumen',
      requiredPreposition: 'von',
      requiredCase: PrepositionalCase.dative,
      sampleSentence: 'Sie träumt von einer Reise.',
    ),
  ];

  /// Find governing valency rule for an infinitive or conjugated stem.
  static VerbValencyRule? findValency(String verb) {
    final clean = verb.trim().toLowerCase()
        .replaceAll('ü', 'ue')
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe');

    for (final rule in _valencyRegistry) {
      if (clean.contains(rule.verbInfinitive)) {
        return rule;
      }
    }
    return null;
  }

  /// Validate whether user-supplied preposition matches the verb's governed preposition.
  static bool validatePreposition(String verb, String preposition) {
    final rule = findValency(verb);
    if (rule == null) return false;
    final cleanPrep = preposition.trim().toLowerCase()
        .replaceAll('ü', 'ue');
    return rule.requiredPreposition == cleanPrep;
  }
}
