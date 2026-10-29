import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Prefix retrieval test', () {
    final engine = TrieSearchEngine();
    engine.insert('Apfel', 'lex.de.apfel');
    engine.insert('Äpfel', 'lex.de.aepfel');
    engine.insert('Apfelsaft', 'lex.de.apfelsaft');

    final results = engine.searchPrefix('apfe');
    expect(results, contains('lex.de.apfel'));
    expect(results, contains('lex.de.apfelsaft'));
  });

  test('Empty query returns empty results', () {
    final engine = TrieSearchEngine();
    engine.insert('Apfel', 'lex.de.apfel');
    expect(engine.searchPrefix(''), isEmpty);
  });
}
