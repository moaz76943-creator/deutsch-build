import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';

void main() {
  group('StreakFreezeLedger', () {
    test('records usage correctly', () {
      var ledger = const StreakFreezeLedger();
      expect(ledger.remainingShields, 2);

      ledger = ledger.recordUsage('missed day', timestamp: DateTime.now());
      expect(ledger.remainingShields, 1);
    });

    test('prevents duplicate freezes on the same day in local time', () {
      var ledger = const StreakFreezeLedger();
      final now = DateTime(2026, 6, 15, 12);
      ledger = ledger.recordUsage('missed day', timestamp: now);
      ledger = ledger.recordUsage('another reason', timestamp: now.add(const Duration(hours: 1)));

      expect(ledger.remainingShields, 1); // Second freeze ignored
    });

    test('cannot consume when no shields remain', () {
      var ledger = const StreakFreezeLedger();
      final now = DateTime.now();
      ledger = ledger.recordUsage('missed day', timestamp: now);
      ledger = ledger.recordUsage('missed day 2', timestamp: now.add(const Duration(days: 1)));

      expect(ledger.remainingShields, 0);
      expect(ledger.canConsume, false);

      ledger = ledger.recordUsage('missed day 3', timestamp: now.add(const Duration(days: 2)));
      expect(ledger.remainingShields, 0); // No change
    });
  });
}
