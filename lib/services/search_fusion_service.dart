import 'dart:async';

import 'fts_search_service.dart';

/// Async, bounded search contract for one already-mounted, local language pack.
/// Sqflite performs SQL work asynchronously; this service never scans pack files.
typedef MountedPackSearch = Future<List<Map<String, dynamic>>> Function(
  String query,
  String languageCode,
  int limit,
);

class FusedSearchHit {
  const FusedSearchHit({
    required this.key,
    required this.word,
    required this.score,
    required this.matchTier,
    required this.contributingPacks,
  });

  /// Normalized language plus normalized lemma: homographs in different
  /// languages are intentionally kept separate.
  final String key;
  final Map<String, dynamic> word;
  final double score;
  final int matchTier;
  final int contributingPacks;
}

class SearchFusionPage {
  const SearchFusionPage({
    required this.pageIndex,
    required this.items,
    required this.totalHits,
    required this.isComplete,
  });

  /// Before completion, page zero is a replaceable ranked snapshot.
  /// After completion, pages are emitted in ascending order.
  final int pageIndex;
  final List<FusedSearchHit> items;
  final int totalHits;
  final bool isComplete;
}

class _PackAnswer {
  const _PackAnswer(this.languageCode, this.rows);
  final String languageCode;
  final List<Map<String, dynamic>> rows;
}

class _AccumulatedHit {
  _AccumulatedHit(this.key, this.word, this.matchTier);
  final String key;
  Map<String, dynamic> word;
  int matchTier;
  double score = 0;
  final Set<String> packs = <String>{};
}

/// Reciprocal Rank Fusion (RRF k=60), with semantic tier ordering:
/// exact active-language surface > lemma > cross-language/translation > other.
///
/// Each ready pack updates page zero without waiting for slow packs. There is no
/// 15 ms guarantee: the first emission depends on actual SQLite I/O latency.
/// Late results can reorder earlier snapshots; only completed pages are stable.
class SearchFusionService {
  SearchFusionService({MountedPackSearch? search, FtsSearchService? fts})
      : _search = search ??
            ((query, languageCode, limit) =>
                (fts ?? FtsSearchService()).searchDictionary(
                  query,
                  languageCode,
                  limit: limit,
                ));

  static const int rrfK = 60;
  final MountedPackSearch _search;
  int _searchGeneration = 0;

  Stream<SearchFusionPage> search({
    required String query,
    required String activeLanguageCode,
    required Iterable<String> mountedLanguages,
    int pageSize = 20,
    int perPackLimit = 80,
  }) async* {
    final currentGeneration = ++_searchGeneration;
    if (pageSize < 1 || pageSize > 100) {
      throw RangeError.range(pageSize, 1, 100, 'pageSize');
    }
    if (perPackLimit < pageSize || perPackLimit > 100) {
      throw RangeError.range(perPackLimit, pageSize, 100, 'perPackLimit');
    }
    final active = _normalizeCode(activeLanguageCode);
    final term = query.trim();
    if (term.isEmpty || term.runes.length > 30) {
      yield const SearchFusionPage(
        pageIndex: 0,
        items: <FusedSearchHit>[],
        totalHits: 0,
        isComplete: true,
      );
      return;
    }
    final languages = <String>{};
    for (final language in mountedLanguages) {
      final code = _normalizeCode(language);
      if (code == active) {
        languages.add(code);
      }
    }
    if (languages.isEmpty) {
      yield const SearchFusionPage(
        pageIndex: 0,
        items: <FusedSearchHit>[],
        totalHits: 0,
        isComplete: true,
      );
      return;
    }

    final events = StreamController<_PackAnswer>();
    final completed = <Future<void>>[];
    for (final language in languages) {
      // Start all requests without awaiting one pack before launching the next.
      final task = Future<void>.sync(() async {
        List<Map<String, dynamic>> rows;
        try {
          rows = await _search(term, language, perPackLimit);
        } catch (_) {
          // A corrupt, unmounted or busy optional pack must not block others.
          rows = <Map<String, dynamic>>[];
        }
        if (!events.isClosed) events.add(_PackAnswer(language, rows));
      });
      completed.add(task);
    }
    unawaited(Future.wait(completed).then((_) => events.close()));

    final responses = <String, List<Map<String, dynamic>>>{};
    await for (final answer in events.stream) {
      if (currentGeneration != _searchGeneration) return;

      responses[answer.languageCode] = answer.rows;
      final ranked = _fuse(responses, active, term.toLowerCase());
      final complete = responses.length == languages.length;
      final count = complete ? (ranked.length + pageSize - 1) ~/ pageSize : 1;
      for (var page = 0; page < count; page++) {
        final start = page * pageSize;
        final end = (start + pageSize < ranked.length)
            ? start + pageSize
            : ranked.length;
        yield SearchFusionPage(
          pageIndex: page,
          items: List<FusedSearchHit>.unmodifiable(
            ranked.sublist(start < end ? start : end, end),
          ),
          totalHits: ranked.length,
          isComplete: complete,
        );
      }
      if (count == 0) {
        yield SearchFusionPage(
          pageIndex: 0,
          items: const <FusedSearchHit>[],
          totalHits: 0,
          isComplete: complete,
        );
      }
    }
  }

