/// A discrete contextual sense of a polysemous word.
class WordSense {
  final String senseId;
  final String definition;
  final List<String> triggerKeywords;
  final String exampleSentence;

  const WordSense({
    required this.senseId,
    required this.definition,
    required this.triggerKeywords,
    required this.exampleSentence,
  });
}

/// Disambiguates polysemous words using surrounding contextual window clues.
class LexicalPolysemyDisambiguator {
  static const Map<String, List<WordSense>> _polysemyDatabase = {
    'bank': [
      WordSense(
        senseId: 'bank_financial',
        definition: 'Financial institution handling money, loans, or accounts.',
        triggerKeywords: ['geld', 'konto', 'überweisung', 'filiale', 'automat', 'kredit'],
        exampleSentence: 'Ich gehe zur Bank, um Geld abzuheben.',
      ),
      WordSense(
        senseId: 'bank_seating',
        definition: 'A long bench for multiple people to sit on, often in parks.',
        triggerKeywords: ['sitzen', 'park', 'garten', 'holz', 'platz', 'ausruhen'],
        exampleSentence: 'Wir sitzen auf einer Bank im Stadtpark.',
      ),
    ],
    'schloss': [
      WordSense(
        senseId: 'schloss_castle',
        definition: 'Grand stately castle, palace, or manor house.',
        triggerKeywords: ['könig', 'prinz', 'burg', 'museum', 'turm', 'alt', 'besichtigen'],
        exampleSentence: 'Das Schloss Neuschwanstein ist berühmt.',
      ),
      WordSense(
        senseId: 'schloss_lock',
        definition: 'Mechanical device for securing doors, gates, or bicycles.',
        triggerKeywords: ['tür', 'schlüssel', 'fahrrad', 'schließen', 'öffnen', 'sperren'],
        exampleSentence: 'Mein Schlüssel steckt im Schloss.',
      ),
    ],
  };

  /// Disambiguates a target polysemous word within a context passage.
  WordSense? disambiguate({required String word, required String contextSentence}) {
    final lowerWord = word.trim().toLowerCase();
    final senses = _polysemyDatabase[lowerWord];
    if (senses == null || senses.isEmpty) return null;

    final contextTokens = contextSentence.toLowerCase().split(RegExp(r'\W+')).toSet();

    WordSense bestSense = senses.first;
    int maxHits = -1;

    for (final sense in senses) {
      int hits = 0;
      for (final kw in sense.triggerKeywords) {
        if (contextTokens.contains(kw)) hits++;
      }
      if (hits > maxHits) {
        maxHits = hits;
        bestSense = sense;
      }
    }

    return bestSense;
  }
}
