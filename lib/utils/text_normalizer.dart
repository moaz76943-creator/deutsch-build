/// Offline, dependency-free normalization for multilingual dictionary search.
///
/// Latin accent folding and Arabic mark removal are deliberately scoped.
/// Characters from other scripts are preserved (apart from Unicode lowercase).
/// This is not a stemming, tokenization, or typo-distance algorithm.
class TextNormalizer {
  TextNormalizer._();

  static final RegExp _spaces = RegExp(r'\s+');

  // Precomposed Latin diacritics cannot be canonically decomposed by Dart core.
  // Build this fixed-size lookup only once, not once per search operation.
  static const Map<String, String> _latinGroups = <String, String>{
    'a': 'àáâãåāăąǎǟǡǻȁȃȧạảấầẩẫậắằẳẵặ',
    'b': 'ḃḅḇ',
    'c': 'çćĉċč',
    'd': 'ďđḋḍḏḑḓ',
    'e': 'èéêëēĕėęěȅȇẹẻẽếềểễệ',
    'f': 'ḟ',
    'g': 'ĝğġģǧḡ',
    'h': 'ĥħȟḥḣḩḫẖ',
    'i': 'ìíîïĩīĭįǐȉȋịỉ',
    'j': 'ĵǰ',
    'k': 'ķǩḱḳḵ',
    'l': 'ĺļľłḷḹḻḽ',
    'm': 'ḿṁṃ',
    'n': 'ñńņňǹṅṇṉṋ',
    'o': 'òóôõøōŏőǒǫǭȍȏȯọỏốồổỗộớờởỡợ',
    'p': 'ṕṗ',
    'r': 'ŕŗřȑȓṙṛṝṟ',
    's': 'śŝşšșṡṣṥṧṩ',
    't': 'ţťŧțṫṭṯṱ',
    'u': 'ùúûũūŭůűųǔȕȗụủứừửữự',
    'v': 'ṽṿ',
    'w': 'ŵẁẃẅẇẉẘ',
    'x': 'ẋẍ',
    'y': 'ýÿŷȳẏỳỵỷỹ',
    'z': 'źżžẑẓẕ',
  };

  static final Map<int, String> _latinFolds = _buildLatinFolds();

  static Map<int, String> _buildLatinFolds() {
    final folds = <int, String>{};
    for (final group in _latinGroups.entries) {
      for (final rune in group.value.runes) {
        folds[rune] = group.key;
      }
    }
    folds.addAll(const <int, String>{
      0x00E6: 'ae', // æ
      0x0153: 'oe', // œ
      0x00F0: 'd', // ð
      0x00FE: 'th', // þ
      0x017F: 's', // ſ
    });
    return Map<int, String>.unmodifiable(folds);
  }

  /// Normalizes a query to lowercase and collapses consecutive whitespace.
  ///
  /// German umlauts use their expanded spelling (ä -> ae, ö -> oe,
  /// ü -> ue); ß -> ss. Arabic alef variants map to ا and Arabic
  /// vowel/recitation marks are removed. Unsupported scripts pass through.
  static String normalizeQuery(String input) =>
      _fold(input, expandUmlauts: true);

  /// Case/diacritic-insensitive substring search without edit-distance
  /// correction. German umlauts match both ae/oe/ue and a/o/u variants.
  ///
  /// Empty queries never match, including against empty source strings.
  static bool fuzzyMatch(String source, String query) {
    final normalizedQuery = normalizeQuery(query);
    if (normalizedQuery.isEmpty) return false;

    final normalizedSource = normalizeQuery(source);
    if (normalizedSource.contains(normalizedQuery)) return true;

    // A second linear pass handles the alternative German spelling without
    // generating a combinatorial set of transliterated variants.
    final simpleQuery = _fold(query, expandUmlauts: false);
    final simpleSource = _fold(source, expandUmlauts: false);
    return simpleSource.contains(simpleQuery);
  }

  static String _fold(String input, {required bool expandUmlauts}) {
    // Accept NFD German spellings too (a + combining diaeresis, etc.).
    final lower = input.toLowerCase()
        .replaceAll('a\u0308', 'ä')
        .replaceAll('o\u0308', 'ö')
        .replaceAll('u\u0308', 'ü');

    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      if (_isIgnorableMark(rune)) continue;

      switch (rune) {
        case 0x00E4: // ä
          buffer.write(expandUmlauts ? 'ae' : 'a');
          break;
        case 0x00F6: // ö
          buffer.write(expandUmlauts ? 'oe' : 'o');
          break;
        case 0x00FC: // ü
          buffer.write(expandUmlauts ? 'ue' : 'u');
          break;
        case 0x00DF: // ß
          buffer.write('ss');
          break;
        case 0x0622: // آ
        case 0x0623: // أ
        case 0x0625: // إ
        case 0x0671: // ٱ
        case 0x0672: // ٲ
        case 0x0673: // ٳ
        case 0x0675: // ٵ
          buffer.write('ا');
          break;
        default:
          buffer.write(_latinFolds[rune] ?? String.fromCharCode(rune));
      }
    }
    return buffer.toString().replaceAll(_spaces, ' ').trim();
  }

  static bool _isIgnorableMark(int rune) {
    // Latin combining marks and extensions. Do not strip unrelated-script
    // vowel signs (e.g. Devanagari), which can be lexically significant.
    if ((rune >= 0x0300 && rune <= 0x036F) ||
        (rune >= 0x1AB0 && rune <= 0x1AFF) ||
        (rune >= 0x1DC0 && rune <= 0x1DFF) ||
        (rune >= 0x20D0 && rune <= 0x20FF) ||
        (rune >= 0xFE20 && rune <= 0xFE2F)) {
      return true;
    }

    // Arabic harakat, Quranic vowel signs, and Kashida (tatweel).
    return (rune >= 0x0610 && rune <= 0x061A) ||
        rune == 0x0640 ||
        (rune >= 0x064B && rune <= 0x065F) ||
        rune == 0x0670 ||
        (rune >= 0x06D6 && rune <= 0x06ED) ||
        (rune >= 0x08D3 && rune <= 0x08FF);
  }
}

/// Convenience entry point for dictionary search clients.
String normalizeQuery(String input) => TextNormalizer.normalizeQuery(input);

/// Convenience entry point for accent-insensitive substring matching.
bool fuzzyMatch(String source, String query) =>
    TextNormalizer.fuzzyMatch(source, query);
