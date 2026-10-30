/// Detailed cultural and semantic breakdown of an idiomatic expression.
class DecodedIdiom {
  final String idiom;
  final String literalMeaning;
  final String communicativeMeaning;
  final String culturalOrigin;
  final String register; // colloquial, neutral, poetic
  final String equivalentInEnglish;

  const DecodedIdiom({
    required this.idiom,
    required this.literalMeaning,
    required this.communicativeMeaning,
    required this.culturalOrigin,
    required this.register,
    required this.equivalentInEnglish,
  });
}

/// Decodes figurative expressions to prevent literal comprehension failure.
class CulturalMetaphorDecoder {
  static const List<DecodedIdiom> _idioms = [
    DecodedIdiom(
      idiom: 'nur Bahnhof verstehen',
      literalMeaning: 'To understand only train station.',
      communicativeMeaning: 'To not understand a single word; it is all incomprehensible.',
      culturalOrigin: 'First World War soldiers longing for the train station to go home; all conversations were dismissed in favor of the train home.',
      register: 'colloquial',
      equivalentInEnglish: 'It is all Greek to me.',
    ),
    DecodedIdiom(
      idiom: 'die Daumen drücken',
      literalMeaning: 'To press the thumbs.',
      communicativeMeaning: 'To wish someone luck or success.',
      culturalOrigin: 'Ancient Roman gladiatorial contests where thumb gestures determined survival or sparing.',
      register: 'neutral',
      equivalentInEnglish: 'To keep one’s fingers crossed.',
    ),
    DecodedIdiom(
      idiom: 'Tomaten auf den Augen haben',
      literalMeaning: 'To have tomatoes on one’s eyes.',
      communicativeMeaning: 'To be oblivious to something obvious that everyone else sees.',
      culturalOrigin: 'Referring to swollen, red, unseeing eyes from lack of sleep or distraction.',
      register: 'colloquial',
      equivalentInEnglish: 'To be blind to the obvious.',
    ),
    DecodedIdiom(
      idiom: 'ins Gras beißen',
      literalMeaning: 'To bite into the grass.',
      communicativeMeaning: 'To perish or die.',
      culturalOrigin: 'Battlefield metaphor of fallen warriors biting the turf.',
      register: 'colloquial',
      equivalentInEnglish: 'To bite the dust.',
    ),
  ];

  /// Detects whether an input sentence contains a known idiomatic phrase.
  DecodedIdiom? detectIdiom(String sentence) {
    final clean = sentence.toLowerCase();
    for (final id in _idioms) {
      final keyWords = id.idiom.toLowerCase().split(' ');
      bool allFound = true;
      for (final kw in keyWords) {
        if (!clean.contains(kw)) {
          allFound = false;
          break;
        }
      }
      if (allFound) return id;
    }
    return null;
  }
}
