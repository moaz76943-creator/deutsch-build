import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/compassionate_resumption_engine.dart';

void main() {
  group('CompassionateResumptionEngine Tests', () {
    const engine = CompassionateResumptionEngine(maxImmediateDayOne: 15, minWarmupItems: 5);

    test('Regular one day gap returns standard direct plan', () {
      final items = List.generate(
        10,
        (i) => OverdueItem(id: 'item_$i', term: 'Wort_$i', stability: 2.0, difficulty: 0.3, daysOverdue: 1),
      );

      final plan = engine.generatePlan(daysInactive: 1, backlog: items, previousStreak: 5);

      expect(plan.daysInactive, equals(1));
      expect(plan.dayOneBatch.length, equals(10));
      expect(plan.deferredSchedule, isEmpty);
      expect(plan.isGraceStreakAwarded, isFalse);
    });

    test('Decongests massive backlog after 14 days absence into smoothed batches', () {
      final items = List.generate(
        100,
        (i) => OverdueItem(
          id: 'item_$i',
          term: 'Wort_$i',
          stability: (i % 5 + 1).toDouble(),
          difficulty: ((100 - i) / 100.0),
          daysOverdue: 14,
        ),
      );

      final plan = engine.generatePlan(daysInactive: 14, backlog: items, previousStreak: 12);

      expect(plan.daysInactive, equals(14));
      expect(plan.totalBacklog, equals(100));
      // Capped by maxImmediateDayOne = 15
      expect(plan.dayOneBatch.length, equals(15));
      expect(plan.recoveryPeriodDays, greaterThanOrEqualTo(3));
      expect(plan.deferredSchedule.isNotEmpty, isTrue);
      expect(plan.isGraceStreakAwarded, isTrue);

      // Verifies high stability items are scheduled first
      expect(plan.dayOneBatch.first.stability, greaterThanOrEqualTo(plan.dayOneBatch.last.stability));
    });

    test('JSON serialization outputs valid telemetry map', () {
      final items = [
        const OverdueItem(id: '1', term: 'Haus', stability: 3.0, difficulty: 0.2, daysOverdue: 5),
      ];

      final plan = engine.generatePlan(daysInactive: 5, backlog: items, previousStreak: 2);
      final json = plan.toJson();

      expect(json['daysInactive'], equals(5));
      expect(json['totalBacklog'], equals(1));
      expect(json.containsKey('encouragingMessage'), isTrue);
    });
  });
}
