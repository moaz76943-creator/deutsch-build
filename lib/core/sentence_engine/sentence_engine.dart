import 'sentence_models.dart';

final class SentenceAnalysisEngine {
  static final RegExp _tokenPattern = RegExp(
    r"[A-Za-zÄÖÜäöüßẞ]+(?:[-'][A-Za-zÄÖÜäöüßẞ]+)*|[0-9]+|[^\s]",
  );
  static final RegExp _wordPattern = RegExp(
    r"^[A-Za-zÄÖÜäöüßẞ0-9]",
  );
  static final RegExp _subordinateMarkerPattern = RegExp(
    r'\b(weil|dass|wenn|obwohl|damit|während|bevor|nachdem|falls|ob)\b',
    caseSensitive: false,
  );

  List<SentenceToken> analyze(SentenceEntry sentence) {
    final grammarByForm = <String, SentenceLexeme>{};

    for (final lexeme in sentence.lexicon) {
      for (final form in <String>{lexeme.lemma, ...lexeme.forms}) {
        final key = normalizeToken(form);
        if (key.isEmpty) continue;
        grammarByForm.putIfAbsent(key, () => lexeme);
      }
    }

    final result = <SentenceToken>[];
    var index = 0;
    for (final match in _tokenPattern.allMatches(sentence.german)) {
      final text = match.group(0)!;
      final normalized = normalizeToken(text);
      final isPunctuation = !_wordPattern.hasMatch(text);
      result.add(
        SentenceToken(
          index: index++,
          text: text,
          normalized: normalized,
          isPunctuation: isPunctuation,
          lexeme: isPunctuation ? null : grammarByForm[normalized],
        ),
      );
    }

    return List<SentenceToken>.unmodifiable(result);
  }

  SentenceWordOrderPattern detectWordOrderPattern(SentenceEntry sentence) {
    if (sentence.wordOrderPattern != SentenceWordOrderPattern.custom) {
      return sentence.wordOrderPattern;
    }

    if (_subordinateMarkerPattern.hasMatch(sentence.german)) {
      return SentenceWordOrderPattern.subordinateVerbFinal;
    }

    final hasModal = sentence.lexicon.any(
      (lexeme) => lexeme.verb?.isModal ?? false,
    );
    if (hasModal) return SentenceWordOrderPattern.modalBracket;

    final hasVerb = sentence.lexicon.any((lexeme) => lexeme.isVerb);
    if (hasVerb) return SentenceWordOrderPattern.svo;

    return SentenceWordOrderPattern.custom;
  }

  static String normalizeToken(String value) =>
      value.trim().toLowerCase().replaceAll('ẞ', 'ß');
}

final class SentenceFuzzySearchService {
  SentenceFuzzySearchService(Iterable<SentenceEntry> sentences)
      : _sentences = List<SentenceEntry>.unmodifiable(sentences);

  final List<SentenceEntry> _sentences;

  static const Map<String, String> _arabicToLatin = <String, String>{
    'ا': 'a',
    'أ': 'a',
    'إ': 'i',
    'آ': 'a',
    'ب': 'b',
    'ت': 't',
    'ث': 'th',
    'ج': 'j',
    'ح': 'h',
    'خ': 'ch',
    'د': 'd',
    'ذ': 'd',
    'ر': 'r',
    'ز': 'z',
    'س': 's',
    'ش': 'sch',
    'ص': 's',
    'ض': 'd',
    'ط': 't',
    'ظ': 'z',
    'ع': '',
    'غ': 'g',
    'ف': 'f',
    'ق': 'k',
    'ك': 'k',
    'ل': 'l',
    'م': 'm',
    'ن': 'n',
    'ه': 'h',
    'ة': 'a',
    'و': 'u',
    'ؤ': 'u',
    'ي': 'i',
    'ى': 'a',
    'ئ': 'i',
    'ء': '',
    'َ': '',
    'ُ': '',
    'ِ': '',
    'ْ': '',
    'ّ': '',
    'ً': '',
    'ٌ': '',
    'ٍ': '',
  };

