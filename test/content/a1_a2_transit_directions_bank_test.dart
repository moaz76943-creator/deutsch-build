import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a1_a2_transit_directions_bank.dart';

void main() {
  group('A1A2TransitDirectionsBank Unit Tests (L004)', () {
    test('Contains vital transit vocabulary (Bahnhof, Fahrkarte, umsteigen)', () {
      expect(A1A2TransitDirectionsBank.entries.length, greaterThanOrEqualTo(6));

      final train = A1A2TransitDirectionsBank.entries.firstWhere((e) => e.germanWord == 'der Zug');
      expect(train.arabicMeaning, contains('القطار'));
      expect(train.exampleSentenceDe, contains('Gleis 4'));

      final transfer = A1A2TransitDirectionsBank.entries.firstWhere((e) => e.germanWord == 'umsteigen');
      expect(transfer.partOfSpeech, equals('verb'));
      expect(transfer.cefrLevel, equals('A2'));
    });
  });
}
