import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/languages/german/german_grammar_provider.dart';

void main() {
  group('Language Intelligence Decoupling Tests', () {
    final germanProvider = GermanGrammarProvider.instance;

    test('GermanGrammarProvider يستنتج الجنس النحوي للأدوات واللواحق بشكل معزول', () {
      expect(germanProvider.determineGender('Tisch', article: 'der'), GrammaticalGender.masculine);
      expect(germanProvider.determineGender('Zeitung'), GrammaticalGender.feminine); // لاحقة ung
      expect(germanProvider.determineGender('Mädchen'), GrammaticalGender.neuter);   // لاحقة chen
    });
  });
}
