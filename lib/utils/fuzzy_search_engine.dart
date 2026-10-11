/// Pure, allocation-bounded typo suggestions over a caller-supplied shortlist.
///
/// Call [suggest] only after an exact/prefix FTS query returns no matches.
/// Do not feed a full lexicon to this synchronous class: shortlist candidates
/// by language, prefix, phonetic code, or a database index first.
class FuzzySuggestion {
  const FuzzySuggestion({
    required this.term,
    required this.distance,
    required this.phoneticMatch,
  });

  final String term;
  final int distance;
  final bool phoneticMatch;
}

class FuzzySearchEngine {
  FuzzySearchEngine._();

  static const int maxEditDistance = 2;
  static const int maxTermLength = 48;
  static const int maxCandidates = 128;
  static const int maxSuggestions = 3;

  static final RegExp _asciiLatin = RegExp(r'^[a-z]+$');

  /// Unrestricted Damerau-Levenshtein: insert, delete, replace, or transpose.
  ///
  /// Unlike optimal-string-alignment distance, edits may overlap (ca -> abc
  /// has distance 2). Returns null if either input exceeds the safety limit
  /// or the actual distance is greater than [maxEditDistance].
  static int? distance(String source, String target) {
    if (!_validTerm(source) || !_validTerm(target)) return null;
    final a = source.trim().toLowerCase().runes.toList(growable: false);
    final b = target.trim().toLowerCase().runes.toList(growable: false);
    final n = a.length;
    final m = b.length;
    if ((n - m).abs() > maxEditDistance) return null;

    // The extra row and column preserve the last-seen character positions.
    // Memory is bounded by (maxTermLength + 2)^2 integers.
    final infinity = n + m;
    final matrix = List<List<int>>.generate(
      n + 2,
      (_) => List<int>.filled(m + 2, 0),
      growable: false,
    );
    matrix[0][0] = infinity;
    for (var i = 0; i <= n; i++) {
      matrix[i + 1][0] = infinity;
      matrix[i + 1][1] = i;
    }
    for (var j = 0; j <= m; j++) {
      matrix[0][j + 1] = infinity;
      matrix[1][j + 1] = j;
    }

    final lastRow = <int, int>{};
    for (var i = 1; i <= n; i++) {
      var lastMatchColumn = 0;
      for (var j = 1; j <= m; j++) {
        final matchedRow = lastRow[b[j - 1]] ?? 0;
        final matchedColumn = lastMatchColumn;
        final same = a[i - 1] == b[j - 1];
        final cost = same ? 0 : 1;
        if (same) lastMatchColumn = j;

        final substitution = matrix[i][j] + cost;
        final insertion = matrix[i + 1][j] + 1;
        final deletion = matrix[i][j + 1] + 1;
        final transposition = matrix[matchedRow][matchedColumn] +
            (i - matchedRow - 1) +
            1 +
            (j - matchedColumn - 1);

        var best = substitution;
        if (insertion < best) best = insertion;
        if (deletion < best) best = deletion;
        if (transposition < best) best = transposition;
        matrix[i + 1][j + 1] = best;
      }
      lastRow[a[i - 1]] = i;
    }

    final result = matrix[n + 1][m + 1];
    return result <= maxEditDistance ? result : null;
  }

  /// Deterministic American Soundex key, with common Latin accent folding.
  /// Returns null for non-Latin scripts and multiword expressions.
  static String? soundex(String value) {
    if (!_validTerm(value)) return null;
    final letters = _foldLatin(value.trim().toLowerCase());
    if (letters.isEmpty || letters.length > maxTermLength ||
        !_asciiLatin.hasMatch(letters)) {
      return null;
    }
    final first = letters[0].toUpperCase();
    final digits = StringBuffer();
    var previousCode = _soundexDigit(letters[0]);
    var count = 0;
    for (var index = 1; index < letters.length && count < 3; index++) {
      final letter = letters[index];
      if (letter == 'h' || letter == 'w') continue;
      final code = _soundexDigit(letter);
      if (code.isNotEmpty && code != previousCode) {
        digits.write(code);
        count++;
      }
      previousCode = code;
    }
    return first + (digits.toString() + '000').substring(0, 3);
  }

