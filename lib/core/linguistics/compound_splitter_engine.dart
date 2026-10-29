class CompoundDecomposition {
  final String compound;
  final String modifierPart;      // الجزء الأول المخصص (Bestimmungswort)
  final String? fugenelement;      // حرف الربط الصوتي (-s-, -en-, -er-)
  final String headPart;          // الاسم الرئيسي الأخير (Grundwort)
  final String derivedArticle;    // أداة التعريف المكتسبة من الاسم الأخير
  final String semanticExplanation;

  const CompoundDecomposition({
    required this.compound,
    required this.modifierPart,
    this.fugenelement,
    required this.headPart,
    required this.derivedArticle,
    required this.semanticExplanation,
  });
}

/// Offline morphological engine decomposing German compound nouns and determining gender and interfixes.
class CharSplitCompoundEngine {
  // بنك الأسماء الأساسية الشائعة وجنسها لتحديد أداة الاسم المركب الأخير
  static const Map<String, String> _headNouns = {
    'schuh': 'der',    // Handschuh -> der
    'haus': 'das',     // Krankenhaus, Rathaus -> das
    'karte': 'die',    // Geburtstagskarte, Fahrkarte -> die
    'buch': 'das',     // Wörterbuch, Lehrbuch -> das
    'brille': 'die',   // Sonnenbrille -> die
    'plan': 'der',     // Fahrplan, Stundenplan -> der
    'wagen': 'der',    // Krankenwagen, Kinderwagen -> der
    'tür': 'die',      // Haustür, Zimmertür -> die
    'zimmer': 'das',   // Wohnzimmer, Badezimmer -> das
    'platz': 'der',    // Arbeitsplatz, Spielplatz -> der
  };

  static const List<String> _fugenList = ['en', 'es', 'er', 's', 'n', 'e'];

  /// تجزئة الكلمة المركبة واستخراج الاسم الرئيسي وحرف الربط
  CompoundDecomposition? split(String compoundWord) {
    final clean = compoundWord.trim().toLowerCase();
    if (clean.length < 6) return null; // الكلمات المركبة الألمانية عادة أطول من 5 أحرف

    for (final entry in _headNouns.entries) {
      final head = entry.key;
      if (clean.endsWith(head) && clean.length > head.length + 2) {
        final prefixWithFuge = clean.substring(0, clean.length - head.length);
        String modifier = prefixWithFuge;
        String? fuge;

        for (final candidateFuge in _fugenList) {
          if (prefixWithFuge.endsWith(candidateFuge) && prefixWithFuge.length > candidateFuge.length + 2) {
            fuge = candidateFuge;
            modifier = prefixWithFuge.substring(0, prefixWithFuge.length - candidateFuge.length);
            break;
          }
        }

        return CompoundDecomposition(
          compound: compoundWord,
          modifierPart: modifier,
          fugenelement: fuge,
          headPart: head,
          derivedArticle: entry.value,
          semanticExplanation: 'الاسم الرئيسي الأخير "$head" يحدد أداة التعريف (${entry.value})' +
              (fuge != null ? ' مع وجود حرف الربط الصوتي (-$fuge-).' : '.'),
        );
      }
    }
    return null;
  }
}