  static List<FusedSearchHit> _fuse(
    Map<String, List<Map<String, dynamic>>> responses,
    String activeLanguage,
    String query,
  ) {
    final gathered = <String, _AccumulatedHit>{};
    final sortedCodes = responses.keys.toList()..sort();
    for (final code in sortedCodes) {
      final rows = responses[code]!;
      for (var index = 0; index < rows.length; index++) {
        final row = rows[index];
        final language = _normalizeCode(
          (row['language_code'] ?? code).toString(),
        );
        // Prevent inappropriate reverse-pair result reuse by strictly scoping to the active language.
        if (language != activeLanguage) continue;

        final surface =
            (row['surface'] ?? row['display_text'] ?? '').toString().trim();
        if (surface.isEmpty) continue;
        final lemma = (row['lemma'] ?? surface).toString().trim();

        final id = (row['lexeme_id'] ?? row['id'] ?? lemma).toString();
        final key = '$language|$id';

        final translation =
            (row['translation_ar'] ?? '').toString().toLowerCase();

        final tier = surface.toLowerCase() == query
            ? 0
            : lemma.toLowerCase() == query
                ? 1
                : translation == query
                    ? 2
                    : (surface.toLowerCase().startsWith(query) || lemma.toLowerCase().startsWith(query))
                        ? 3
                        : translation.contains(query)
                            ? 4
                            : 5;

        final candidate = gathered.putIfAbsent(
          key,
          () => _AccumulatedHit(key, row, tier),
        );
        if (tier < candidate.matchTier) {
          candidate.matchTier = tier;
          candidate.word = row;
        }
        // One pack contributes at most once per deduplicated headword.
        if (candidate.packs.add(code)) {
          candidate.score += 1.0 / (rrfK + index + 1);
        }
      }
    }

    final hits = gathered.values
        .map((candidate) => FusedSearchHit(
              key: candidate.key,
              word: candidate.word,
              score: candidate.score,
              matchTier: candidate.matchTier,
              contributingPacks: candidate.packs.length,
            ))
        .toList(growable: false);
    hits.sort((a, b) {
      final tier = a.matchTier.compareTo(b.matchTier);
      if (tier != 0) return tier;
      final score = b.score.compareTo(a.score);
      return score != 0 ? score : a.key.compareTo(b.key);
    });
    return hits;
  }

  static String _normalizeCode(String code) {
    final value = code.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(value)) {
      throw ArgumentError.value(code, 'languageCode', 'Invalid language code');
    }
    return value.split('-').first;
  }
}
