import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
<<<<<<< HEAD
  group('TrieSearchEngine - J049 Bounded Multi-Script Trie & Prefix Retrieval', () {
    test('Handles Unicode and multi-byte insertion/retrieval (CJK, Emojis)', () {
      final engine = TrieSearchEngine();
      engine.insert('你好', 'id1');
      engine.insert('こんにちは', 'id2');
      engine.insert('안녕하세요', 'id3');
      engine.insert('👨‍👩‍👧‍👦 family', 'id4');

      expect(engine.searchPrefix('你'), ['id1']);
      expect(engine.searchPrefix('こん'), ['id2']);
      expect(engine.searchPrefix('안녕'), ['id3']);
      expect(engine.searchPrefix('👨‍👩‍👧‍👦'), ['id4']);
    });

    test('Normalizes Arabic (stripping tashkeel and tatweel)', () {
      final engine = TrieSearchEngine();
      // "مُحَمَّد" with tashkeel
      engine.insert('مُحَمَّد', 'id1');
      // "شـــــكراً" with tatweel
      engine.insert('شـــــكراً', 'id2');

      expect(engine.searchPrefix('محمد'), ['id1']);
      expect(engine.searchPrefix('محم'), ['id1']);
      expect(engine.searchPrefix('شكرا'), ['id2']);
    });

    test('Normalizes Hebrew (stripping niqqud)', () {
      final engine = TrieSearchEngine();
      // "שָׁלוֹם" with niqqud
      engine.insert('שָׁלוֹם', 'id1');

      expect(engine.searchPrefix('שלום'), ['id1']);
      expect(engine.searchPrefix('שלו'), ['id1']);
    });

    test('Preserves German umlauts by normalizing', () {
      final engine = TrieSearchEngine();
      engine.insert('Mädchen', 'id1');
      engine.insert('Schön', 'id2');
      engine.insert('Müll', 'id3');
      engine.insert('Straße', 'id4');

      expect(engine.searchPrefix('maedchen'), ['id1']);
      expect(engine.searchPrefix('schoen'), ['id2']);
      expect(engine.searchPrefix('muell'), ['id3']);
      expect(engine.searchPrefix('strasse'), ['id4']);
    });

    test('Bounds node count limit (maxNodes)', () {
      final engine = TrieSearchEngine(maxNodes: 5);
      // 'a' (node 2) -> 'b' (node 3) -> 'c' (node 4) -> 'd' (node 5) -> 'e' (limit reached)
      engine.insert('abcde', 'id1');
      engine.insert('fghij', 'id2'); // Won't add nodes

      // Should be able to find up to 'abcd'
      expect(engine.searchPrefix('abcd'), ['id1']);
      // Should not find 'abcde'
      expect(engine.searchPrefix('abcde'), []);
      // Should not find 'fghij'
      expect(engine.searchPrefix('f'), []);
    });

    test('Bounds prefix search results (maxResults)', () {
      final engine = TrieSearchEngine(maxResults: 2);
      engine.insert('test', 'id1');
      engine.insert('testa', 'id2');
      engine.insert('testb', 'id3');

      final results = engine.searchPrefix('test');
      expect(results.length, 2);
      expect(results, contains('id1'));
      expect(results, contains('id2'));
    });

    test('Deduplicates identical lexical IDs', () {
      final engine = TrieSearchEngine();
      engine.insert('hello', 'id1');
      engine.insert('hello', 'id1');
      engine.insert('hello world', 'id1');

      final results = engine.searchPrefix('hello');
      expect(results.length, 1);
      expect(results, ['id1']);
    });

    test('Resets the trie and tracks content version', () {
      final engine = TrieSearchEngine();
      engine.insert('apple', 'id1');
      expect(engine.searchPrefix('app'), ['id1']);

      engine.reset(contentVersion: 'v2');
      expect(engine.searchPrefix('app'), []);
      expect(engine.contentVersion, 'v2');

      engine.insert('banana', 'id2');
      expect(engine.searchPrefix('ban'), ['id2']);
    });

    test('Returns empty for non-existent prefix', () {
      final engine = TrieSearchEngine();
      engine.insert('apple', 'id1');

      expect(engine.searchPrefix('orange'), []);
    });

    test('Handles empty query safely', () {
      final engine = TrieSearchEngine();
      engine.insert('apple', 'id1');

      expect(engine.searchPrefix(''), []);
    });
  });
