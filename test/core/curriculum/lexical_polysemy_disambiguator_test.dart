import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/lexical_polysemy_disambiguator.dart';

void main() {
  group('LexicalPolysemyDisambiguator Unit Tests (N036)', () {
    final disambiguator = LexicalPolysemyDisambiguator();

    test('Disambiguates Bank as financial institution when Geld/Konto are present', () {
      final sense = disambiguator.disambiguate(
        word: 'Bank',
        contextSentence: 'Er überweist das Geld direkt auf sein neues Konto bei der Bank.',
      );

      expect(sense, isNotNull);
      expect(sense!.senseId, equals('bank_financial'));
      expect(sense.definition, contains('Financial institution'));
    });

    test('Disambiguates Bank as park seating bench when sitzen/Park are present', () {
      final sense = disambiguator.disambiguate(
        word: 'Bank',
        contextSentence: 'Nach dem langen Spaziergang ruhen wir uns auf der grünen Bank im Park aus.',
      );

      expect(sense, isNotNull);
      expect(sense!.senseId, equals('bank_seating'));
      expect(sense.definition, contains('bench'));
    });

    test('Disambiguates Schloss as lock vs castle', () {
      final lockSense = disambiguator.disambiguate(
        word: 'Schloss',
        contextSentence: 'Der Schlüssel passt leider nicht in dieses alte Schloss an der Tür.',
      );
      expect(lockSense?.senseId, equals('schloss_lock'));

      final castleSense = disambiguator.disambiguate(
        word: 'Schloss',
        contextSentence: 'Der König wanderte durch die Prunksäle im Schloss.',
      );
      expect(castleSense?.senseId, equals('schloss_castle'));
    });

    test('Returns null for uncatalogued words', () {
      final result = disambiguator.disambiguate(word: 'Katze', contextSentence: 'Die Katze schnurrt.');
      expect(result, isNull);
    });
  });
}