  List<SentenceSearchHit> search(
    String query, {
    int limit = 20,
  }) {
    final normalizedQuery = _normalizeSearch(query);
    if (normalizedQuery.isEmpty) return const <SentenceSearchHit>[];

    final cappedLimit = limit.clamp(1, 100).toInt();
    final hits = <SentenceSearchHit>[];

    for (final sentence in _sentences) {
      var bestScore = 0.0;
      for (final candidate in _candidateTexts(sentence)) {
        final normalizedCandidate = _normalizeSearch(candidate);
        if (normalizedCandidate.isEmpty) continue;
        final score = _score(normalizedQuery, normalizedCandidate);
        if (score > bestScore) bestScore = score;
        if (bestScore >= .999) break;
      }

      if (bestScore >= .42) {
        hits.add(SentenceSearchHit(sentence: sentence, score: bestScore));
      }
    }

    hits.sort((left, right) {
      final scoreOrder = right.score.compareTo(left.score);
      if (scoreOrder != 0) return scoreOrder;
      return left.sentence.id.compareTo(right.sentence.id);
    });

    return List<SentenceSearchHit>.unmodifiable(hits.take(cappedLimit));
  }

  static Iterable<String> _candidateTexts(SentenceEntry sentence) sync* {
    yield sentence.german;
    yield sentence.translationAr;
    yield* sentence.phoneticAliases;

    for (final lexeme in sentence.lexicon) {
      yield lexeme.lemma;
      yield* lexeme.forms;
      yield* lexeme.phoneticAliases;
    }
  }

  static double _score(String query, String candidate) {
    if (candidate.isEmpty) return 0;
    if (query == candidate) return 1;
    if (candidate.contains(query)) return .96;

    final queryTokens = query.split(' ');
    final candidateTokens = candidate.split(' ');
    var similarityTotal = 0.0;
    var covered = 0;

    for (final queryToken in queryTokens) {
      var best = 0.0;
      for (final candidateToken in candidateTokens) {
        final similarity = _similarity(queryToken, candidateToken);
        if (similarity > best) best = similarity;
        if (best == 1) break;
      }
      similarityTotal += best;
      if (best >= .72) covered += 1;
    }

    final average = similarityTotal / queryTokens.length;
    final coverage = covered / queryTokens.length;
    final prefixBonus = candidateTokens.isNotEmpty &&
            candidateTokens.first.startsWith(queryTokens.first)
        ? .04
        : 0.0;

    return (average * .78 + coverage * .18 + prefixBonus)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _similarity(String left, String right) {
    if (left == right) return 1;
    if (left.isEmpty || right.isEmpty) return 0;

    final longest = left.length > right.length ? left.length : right.length;
    final distance = _levenshtein(left, right);
    return (1 - (distance / longest)).clamp(0.0, 1.0).toDouble();
  }

  static int _levenshtein(String left, String right) {
    var previous = List<int>.generate(right.length + 1, (index) => index);

    for (var row = 1; row <= left.length; row++) {
      final current = <int>[row];
      for (var column = 1; column <= right.length; column++) {
        final substitution = previous[column - 1] +
            (left[row - 1] == right[column - 1] ? 0 : 1);
        final insertion = current[column - 1] + 1;
        final deletion = previous[column] + 1;

        var best = substitution;
        if (insertion < best) best = insertion;
        if (deletion < best) best = deletion;
        current.add(best);
      }
      previous = current;
    }

    return previous.last;
  }

  static String _normalizeSearch(String value) {
    var normalized = value.toLowerCase();
    normalized = normalized
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');

    final buffer = StringBuffer();
    for (final rune in normalized.runes) {
      final character = String.fromCharCode(rune);
      buffer.write(_arabicToLatin[character] ?? character);
    }

    normalized = buffer.toString().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }
}

@Deprecated('Use SentenceFuzzySearchService instead.')
final class FuzzySentenceSearch {
  FuzzySentenceSearch(Iterable<SentenceEntry> sentences)
      : _delegate = SentenceFuzzySearchService(sentences);

  final SentenceFuzzySearchService _delegate;

  List<SentenceSearchHit> search(
    String query, {
    int limit = 20,
  }) =>
      _delegate.search(query, limit: limit);
}
