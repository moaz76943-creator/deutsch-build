import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
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

}
