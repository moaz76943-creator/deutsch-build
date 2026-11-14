import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';


void main() {
  group('StreakFreezeLedger J060', () {
    test('ledger consumes freeze correctly', () {
      const ledger = StreakFreezeLedger();
      expect(ledger.remainingShields, 2);
      expect(ledger.canConsume, isTrue);

      final newLedger = ledger.recordUsage('missed day');
      expect(newLedger.remainingShields, 1);
    });
  });
}