  /// Maximum of three ranked, unique suggestions, from at most 128 candidates.
  /// Suppressed if the normal exact/prefix search returned any results.
  ///
  /// Soundex is a tie-breaker; it never bypasses the two-edit limit.
  static List<FuzzySuggestion> suggest(
    String query,
    Iterable<String> candidates, {
    bool hasExactOrPrefixMatches = false,
    int limit = maxSuggestions,
  }) {
    if (hasExactOrPrefixMatches || !_validTerm(query) || limit <= 0) {
      return <FuzzySuggestion>[];
    }
    final count = limit > maxSuggestions ? maxSuggestions : limit;
    final search = query.trim().toLowerCase();
    if (search.isEmpty) return <FuzzySuggestion>[];
    final queryPhonetic = soundex(search);
    final seen = <String>{};
    final top = <FuzzySuggestion>[];
    var inspected = 0;

    for (final candidate in candidates) {
      if (inspected >= maxCandidates) break;
      inspected++;
      if (!_validTerm(candidate)) continue;
      final text = candidate.trim();
      final key = text.toLowerCase();
      if (!seen.add(key) || key == search) continue;
      final edits = distance(search, key);
      if (edits == null) continue;

      final matchingPhonetics = queryPhonetic != null &&
          queryPhonetic == soundex(text);
      top.add(FuzzySuggestion(
        term: text,
        distance: edits,
        phoneticMatch: matchingPhonetics,
      ));
      top.sort(_compare);
      if (top.length > count) top.removeLast();
    }
    return List<FuzzySuggestion>.unmodifiable(top);
  }

  static int _compare(FuzzySuggestion left, FuzzySuggestion right) {
    final byDistance = left.distance.compareTo(right.distance);
    if (byDistance != 0) return byDistance;
    if (left.phoneticMatch != right.phoneticMatch) {
      return left.phoneticMatch ? -1 : 1;
    }
    final byLength = left.term.runes.length.compareTo(right.term.runes.length);
    if (byLength != 0) return byLength;
    return left.term.toLowerCase().compareTo(right.term.toLowerCase());
  }

  static bool _validTerm(String value) {
    // Reject huge untrusted strings before decoding runes or allocating a DP
    // matrix. UTF-16 code units may be twice the scalar count.
    if (value.length > maxTermLength * 2) return false;
    return value.trim().runes.length <= maxTermLength;
  }

  static String _soundexDigit(String letter) {
    if ('bfpv'.contains(letter)) return '1';
    if ('cgjkqsxz'.contains(letter)) return '2';
    if ('dt'.contains(letter)) return '3';
    if (letter == 'l') return '4';
    if ('mn'.contains(letter)) return '5';
    if (letter == 'r') return '6';
    return '';
  }

  static String _foldLatin(String source) {
    const replacements = <String, String>{
      'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'å': 'a',
      'æ': 'ae', 'ç': 'c', 'č': 'c',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ñ': 'n', 'ń': 'n',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o',
      'œ': 'oe', 'š': 's', 'ś': 's',
      'ù': 'u', 'ú': 'u', 'û': 'u',
      'ý': 'y', 'ÿ': 'y', 'ž': 'z', 'ź': 'z',
      'ł': 'l', 'đ': 'd', 'ð': 'd', 'þ': 'th',
      'ğ': 'g', 'ş': 's', 'ı': 'i',
    };
    final buffer = StringBuffer();
    for (final scalar in source.runes) {
      final letter = String.fromCharCode(scalar);
      buffer.write(replacements[letter] ?? letter);
    }
    return buffer.toString();
  }
}
