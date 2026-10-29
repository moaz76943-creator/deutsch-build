import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Trie supports reset and content version tracking', () {
    final engine = TrieSearchEngine();
    engine.insert('Auto', 'lex.de.auto');
    expect(engine.searchPrefix('auto').length, 1);
    expect(engine.contentVersion, 0);

    engine.reset(1);
    expect(engine.searchPrefix('auto').length, 0);
    expect(engine.contentVersion, 1);
    expect(engine.currentNodeCount, 1);
  });
}
