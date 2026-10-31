import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Trie deduplicates identical lexical IDs', () {
    final engine = TrieSearchEngine();
    engine.insert('Apfel', 'lex.de.apfel');
    engine.insert('Äpfel', 'lex.de.apfel'); // same lexical ID
    engine.insert('apfel', 'lex.de.apfel'); // same lexical ID

    final results = engine.searchPrefix('apfe');
    expect(results.length, 1);
    expect(results.first, 'lex.de.apfel');
  });
}
