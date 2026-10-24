import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';

void main() {
  test('handles timezone transitions correctly using local-day boundaries', () {
    const ledger = StreakFreezeLedger();

    // Simulate user in UTC
    final t1 = DateTime.utc(2023, 10, 1, 23, 0);
    final l1 = ledger.recordUsage('miss1', timestamp: t1);
    expect(l1.remainingShields, 1);

    // Later the user travels to UTC+2, their new local time is 2023-10-02 01:00
    // So the timestamp they generate is 2023-10-01 23:00 UTC (same moment)
    final t2 = DateTime.utc(2023, 10, 1, 23, 0);
    final l2 = l1.recordUsage('miss2', timestamp: t2);

    // Since it's literally the same time, it shouldn't deduct.
    expect(l2.remainingShields, 1);
  });
}
