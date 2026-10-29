import '../core/content_contract.dart';
import '../language/language_text_normalizer.dart';
import 'verb_index.dart';

/// V122 search intelligence: exact, semantic-ish token, morphology and fuzzy lookup.
class SearchIndex<T extends LearningContent> {
  final List<T> _items;
  final VerbIndex _verbIndex;
  final LanguageTextNormalizer _textNormalizer;

  late final Map<String, List<T>> _sourceExact = _buildExact(
    _items,
    (x) => x.sourceText,
  );
  late final Map<String, List<T>> _translationExact = _buildExact(
    _items,
    (x) => x.translationText,
  );
  late final Map<String, List<T>> _tokenIndex = _buildTokens(_items);
  late final Map<String, List<T>> _topicGroups = _buildGroups(
    _items,
    (x) => x.topic,
  );
  late final Map<String, List<T>> _skillGroups = _buildGroups(
    _items,
    (x) => x.skill,
  );
  final Map<String, _Entry<T>> _entryCache = <String, _Entry<T>>{};
  late final Map<String, List<_Entry<T>>> _trigramIndex = _buildTrigrams(
    _items
        .map((item) => _Entry<T>(item, _textNormalizer))
        .toList(growable: false),
  );

  SearchIndex(this._items, this._verbIndex, this._textNormalizer);

  List<T> search(String query, {int limit = 60, String? skill}) =>
      searchDetailed(
        query,
        limit: limit,
        skill: skill,
      ).map((x) => x.item).toList(growable: false);

  List<SearchResult<T>> searchDetailed(
    String query, {
    int limit = 60,
    String? skill,
  }) {
    final q = _textNormalizer.answer(query);
    final cap = limit.clamp(1, 200).toInt();
    final eligible = (T x) => skill == null || x.skill == skill;
    if (q.isEmpty) {
      return _items
          .where(eligible)
          .take(cap)
          .map((item) => SearchResult(item, 1, 'browse', 'عرض المحتوى'))
          .toList(growable: false);
    }

    final scored = <String, SearchResult<T>>{};
    void add(T item, int score, String type, String label) {
      if (!eligible(item)) return;
      final existing = scored[item.id];
      if (existing == null || score > existing.score) {
        scored[item.id] = SearchResult(item, score, type, label);
      }
    }

    final exactResults = <SearchResult<T>>[];
    for (final item in _sourceExact[q] ?? <T>[]) {
      if (eligible(item))
        exactResults.add(
          SearchResult(item, 1000, 'exactGerman', 'مطابقة ألمانية كاملة'),
        );
    }
    for (final item in _translationExact[q] ?? <T>[]) {
      if (eligible(item))
        exactResults.add(
          SearchResult(item, 940, 'exactArabic', 'مطابقة عربية كاملة'),
        );
    }
    if (exactResults.length >= cap)
      return exactResults.take(cap).toList(growable: false);

    for (final item in exactResults) {
      add(item.item, item.score, item.matchType, item.label);
    }

    final verbInfinitives = _verbIndex.infinitivesFor(q);
    for (final infinitive in verbInfinitives) {
      for (final item
          in _sourceExact[_textNormalizer.answer(infinitive)] ?? <T>[]) {
        add(item, 920, 'verbForm', 'صيغة فعل → المصدر');
      }
    }

    if (scored.length >= cap) {
      final result = scored.values.toList(growable: false);
      return result.take(cap).toList(growable: false);
    }

    final queryTokens = _tokens(q);
    final candidates = <T>{};
    for (final token in queryTokens) {
      candidates.addAll(_tokenIndex[token] ?? <T>[]);
    }
    // Do not fall back to the full corpus here: a miss should move to the
    // bounded fuzzy stage instead of materializing thousands of _Entry objects.
    for (final item in candidates) {
      if (!eligible(item)) continue;
      final entry = _entryCache[item.id] ??= _Entry<T>(item, _textNormalizer);
      final scoredEntry = entry.scoreDetailed(q);
      if (scoredEntry.score > 0)
        add(item, scoredEntry.score, scoredEntry.type, scoredEntry.label);
    }

    // Fuzzy fallback is intentionally bounded to avoid O(N²) behavior for ordinary searches.
    if (scored.length < cap) {
      for (final entry in _fuzzyCandidates(q)) {
        if (!eligible(entry.item) || scored.containsKey(entry.item.id))
          continue;
        final distance = _bestFuzzyDistance(q, entry.searchTerms);
        if (distance <= _fuzzyLimit(q)) {
          final score = 320 - distance * 55 + _lengthProximity(q, entry.source);
          add(entry.item, score, 'fuzzy', 'اقتراح تهجئة قريب');
        }
      }
    }

    final result = scored.values.toList(growable: false)
      ..sort((a, b) {
        final score = b.score.compareTo(a.score);
        if (score != 0) return score;
        return a.item.sourceText.compareTo(b.item.sourceText);
      });
    return result.take(cap).toList(growable: false);
  }

