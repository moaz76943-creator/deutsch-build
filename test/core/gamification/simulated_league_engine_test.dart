import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/gamification/simulated_league_engine.dart';

void main() {
  group('SimulatedLeagueEngine Tests', () {
    test('Calculates deterministic rankings and awards promotion for high scores', () {
      const engine = SimulatedLeagueEngine(
        currentTier: LeagueTier.silver,
        weekEpochSeed: 42,
      );

      final report = engine.evaluateStandings(userScore: 1200); // Very high score

      expect(report.userRank, equals(1));
      expect(report.isPromoted, isTrue);
      expect(report.isDemoted, isFalse);
      expect(report.leaderboard.first.isUser, isTrue);
    });

    test('Identifies demotion zone for low scores in non-bronze tiers', () {
      const engine = SimulatedLeagueEngine(
        currentTier: LeagueTier.gold,
        weekEpochSeed: 42,
      );

      final report = engine.evaluateStandings(userScore: 10); // Very low score

      expect(report.userRank, greaterThan(report.leaderboard.length - 3));
      expect(report.isDemoted, isTrue);
    });
  });
}
