/// Grammatical case in German nominal syntax.
enum GermanGrammaticalCase { nominativ, akkusativ, dativ, genitiv, ambiguous }

/// Deterministic offline grammatical case analyzer based on preposition government,
/// verb valency, and two-way preposition (Wechselpräpositionen) directional semantics.
class GermanCaseDisambiguationEngine {
  static const Set<String> _accusativePrepositions = {
    'durch',
    'fuer',
    'für',
    'gegen',
    'ohne',
    'um',
    'bis',
    'entlang',
  };

  static const Set<String> _dativePrepositions = {
    'aus',
    'ausser',
    'außer',
    'bei',
    'mit',
    'nach',
    'seit',
    'von',
    'zu',
    'gegenueber',
    'gegenüber',
  };

  static const Set<String> _genitivePrepositions = {
    'waehrend',
    'während',
    'wegen',
    'trotz',
    'anstatt',
    'statt',
  };

  static const Set<String> _twoWayPrepositions = {
    'an',
    'auf',
    'hinter',
    'in',
    'neben',
    'ueber',
    'über',
    'unter',
    'vor',
    'zwischen',
  };

  /// Disambiguate required case for a noun phrase governed by a given preposition.
  static GermanGrammaticalCase resolvePrepositionCase(String preposition, {bool isDirectionalMotion = false}) {
    final clean = preposition.trim().toLowerCase();

    if (_accusativePrepositions.contains(clean)) {
      return GermanGrammaticalCase.akkusativ;
    }
    if (_dativePrepositions.contains(clean)) {
      return GermanGrammaticalCase.dativ;
    }
    if (_genitivePrepositions.contains(clean)) {
      return GermanGrammaticalCase.genitiv;
    }
    if (_twoWayPrepositions.contains(clean)) {
      // Wohin? (Motion/Direction) -> Akkusativ | Wo? (Static Location) -> Dativ
      return isDirectionalMotion
          ? GermanGrammaticalCase.akkusativ
          : GermanGrammaticalCase.dativ;
    }

    return GermanGrammaticalCase.ambiguous;
  }

  /// Check whether an article aligns with the expected grammatical case and gender.
  static bool verifyDefiniteArticle({
    required String article,
    required GermanGrammaticalCase targetCase,
    required String gender, // 'der', 'die', 'das'
  }) {
    final cleanArt = article.trim().toLowerCase();
    switch (targetCase) {
      case GermanGrammaticalCase.nominativ:
        if (gender == 'der') return cleanArt == 'der';
        if (gender == 'die') return cleanArt == 'die';
        if (gender == 'das') return cleanArt == 'das';
        break;
      case GermanGrammaticalCase.akkusativ:
        if (gender == 'der') return cleanArt == 'den';
        if (gender == 'die') return cleanArt == 'die';
        if (gender == 'das') return cleanArt == 'das';
        break;
      case GermanGrammaticalCase.dativ:
        if (gender == 'der' || gender == 'das') return cleanArt == 'dem';
        if (gender == 'die') return cleanArt == 'der';
        break;
      case GermanGrammaticalCase.genitiv:
        if (gender == 'der' || gender == 'das') return cleanArt == 'des';
        if (gender == 'die') return cleanArt == 'der';
        break;
      case GermanGrammaticalCase.ambiguous:
        return true;
    }
    return false;
  }
}
