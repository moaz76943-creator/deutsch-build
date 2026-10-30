import 'package:test/test.dart';
import '../../lib/src/core/curriculum/cultural_metaphor_decoder.dart';

void main() {
  group('CulturalMetaphorDecoder Unit Tests (N037)', () {
    final decoder = CulturalMetaphorDecoder();

    test('Correctly identifies and decodes "nur Bahnhof verstehen"', () {
      final match = decoder.detectIdiom('Entschuldigung, ich verstehe hier wirklich nur Bahnhof.');
      expect(match, isNotNull);
      expect(match!.idiom, equals('nur Bahnhof verstehen'));
      expect(match.communicativeMeaning, contains('incomprehensible'));
      expect(match.equivalentInEnglish, equals('It is all Greek to me.'));
    });

    test('Decodes "die Daumen drücken" wishing luck', () {
      final match = decoder.detectIdiom('Morgen habe ich meine B2-Prüfung. Bitte drücke mir die Daumen!');
      expect(match, isNotNull);
      expect(match!.communicativeMeaning, contains('luck'));
      expect(match.equivalentInEnglish, contains('fingers crossed'));
    });

    test('Returns null for ordinary literal sentences', () {
      final match = decoder.detectIdiom('Der Zug kommt pünktlich am Hauptbahnhof an.');
      expect(match, isNull);
    });
  });
}
