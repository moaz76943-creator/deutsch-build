import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  test('Arabic normalization and search', () {
    final engine = TrieSearchEngine();
    engine.insert('مُعَلِّم', 'lex.ar.teacher');

    // Search without diacritics
    expect(engine.searchPrefix('معل'), contains('lex.ar.teacher'));
  });

  test('Hebrew normalization and search', () {
    final engine = TrieSearchEngine();
    engine.insert('שָׁלוֹם', 'lex.he.shalom'); // Shalom with niqqud

    expect(engine.searchPrefix('שלו'), contains('lex.he.shalom'));
  });

  test('Clear functionality', () {
    final engine = TrieSearchEngine();
    engine.insert('Apfel', 'lex.de.apfel');
    expect(engine.searchPrefix('apf').length, 1);

    engine.clear();
    expect(engine.searchPrefix('apf').length, 0);
  });

  test('CJK prefix retrieval', () {
    final engine = TrieSearchEngine();
    engine.insert('日本語', 'lex.ja.japanese');
    expect(engine.searchPrefix('日本'), contains('lex.ja.japanese'));
  });
}
