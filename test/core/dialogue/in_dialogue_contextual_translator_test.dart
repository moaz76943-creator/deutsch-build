import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/in_dialogue_contextual_translator.dart';

void main() {
  group('InDialogueContextualTranslator Tests', () {
    const translator = InDialogueContextualTranslator();

    test('Resolves inflected noun with clean punctuation stripping', () {
      final gloss = translator.lookupToken('Speisekarte,', surroundingSentence: 'Hier ist die Speisekarte, bitte.');

      expect(gloss.lemma, equals('die Speisekarte'));
      expect(gloss.partOfSpeech, contains('Noun'));
      expect(gloss.translation, equals('menu'));
      expect(gloss.phoneticIpa, contains('ˈʃpaɪ̯zəˌkaʁtə'));
    });

    test('Resolves irregular past verb "ging" to infinitive lemma "gehen"', () {
      final gloss = translator.lookupToken('ging');

      expect(gloss.lemma, equals('gehen'));
      expect(gloss.partOfSpeech, contains('Verb'));
      expect(gloss.grammarNote, contains('Präteritum'));
    });

    test('Serializes to structured JSON for tap tooltip UI', () {
      final gloss = translator.lookupToken('Rechnung');
      final json = gloss.toJson();

      expect(json['lemma'], equals('die Rechnung'));
      expect(json['translation'], equals('bill / check'));
    });
  });
}
