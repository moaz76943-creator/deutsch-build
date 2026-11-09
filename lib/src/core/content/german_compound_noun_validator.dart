/// Gender categories in German nominal grammar.
enum GermanGender { der, die, das }

/// Component decomposition of a German compound noun (Kompositum).
class CompoundNounAnalysis {
  final String compoundWord;
  final List<String> segments;
  final GermanGender baseGender;
  final String headNoun;

  CompoundNounAnalysis({
    required this.compoundWord,
    required this.segments,
    required this.baseGender,
    required this.headNoun,
  });

  Map<String, dynamic> toJson() => {
        'word': compoundWord,
        'segments': segments,
        'gender': baseGender.name,
        'head_noun': headNoun,
      };
}

/// Offline linguistic rule engine for decomposing German compound nouns
/// and determining correct grammatical gender based on the final head noun.
class GermanCompoundNounValidator {
  static const Map<String, GermanGender> _knownHeadNouns = {
    'haus': GermanGender.das,
    'buch': GermanGender.das,
    'zimmer': GermanGender.das,
    'schule': GermanGender.die,
    'sprache': GermanGender.die,
    'zeit': GermanGender.die,
    'lehrer': GermanGender.der,
    'wagen': GermanGender.der,
    'plan': GermanGender.der,
    'tisch': GermanGender.der,
  };

  /// Analyze a German compound noun and compute its grammatical attributes.
  static CompoundNounAnalysis analyzeCompound(String word) {
    final clean = word.trim().toLowerCase();

    // Check matching head noun suffixes
    for (final entry in _knownHeadNouns.entries) {
      if (clean.endsWith(entry.key) && clean.length > entry.key.length) {
        final prefix = clean.substring(0, clean.length - entry.key.length);
        return CompoundNounAnalysis(
          compoundWord: word,
          segments: [prefix, entry.key],
          baseGender: entry.value,
          headNoun: entry.key,
        );
      }
    }

    // Default fallback to direct dictionary lookup or neuter default
    final directGender = _knownHeadNouns[clean] ?? GermanGender.das;
    return CompoundNounAnalysis(
      compoundWord: word,
      segments: [clean],
      baseGender: directGender,
      headNoun: clean,
    );
  }
}
