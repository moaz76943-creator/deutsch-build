import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  group('TrieSearchEngine', () {
    late TrieSearchEngine engine;

    setUp(() {
      engine = TrieSearchEngine(maxNodes: 100, maxResults: 5);
    });

    test('Normalize Universal - Latin & German', () {
      expect(TrieSearchEngine.normalizeUniversal('Mädchen'), 'maedchen');
      expect(TrieSearchEngine.normalizeUniversal('groß'), 'gross');
      expect(TrieSearchEngine.normalizeUniversal('Öl'), 'oel');
      expect(TrieSearchEngine.normalizeUniversal('Über'), 'ueber');
      expect(TrieSearchEngine.normalizeUniversal('café'), 'cafe');
    });

    test('Normalize Universal - Arabic', () {
      expect(TrieSearchEngine.normalizeUniversal('مُحَمَّد'), 'محمد');
      expect(TrieSearchEngine.normalizeUniversal('بـيـت'), 'بيت');
      expect(TrieSearchEngine.normalizeUniversal('أإآ'), 'ااا');
      expect(TrieSearchEngine.normalizeUniversal('مدرسة'), 'مدرسه');
      expect(TrieSearchEngine.normalizeUniversal('هدى'), 'هدي');
    });

    test('Normalize Universal - Hebrew', () {
      expect(TrieSearchEngine.normalizeUniversal('שָׁלוֹם'), 'שלום');
      expect(TrieSearchEngine.normalizeUniversal('בְּרֵאשִׁית'), 'בראשית');
    });

    test('Insert and search basic', () {
      engine.insert('hello', 'id1');
      engine.insert('hell', 'id2');
      engine.insert('helicopter', 'id3');

      expect(engine.searchPrefix('hel'), containsAll(['id1', 'id2', 'id3']));
      expect(engine.searchPrefix('hell'), containsAll(['id1', 'id2']));
      expect(engine.searchPrefix('hello'), ['id1']);
      expect(engine.searchPrefix('heli'), ['id3']);
      expect(engine.searchPrefix('x'), isEmpty);
    });

    test('Empty queries', () {
      engine.insert('', 'id1');
      expect(engine.searchPrefix(''), isEmpty);
    });

    test('Bounds and Limits', () {
      for (int i = 0; i < 10; i++) {
        engine.insert('apple', 'id$i');
      }
      final res = engine.searchPrefix('app');
      expect(res.length, 5); // maxResults is 5
      expect(res.toSet().length, 5); // no duplicates
    });

    test('Node Limit', () {
      final boundedEngine = TrieSearchEngine(maxNodes: 10, maxResults: 10);
      boundedEngine.insert('abcdefghijklmnopqrstuvwxyz', 'id1');
      // Root is 1 node. 'abcdefghi' uses 9 nodes. Total 10 nodes.
      // Search for 'abcdefghi' should return 'id1'
      expect(boundedEngine.searchPrefix('abcdefghi'), ['id1']);
      // Should not find further because maxNodes bounded
      expect(boundedEngine.searchPrefix('abcdefghij'), isEmpty);
    });

    test('Duplicate insertions', () {
      engine.insert('duplicate', 'id1');
      engine.insert('duplicate', 'id1');
      expect(engine.searchPrefix('dup'), ['id1']);
    });

    test('Clear and stale state', () {
      engine.clear(contentVersion: 'v1', languagePair: 'en-de');
      engine.insert('test', 'id1');
      expect(engine.searchPrefix('test'), ['id1']);

      expect(engine.isStale('v1', 'en-de'), isFalse);
      expect(engine.isStale('v2', 'en-de'), isTrue);

      engine.clear(contentVersion: 'v2', languagePair: 'en-fr');
      expect(engine.searchPrefix('test'), isEmpty);
    });

    test('Unicode correctness (CJK/Emojis)', () {
      // 𪜀 is a surrogate pair in UTF-16
      engine.insert('𪜀𪜁', 'id1');
      // When iterating by runes, 𪜀 is preserved as 1 character (2 utf-16 code units)
      // but Dart String.fromCharCode(rune) creates a String.
      expect(engine.searchPrefix('𪜀'), ['id1']);
    });

    test('Search Prefix Case-Insensitive', () {
      engine.insert('Mädchen', 'id1');
      expect(engine.searchPrefix('Maed'), ['id1']);
      expect(engine.searchPrefix('mÄd'), ['id1']);
    });

    test('Measure lookup latency', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        engine.insert('word$i', 'id$i');
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      stopwatch.reset();
      stopwatch.start();
      for (int i = 0; i < 1000; i++) {
        engine.searchPrefix('word$i');
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