  List<String> suggestions(String query, {int limit = 5}) {
    final q = _textNormalizer.answer(query);
    if (q.isEmpty) return const <String>[];
    return searchDetailed(q, limit: limit * 2)
        .where((r) => r.matchType == 'fuzzy')
        .map((r) => r.item.sourceText)
        .toSet()
        .take(limit.clamp(1, 20).toInt())
        .toList(growable: false);
  }

  Map<String, List<T>> get topicGroups => _topicGroups;
  Map<String, List<T>> get skillGroups => _skillGroups;

  static Map<String, List<E>> _buildGroups<E extends LearningContent>(
    List<E> items,
    String Function(E) key,
  ) {
    final map = <String, List<E>>{};
    for (final item in items) {
      (map[key(item)] ??= <E>[]).add(item);
    }
    return map;
  }

  Map<String, List<E>> _buildExact<E extends LearningContent>(
    List<E> items,
    String Function(E) key,
  ) {
    final map = <String, List<E>>{};
    for (final item in items) {
      final value = _textNormalizer.answer(key(item));
      if (value.isNotEmpty) (map[value] ??= <E>[]).add(item);
    }
    return map;
  }

  Iterable<_Entry<T>> _fuzzyCandidates(String q) {
    const maxCandidates = 160;
    final grams = trigramsFor(q);
    if (grams.isEmpty) {
      final maxDistance = _fuzzyLimit(q);
      final first = q.isEmpty ? '' : q[0];
      final candidates = <_Entry<T>>[];
      for (final item in _items) {
        if (first.isNotEmpty &&
            !_textNormalizer.answer(item.sourceText).startsWith(first))
          continue;
        if ((_textNormalizer.answer(item.sourceText).length - q.length).abs() >
            maxDistance + 1) continue;
        candidates.add(
          _entryCache[item.id] ??= _Entry<T>(item, _textNormalizer),
        );
        if (candidates.length >= _fuzzyCandidateCap(q)) break;
      }
      return candidates;
    }

    final candidates = <_Entry<T>>{};
    for (final gram in grams) {
      for (final entry in _trigramIndex[gram] ?? <_Entry<T>>[]) {
        candidates.add(entry);
        if (candidates.length >= maxCandidates) break;
      }
      if (candidates.length >= maxCandidates) break;
    }
    return candidates;
  }

  int _fuzzyCandidateCap(String q) => q.length <= 4 ? 80 : 160;

  static Map<String, List<_Entry<E>>> _buildTrigrams<E extends LearningContent>(
    List<_Entry<E>> entries,
  ) {
    final map = <String, List<_Entry<E>>>{};
    for (final entry in entries) {
      for (final term in entry.searchTerms) {
        for (final gram in trigramsFor(term)) {
          (map[gram] ??= <_Entry<E>>[]).add(entry);
        }
      }
    }
    return map;
  }

  Map<String, List<E>> _buildTokens<E extends LearningContent>(List<E> items) {
    final map = <String, List<E>>{};
    for (final item in items) {
      final german = _tokens(_textNormalizer.answer(item.sourceText));
      final arabic = _tokens(_textNormalizer.answer(item.translationText));
      final plural = _tokens(_textNormalizer.answer(item.pluralForm));
      for (final token in {...german, ...arabic, ...plural}) {
        (map[token] ??= <E>[]).add(item);
      }
    }
    return map;
  }
}

class SearchResult<T extends LearningContent> {
  final T item;
  final int score;
  final String matchType;
  final String label;
  const SearchResult(this.item, this.score, this.matchType, this.label);

  String get level => score >= 900
      ? 'high'
      : score >= 500
          ? 'medium'
          : 'low';
}

class _EntryScore {
  final int score;
  final String type;
  final String label;
  const _EntryScore(this.score, this.type, this.label);
}

class _Entry<T extends LearningContent> {
  final T item;
  final String source,
      translation,
      sentence,
      sentenceAr,
      topic,
      grammaticalMarker,
      plural;
  final LanguageTextNormalizer _textNormalizer;
  final Set<String> sourceTokens, translationTokens;
  final Set<String> searchTerms;