=======
  test('German Umlauts and Arabic combining marks use separate policies', () {
    final de = TrieSearchEngine(languageCode: 'de');
    final ar = TrieSearchEngine(languageCode: 'ar');
    de.insert('Mädchen', 'de1');
    ar.insert('مُعَلِّم', 'ar1');
    expect(de.searchPrefix('maed'), ['de1']);
    expect(de.searchPrefix('mad'), isEmpty);
    expect(ar.searchPrefix('معل'), ['ar1']);
    // A generic cross-language instance must not silently apply German rules.
    expect(TrieSearchEngine.normalizeUniversal('Mädchen'), 'mädchen');
  });

  test('Indic combining clusters, CJK and supplementary symbols survive', () {
    for (final word in ['नमस्ते', 'বাংলা', 'こんにちは', '한국어', '𠀋']) {
      final index = TrieSearchEngine(languageCode: 'und');
      expect(index.tryInsert(word, word), isTrue);
      expect(index.searchPrefix(word), [word]);
    }
  });

  test('Hebrew niqqud is stripped only with Hebrew policy', () {
    final he = TrieSearchEngine(languageCode: 'he');
    he.insert('שָׁלוֹם', '1');
    expect(he.searchPrefix('שלום'), ['1']);
    final other = TrieSearchEngine(languageCode: 'und');
    other.insert('שָׁלוֹם', '1');
    expect(other.searchPrefix('שלום'), isEmpty);
  });

  test('failed capacity insert never leaks a partially indexed word', () {
    final index = TrieSearchEngine(maxNodes: 5);
    expect(index.tryInsert('longword', '1'), isFalse);
    expect(index.searchPrefix('long'), isEmpty);
    expect(index.currentNodeCount, 1);
    expect(index.tryInsert('four', '2'), isTrue);
    expect(index.searchPrefix('four'), ['2']);
  });

  test('limits are exact and failed overflow does not produce partial prefix', () {
    final index = TrieSearchEngine(
      maxNodes: 40, maxResultsPerNode: 2, maxSearchResults: 1,
    );
    expect(index.tryInsert('test1', '1'), isTrue);
    expect(index.tryInsert('test2', '2'), isTrue);
    expect(index.tryInsert('test3', '3'), isFalse);
    expect(index.searchPrefix('test'), ['1']);
    expect(index.searchPrefix('test3'), isEmpty);
    index.clear();
    expect(index.searchPrefix('test'), isEmpty);
  });

  test('pair-scoped indexes refuse other pair IDs', () {
    final index = TrieSearchEngine(
      languageCode: 'ar', directedPairKey: 'de_ar_1.0.0',
    );
    expect(index.tryInsert('كتاب', '1', pairKey: 'de_ar_1.0.0'), isTrue);
    expect(index.tryInsert('كتاب', '2', pairKey: 'ar_de_1.0.0'), isFalse);
    expect(index.searchPrefix('كت', pairKey: 'ar_de_1.0.0'), isEmpty);
    expect(index.searchPrefix('كت', pairKey: 'de_ar_1.0.0'), ['1']);
  });

  test('oversized input and unsafe constructor limits fail safely', () {
    expect(() => TrieSearchEngine(maxNodes: 1), throwsArgumentError);
    final index = TrieSearchEngine(maxWordGraphemes: 3);
    expect(index.tryInsert('abcdef', '1'), isFalse);
    expect(index.searchPrefix('abcdef'), isEmpty);
    expect(index.currentNodeCount, 1);
    expect(index.searchPrefix(''), isEmpty);
  });
  test('rejects huge grapheme payloads and huge IDs before indexing', () {
    final index = TrieSearchEngine();
    final massiveCluster = 'e' + List<String>.filled(2300, '\u0301').join();
    final enormousId = List<String>.filled(200, 'x').join();
    expect(index.tryInsert(massiveCluster, '1'), isFalse);
    expect(index.tryInsert('abc', enormousId), isFalse);
    expect(index.searchPrefix(massiveCluster), isEmpty);
    expect(index.currentNodeCount, 1);
  });

>>>>>>> pr-179
}
