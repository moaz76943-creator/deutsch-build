/// Syntactic representation format for adverbial connections.
enum AdverbialSyntacticType {
  subordinateClause,    // Subjunktion (weil, obwohl, wenn) -> Verb am Ende
  conjunctiveAdverb,    // Konjunktionaladverb (deshalb, trotzdem, sonst) -> Inversion
  prepositionalPhrase,  // Präposition (wegen, trotz, bei) -> Nominalstil
}

/// Semantic relationship category.
enum AdverbialLogicCategory { causal, concessive, conditional, finalPurpose }

/// Tri-way syntactic cluster representing the exact same logical meaning in 3 grammar structures.
class AdverbialTriWayCluster {
  final AdverbialLogicCategory category;
  final String subordinateClause;
  final String conjunctiveAdverbSentence;
  final String prepositionalPhraseSentence;
  final String arabicExplanation;

  const AdverbialTriWayCluster({
    required this.category,
    required this.subordinateClause,
    required this.conjunctiveAdverbSentence,
    required this.prepositionalPhraseSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'subordinate': subordinateClause,
        'adverb': conjunctiveAdverbSentence,
        'prepositional': prepositionalPhraseSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine transforming adverbial relationships across three primary German syntactic registers:
/// 1. Subordinate clause (Nebensatz mit Subjunktion: Verb am Ende)
/// 2. Main clause with conjunctive adverb (Hauptsatz mit Konjunktionaladverb: Inversion)
/// 3. Nominal style prepositional phrase (Präpositionalphrase)
class GermanAdverbialTriTransformEngine {
  static const List<AdverbialTriWayCluster> _curatedClusters = [
    // Causal: weil / deshalb / wegen
    AdverbialTriWayCluster(
      category: AdverbialLogicCategory.causal,
      subordinateClause: 'Weil es stark regnete, blieben wir zu Hause.',
      conjunctiveAdverbSentence: 'Es regnete stark, deshalb blieben wir zu Hause.',
      prepositionalPhraseSentence: 'Wegen des starken Regens blieben wir zu Hause.',
      arabicExplanation: 'السببية: (لأن / لذلك / بسبب)',
    ),
    // Concessive: obwohl / trotzdem / trotz
    AdverbialTriWayCluster(
      category: AdverbialLogicCategory.concessive,
      subordinateClause: 'Obwohl er sehr müde war, arbeitete er weiter.',
      conjunctiveAdverbSentence: 'Er war sehr müde, trotzdem arbeitete er weiter.',
      prepositionalPhraseSentence: 'Trotz seiner großen Müdigkeit arbeitete er weiter.',
      arabicExplanation: 'التناقض / الاستدراك: (على الرغم من / مع ذلك / رغم)',
    ),
    // Conditional: wenn / sonst / bei
    AdverbialTriWayCluster(
      category: AdverbialLogicCategory.conditional,
      subordinateClause: 'Wenn du regelmäßig übst, lernst du schneller.',
      conjunctiveAdverbSentence: 'Übe regelmäßig, sonst lernst du nicht schnell.',
      prepositionalPhraseSentence: 'Bei regelmäßigem Üben lernst du schneller.',
      arabicExplanation: 'الشرطية: (إذا / وإلا / عند)',
    ),
    // Final Purpose: damit / dazu / zu
    AdverbialTriWayCluster(
      category: AdverbialLogicCategory.finalPurpose,
      subordinateClause: 'Ich lerne fleißig, damit ich die Prüfung bestehe.',
      conjunctiveAdverbSentence: 'Ich möchte die Prüfung bestehen, dafür lerne ich fleißig.',
      prepositionalPhraseSentence: 'Zum Bestehen der Prüfung lerne ich fleißig.',
      arabicExplanation: 'الغاية / الهدف: (لكي / لأجل ذلك / من أجل)',
    ),
  ];

  /// Find matching tri-way transformation cluster by logical category.
  static AdverbialTriWayCluster findCluster(AdverbialLogicCategory category) {
    return _curatedClusters.firstWhere(
      (c) => c.category == category,
      orElse: () => _curatedClusters.first,
    );
  }

  /// Detect the syntactic type of a given input sentence.
  static AdverbialSyntacticType detectType(String sentence) {
    final lower = sentence.trim().toLowerCase();

    if (lower.startsWith('weil') || lower.startsWith('obwohl') || lower.startsWith('wenn') || lower.startsWith('damit')) {
      return AdverbialSyntacticType.subordinateClause;
    }
    if (lower.startsWith('wegen') || lower.startsWith('trotz') || lower.startsWith('bei') || lower.startsWith('zum')) {
      return AdverbialSyntacticType.prepositionalPhrase;
    }
    return AdverbialSyntacticType.conjunctiveAdverb;
  }
}
