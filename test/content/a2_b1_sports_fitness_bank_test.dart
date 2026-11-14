import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a2_b1_sports_fitness_bank.dart';

void main() {
  group('A2B1SportsFitnessBank Unit Tests (L017)', () {
    test('Contains wholesome sports, swimming, and ethical fitness vocabulary', () {
      expect(A2B1SportsFitnessBank.sportEntries.length, greaterThanOrEqualTo(5));

      final swim = A2B1SportsFitnessBank.sportEntries.firstWhere((e) => e.germanWord == 'das Schwimmen');
      expect(swim.arabicMeaning, contains('السباحة'));

      final sportsmanship = A2B1SportsFitnessBank.sportEntries.firstWhere((e) => e.germanWord == 'der Sportsgeist');
      expect(sportsmanship.arabicMeaning, contains('الروح الرياضية'));
      expect(sportsmanship.cefrLevel, equals('B1'));
    });
  });
}
