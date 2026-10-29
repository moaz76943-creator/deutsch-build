/// Bounded, offline-only typo suggestions for short lexicon queries.
///
/// This engine never loads or caches a lexicon. Callers supply a limited
/// candidate stream after their exact/prefix search returned no results.
class FuzzySearchEngine {
  const FuzzySearchEngine._();

  static const int maxEditDistance = 2;
  static const int maxWordRunes = 48;
  static const int maxQueryRunes = 30;
  static const int maxCandidateChecks = 96;
  static const int maxSuggestions = 3;

  /// True Damerau-Levenshtein: insert, delete, replace, or transpose adjacent
  /// characters. Unlike restricted optimal-string-alignment, a character may
  /// participate in more than one edit (e.g. CA -> ABC has distance 2).
  ///
  /// Returns [maxEditDistance] + 1 if beyond the threshold or input cap.
  /// The capped 50x50 matrix prevents unbounded allocations and runtime work.
  static int damerauLevenshtein(
    String source,
    String target, {
    int threshold = maxEditDistance,
  }) {
    if (threshold < 0 || threshold > maxEditDistance) {
      throw RangeError.range(threshold, 0, maxEditDistance, 'threshold');
    }
    final a = source.trim().toLowerCase().runes.toList(growable: false);
    final b = target.trim().toLowerCase().runes.toList(growable: false);
    if (a.length > maxQueryRunes || b.length > maxWordRunes) {
      return threshold + 1;
    }
    final n = a.length;
    final m = b.length;
    if ((n - m).abs() > threshold) return threshold + 1;
    if (n == 0) return m > threshold ? threshold + 1 : m;
    if (m == 0) return n > threshold ? threshold + 1 : n;

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

    final lastSeenRow = <int, int>{};
    for (var i = 1; i <= n; i++) {
      var lastMatchColumn = 0;
      for (var j = 1; j <= m; j++) {
        final previousRow = lastSeenRow[b[j - 1]] ?? 0;
        final previousColumn = lastMatchColumn;
        final equal = a[i - 1] == b[j - 1];
        if (equal) lastMatchColumn = j;
        final substitution = matrix[i][j] + (equal ? 0 : 1);
        final insertion = matrix[i + 1][j] + 1;
        final deletion = matrix[i][j + 1] + 1;
        final transposition = matrix[previousRow][previousColumn] +
            (i - previousRow - 1) + 1 + (j - previousColumn - 1);
        var cost = substitution < insertion ? substitution : insertion;
        if (deletion < cost) cost = deletion;
        if (transposition < cost) cost = transposition;
        matrix[i + 1][j + 1] = cost;
      }
      lastSeenRow[a[i - 1]] = i;
    }

    final distance = matrix[n + 1][m + 1];
    return distance > threshold ? threshold + 1 : distance;
  }

  /// A deliberately small Latin-script Soundex. Non-Latin input returns ''.
  /// Accent folding is for phonetics only; edit distance retains original
  /// Unicode code points and does not replace the user's spelling.
  static String soundex(String word) {
    var latin = word.trim().toLowerCase();
    if (latin.isEmpty || latin.runes.length > maxWordRunes) return '';
    latin = latin
        .replaceAll('æ', 'ae')
        .replaceAll('œ', 'oe')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[àáâãäåāăą]'), 'a')
        .replaceAll(RegExp(r'[çćč]'), 'c')
        .replaceAll(RegExp(r'[ďđ]'), 'd')
        .replaceAll(RegExp(r'[èéêëēěę]'), 'e')
        .replaceAll(RegExp(r'[ìíîïīı]'), 'i')
        .replaceAll(RegExp(r'[ñńň]'), 'n')
        .replaceAll(RegExp(r'[òóôõöøō]'), 'o')
        .replaceAll(RegExp(r'[řŕ]'), 'r')
        .replaceAll(RegExp(r'[śšş]'), 's')
        .replaceAll(RegExp(r'[ťț]'), 't')
        .replaceAll(RegExp(r'[ùúûüū]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll(RegExp(r'[źżž]'), 'z')
        .replaceAll(RegExp(r'[ł]'), 'l');
    if (!RegExp(r'^[a-z]+$').hasMatch(latin)) return '';

    String digit(String character) {
      if ('bfpv'.contains(character)) return '1';
      if ('cgjkqsxz'.contains(character)) return '2';
      if ('dt'.contains(character)) return '3';
      if (character == 'l') return '4';
      if ('mn'.contains(character)) return '5';
      if (character == 'r') return '6';
      return '0';
    }

    final first = latin[0].toUpperCase();
    final result = StringBuffer(first);
    var previous = digit(latin[0]);
    var emitted = 0;
    for (var index = 1; index < latin.length && emitted < 3; index++) {
      final ch = latin[index];
      if (ch == 'h' || ch == 'w') continue;
      final code = digit(ch);
      if (code != '0' && code != previous) {
        result.write(code);
        emitted++;
      }
      previous = code;
    }
    for (; emitted < 3; emitted++) {
      result.write('0');
    }
    return result.toString();
  }

  /// Returns at most three ranked "Did you mean?" candidates.
  ///
  /// Invoke only after exact/prefix search found nothing, indicated by
  /// [exactOrPrefixFound] = false. Phonetic matches can supplement edit-
  /// distance matches; non-Latin words use edit distance exclusively.
  /// Only the first [maxCandidateChecks] candidates are examined.
  static List<String> didYouMean(
    String query,
    Iterable<String> candidates, {
    bool exactOrPrefixFound = false,
  }) {
    final term = query.trim();
    if (exactOrPrefixFound ||
        term.isEmpty ||
        term.runes.length > maxQueryRunes) {
      return const <String>[];
    }
    final canonicalQuery = term.toLowerCase();
    final sound = soundex(term);
    final seen = <String>{};
    final best = <_Suggestion>[];
    var checked = 0;

    for (final candidate in candidates) {
      if (checked++ >= maxCandidateChecks) break;
      final text = candidate.trim();
      if (text.isEmpty || text.runes.length > maxWordRunes) continue;
      final normalized = text.toLowerCase();
      if (!seen.add(normalized)) continue;
      // An exact/prefix hit means the caller has a normal search result.
      if (normalized.startsWith(canonicalQuery)) return const <String>[];
      final distance = damerauLevenshtein(term, text);
      final phonetic = sound.isNotEmpty && sound == soundex(text);
      if (distance > maxEditDistance) continue;

      final next = _Suggestion(
        text,
        distance,
        phonetic,
      );
      var insertAt = 0;
      while (insertAt < best.length &&
          _compare(best[insertAt], next) <= 0) {
        insertAt++;
      }
      if (insertAt >= maxSuggestions) continue;
      best.insert(insertAt, next);
      if (best.length > maxSuggestions) best.removeLast();
    }
    return List<String>.unmodifiable(best.map((entry) => entry.word));
  }

  static int _compare(_Suggestion left, _Suggestion right) {
    if (left.distance != right.distance) {
      return left.distance.compareTo(right.distance);
    }
    if (left.phonetic != right.phonetic) {
      return left.phonetic ? -1 : 1;
    }
    final comparison =
        left.word.toLowerCase().compareTo(right.word.toLowerCase());
    return comparison != 0 ? comparison : left.word.compareTo(right.word);
  }
}

class _Suggestion {
  const _Suggestion(this.word, this.distance, this.phonetic);
  final String word;
  final int distance;
  final bool phonetic;
}
