import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Trie memory and performance', () {
    final engine = TrieSearchEngine(maxNodes: 500000, maxSearchResults: 10);

    final stopwatch = Stopwatch()..start();
    // Insert many words with common prefixes
    for (int i = 0; i < 10000; i++) {
      engine.insert('prefix$i', 'lex.test.$i');
    }
    stopwatch.stop();
    print('Insert time: ${stopwatch.elapsedMilliseconds} ms');

    stopwatch.reset();
    stopwatch.start();
    final results = engine.searchPrefix('pref');
    stopwatch.stop();
    print('Search time: ${stopwatch.elapsedMicroseconds} us');

    expect(results.length, equals(10)); // Bounded by maxResults
  });
}
