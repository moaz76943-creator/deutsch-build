import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Prefix collisions are handled correctly', () {
    final engine = TrieSearchEngine();
    engine.insert('Auto', 'lex.de.auto');
    engine.insert('Autobahn', 'lex.de.autobahn');
    engine.insert('Automobil', 'lex.de.automobil');

    final results = engine.searchPrefix('auto');
    expect(results.length, 3);
    expect(results, containsAll(['lex.de.auto', 'lex.de.autobahn', 'lex.de.automobil']));
  });

  test('Unicode boundaries are preserved', () {
    final engine = TrieSearchEngine();
    // Use multi-byte emojis or characters to verify runes are used properly
    engine.insert('Familie👨‍👩‍👧‍👦', 'lex.test.family');
    engine.insert('Familien', 'lex.test.families');

    expect(engine.searchPrefix('Familie').length, 2);
    expect(engine.searchPrefix('Familie👨‍👩‍👧‍👦').length, 1);
  });
}
