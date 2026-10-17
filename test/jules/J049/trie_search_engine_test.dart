import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
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
}
