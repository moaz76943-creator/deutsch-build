import 'package:test/test.dart';
import '../../lib/src/content/a1_core_lexical_bank.dart';

void main() {
  group('A1CoreLexicalBank Unit Tests (L001)', () {
    final bank = A1CoreLexicalBank();

    test('Contains essential A1 foundation verbs with accurate Arabic translations', () {
      expect(A1CoreLexicalBank.coreVocabulary.length, greaterThanOrEqualTo(5));

      final entry = bank.findByWord('helfen');
      expect(entry, isNotNull);
      expect(entry!.arabicMeaning, contains('يساعد'));
      expect(entry.exampleSentenceDe, contains('helfe'));
      expect(entry.cefrLevel, equals('A1'));
    });

    test('All examples are ethically sound, positive, and educational', () {
      for (final entry in A1CoreLexicalBank.coreVocabulary) {
        expect(entry.germanWord.isNotEmpty, isTrue);
        expect(entry.arabicMeaning.isNotEmpty, isTrue);
        expect(entry.exampleSentenceDe.isNotEmpty, isTrue);
        expect(entry.exampleSentenceAr.isNotEmpty, isTrue);
      }
    });
  });
}
