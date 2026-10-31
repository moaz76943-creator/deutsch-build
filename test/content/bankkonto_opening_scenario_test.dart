import 'package:test/test.dart';
import '../../lib/src/content/bankkonto_opening_scenario.dart';

void main() {
  group('BankkontoOpeningScenario Unit Tests (L022)', () {
    test('Contains complete realistic checking account opening procedure', () {
      expect(BankkontoOpeningScenario.turns.length, equals(5));

      final firstTurn = BankkontoOpeningScenario.turns.first;
      expect(firstTurn.utteranceDe, contains('Bank helfen'));

      final opening = BankkontoOpeningScenario.turns[1];
      expect(opening.utteranceDe, contains('Girokonto'));
      expect(opening.utteranceAr, contains('حساب جاري'));
    });
  });
}