  _Entry(this.item, this._textNormalizer)
      : source = _textNormalizer.answer(item.sourceText),
        translation = _textNormalizer.answer(item.translationText),
        sentence = _textNormalizer.answer(item.exampleText),
        sentenceAr = _textNormalizer.answer(item.exampleTranslationText),
        topic = _textNormalizer.answer(item.topic),
        grammaticalMarker = _textNormalizer.answer(item.grammaticalMarker),
        plural = _textNormalizer.answer(item.pluralForm),
        sourceTokens = _tokens(_textNormalizer.answer(item.sourceText)),
        translationTokens =
            _tokens(_textNormalizer.answer(item.translationText)),
        searchTerms = {
          _textNormalizer.answer(item.sourceText),
          _textNormalizer.answer(item.translationText),
          _textNormalizer.answer(item.pluralForm),
          ...item.acceptedForms.map(_textNormalizer.answer),
        }..removeWhere((x) => x.isEmpty);

  int tokenScore(String q) => scoreDetailed(q).score;

  _EntryScore scoreDetailed(String q) {
    if (source == q)
      return const _EntryScore(1000, 'exactGerman', 'مطابقة ألمانية كاملة');
    if ('$grammaticalMarker $source' == q)
      return const _EntryScore(980, 'article', 'مطابقة Artikel + كلمة');
    if ('$source $plural' == q && plural.isNotEmpty)
      return const _EntryScore(970, 'plural', 'مطابقة المفرد + الجمع');
    if (plural == q)
      return const _EntryScore(900, 'plural', 'مطابقة صيغة الجمع');
    if (item.acceptedForms.any((x) => _textNormalizer.answer(x) == q))
      return const _EntryScore(890, 'accepted', 'إجابة بديلة معتمدة');
    if (source.startsWith(q))
      return const _EntryScore(850, 'prefix', 'مطابقة بداية الكلمة');
    if (source.contains(q))
      return const _EntryScore(720, 'containsGerman', 'الكلمة تحتوي البحث');
    if (translation == q)
      return const _EntryScore(940, 'exactArabic', 'مطابقة عربية كاملة');
    if (translation.contains(q))
      return const _EntryScore(610, 'containsArabic', 'العربية تحتوي البحث');
    if (plural.contains(q))
      return const _EntryScore(520, 'containsPlural', 'البحث داخل الجمع');
    if (sentence.contains(q) || sentenceAr.contains(q))
      return const _EntryScore(410, 'example', 'مطابقة داخل المثال');
    if (topic.contains(q))
      return const _EntryScore(250, 'topic', 'مطابقة الموضوع');
    final queryTokens = _tokens(q);
    if (queryTokens.isEmpty) return const _EntryScore(0, 'none', '');
    final germanHits = queryTokens.where(sourceTokens.contains).length;
    final arabicHits = queryTokens.where(translationTokens.contains).length;
    final hits = germanHits + arabicHits;
    if (hits == 0) return const _EntryScore(0, 'none', '');
    final coverage = hits / queryTokens.length;
    if (coverage == 1 && germanHits == queryTokens.length)
      return const _EntryScore(560, 'tokenGerman', 'مطابقة كلمات ألمانية');
    if (coverage >= .5 && germanHits > 0)
      return const _EntryScore(
        360,
        'tokenMixed',
        'مطابقة جزئية متعددة الكلمات',
      );
    return const _EntryScore(180, 'tokenArabic', 'مطابقة كلمات عربية');
  }
}

int _bestFuzzyDistance(String q, Iterable<String> terms) {
  var best = 999;
  for (final term in terms) {
    final d = _editDistance(q, term);
    if (d < best) best = d;
    if (best == 0) break;
  }
  return best;
}

int _fuzzyLimit(String q) => q.length <= 4
    ? 1
    : q.length <= 8
        ? 2
        : 3;

int _lengthProximity(String a, String b) =>
    (10 - (a.length - b.length).abs()).clamp(0, 10).toInt();

int _editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  if (a.length < b.length) return _editDistance(b, a);
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0);
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = [
        current[j - 1] + 1,
        previous[j] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    previous = current;
  }
  return previous[b.length];
}

Set<String> _tokens(String value) => value
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((x) => x.isNotEmpty)
    .toSet();

Set<String> trigramsFor(String value) {
  if (value.length < 3) return const <String>{};
  final grams = <String>{};
  for (var i = 0; i <= value.length - 3; i++) {
    grams.add(value.substring(i, i + 3));
  }
  return grams;
}
