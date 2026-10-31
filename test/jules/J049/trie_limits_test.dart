import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Trie limits are bounded', () {
    final engine = TrieSearchEngine();
    for(int i = 0; i < 1000; i++) {
        engine.insert('word$i', 'lex.de.$i');
    }
    final results = engine.searchPrefix('wor');
    // Verify limits are supported and enforced
    expect(results.length, lessThan(1000));
  });
}
