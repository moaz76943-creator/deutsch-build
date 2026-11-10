/// Style type of the syntactic expression.
enum SyntacticStyle { nominal, verbal }

/// Semantic relationship of the clause connector.
enum ConnectorRelationship { temporal, causal, concessive, modal }

/// Pair descriptor mapping a nominal prepositional phrase to its verbal clause equivalent.
class NominalVerbalPair {
  final String nominalPattern;
  final String verbalConjunction;
  final String verbalVerb;
  final ConnectorRelationship relationship;
  final String sampleNominal;
  final String sampleVerbal;

  const NominalVerbalPair({
    required this.nominalPattern,
    required this.verbalConjunction,
    required this.verbalVerb,
    required this.relationship,
    required this.sampleNominal,
    required this.sampleVerbal,
  });
}

/// Nomen-Verb-Verbindung (Functional Verb Collocation) mapping.
class FunctionalVerbCollocation {
  final String collocation;
  final String simpleVerb;
  final String arabicMeaning;

  const FunctionalVerbCollocation({
    required this.collocation,
    required this.simpleVerb,
    required this.arabicMeaning,
  });
}

/// Offline rule engine transforming German academic Nominalstil into communicative Verbalstil
/// and resolving functional verb collocations (Nomen-Verb-Verbindungen).
class GermanNominalizationConverter {
  static const List<NominalVerbalPair> _nominalVerbalRegistry = [
    NominalVerbalPair(
      nominalPattern: 'beim',
      verbalConjunction: 'während / als',
      verbalVerb: 'essen / sprechen',
      relationship: ConnectorRelationship.temporal,
      sampleNominal: 'Beim Essen sprechen wir nicht.',
      sampleVerbal: 'Während wir essen, sprechen wir nicht.',
    ),
    NominalVerbalPair(
      nominalPattern: 'nach',
      verbalConjunction: 'nachdem',
      verbalVerb: 'ankommen / beenden',
      relationship: ConnectorRelationship.temporal,
      sampleNominal: 'Nach der Ankunft ruhte er sich aus.',
      sampleVerbal: 'Nachdem er angekommen war, ruhte er sich aus.',
    ),
    NominalVerbalPair(
      nominalPattern: 'vor',
      verbalConjunction: 'bevor / ehe',
      verbalVerb: 'abfahren / beginnen',
      relationship: ConnectorRelationship.temporal,
      sampleNominal: 'Vor dem Beginn des Unterrichts prüfen wir die Anwesenheit.',
      sampleVerbal: 'Bevor der Unterricht beginnt, prüfen wir die Anwesenheit.',
    ),
    NominalVerbalPair(
      nominalPattern: 'wegen',
      verbalConjunction: 'weil / da',
      verbalVerb: 'regnen / krank sein',
      relationship: ConnectorRelationship.causal,
      sampleNominal: 'Wegen des starken Regens blieben wir zu Hause.',
      sampleVerbal: 'Weil es stark regnete, blieben wir zu Hause.',
    ),
    NominalVerbalPair(
      nominalPattern: 'trotz',
      verbalConjunction: 'obwohl / obgleich',
      verbalVerb: 'müde sein / regnen',
      relationship: ConnectorRelationship.concessive,
      sampleNominal: 'Trotz seiner Müdigkeit arbeitete er weiter.',
      sampleVerbal: 'Obwohl er müde war, arbeitete er weiter.',
    ),
  ];

  static const List<FunctionalVerbCollocation> _functionalVerbs = [
    FunctionalVerbCollocation(
      collocation: 'eine entscheidung treffen',
      simpleVerb: 'sich entscheiden',
      arabicMeaning: 'يتخذ قراراً',
    ),
    FunctionalVerbCollocation(
      collocation: 'kritik ueben',
      simpleVerb: 'kritisieren',
      arabicMeaning: 'يوجه نقداً / ينتقد',
    ),
    FunctionalVerbCollocation(
      collocation: 'unter beweis stellen',
      simpleVerb: 'beweisen',
      arabicMeaning: 'يبرهن / يثبت جدارة',
    ),
    FunctionalVerbCollocation(
      collocation: 'in betracht ziehen',
      simpleVerb: 'beruecksichtigen',
      arabicMeaning: 'يأخذ بعين الاعتبار',
    ),
    FunctionalVerbCollocation(
      collocation: 'hilfe leisten',
      simpleVerb: 'helfen',
      arabicMeaning: 'يقدم مساعدة',
    ),
  ];

  /// Find matching verbal clause transformation for a nominal prepositional pattern.
  static NominalVerbalPair? findVerbalEquivalent(String phrase) {
    final lower = phrase.trim().toLowerCase();
    for (final pair in _nominalVerbalRegistry) {
      if (lower.startsWith(pair.nominalPattern)) {
        return pair;
      }
    }
    return null;
  }

  /// Resolve a functional verb collocation to its simple canonical verb.
  static FunctionalVerbCollocation? resolveCollocation(String phrase) {
    final clean = phrase.trim().toLowerCase()
        .replaceAll('ü', 'ue')
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe');

    for (final fv in _functionalVerbs) {
      if (clean.contains(fv.collocation)) {
        return fv;
      }
    }
    return null;
  }
}
