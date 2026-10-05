import 'dart:io';

import 'package:deutsch_bilarabi/features/grammar/data/ar_de_grammar_explain_why.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AR-DE Explain Why catalog is asset-backed, complete, and cached', () async {
    var reads = 0;
    Future<String> readText(String path) async {
      reads += 1;
      return File(path).readAsString();
    }

    final engine = await ArDeGrammarExplainWhyCatalog.load(
      readText: readText,
    );
    final second = await ArDeGrammarExplainWhyCatalog.load(
      readText: readText,
    );

    expect(identical(engine, second), isTrue);
    expect(reads, 1);
    expect(engine.supports('grammar.input.incomplete'), isTrue);
    expect(engine.supports('grammar.word_order.main_v2'), isTrue);
    expect(engine.supports('grammar.word_order.subordinate_final'), isTrue);
    expect(engine.supports('grammar.verb.conjugation'), isTrue);
    expect(engine.supports('grammar.case.direct_object'), isTrue);
    expect(engine.supports('grammar.case.preposition'), isTrue);
    expect(engine.supports('lexicon.verb.agreement'), isTrue);
    expect(engine.supports('lexicon.grammatical_marker'), isTrue);
    expect(engine.supports('lexicon.plural_form'), isTrue);
    expect(engine.supports('lexicon.usage_example'), isTrue);
    expect(engine.supports('lexicon.meaning'), isTrue);
  });
}
