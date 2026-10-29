import 'dart:math';

/// Tiers in the competitive offline league ladder.
enum LeagueTier { bronze, silver, gold, sapphire, ruby, diamond }

/// Competitor in the offline simulated league leaderboard.
class LeagueCompetitor {
  final String name;
  final int points;
  final bool isUser;

  const LeagueCompetitor({
    required this.name,
    required this.points,
    this.isUser = false,
  });
}

/// Standings result indicating promotion, safety, or demotion.
class LeagueStandingsReport {
  final LeagueTier tier;
  final int userRank; // 1-based rank
  final bool isPromoted; // Top 5
  final bool isDemoted;  // Bottom 5
  final List<LeagueCompetitor> leaderboard;

  const LeagueStandingsReport({
    required this.tier,
    required this.userRank,
    required this.isPromoted,
    required this.isDemoted,
    required this.leaderboard,
  });
}

/// Generates and manages realistic offline weekly leaderboards with zero cloud servers.
class SimulatedLeagueEngine {
  final LeagueTier currentTier;
  final int weekEpochSeed;

  const SimulatedLeagueEngine({
    this.currentTier = LeagueTier.bronze,
    required this.weekEpochSeed,
  });

  /// Computes leaderboard standings with learner score injected.
  LeagueStandingsReport evaluateStandings({required int userScore}) {
    final rand = Random(weekEpochSeed);
    final competitors = <LeagueCompetitor>[];

    // Seed realistic scores based on current tier baseline
    final int baseScore = 200 + (currentTier.index * 150);
    final botNames = [
      'Lukas', 'Emma', 'Tariq', 'Fatima', 'Yuki', 'Chen', 'Mateo', 'Elena',
      'Liam', 'Sophia', 'Omar', 'Amina', 'Dmitry', 'Sora', 'Carlos', 'Zainab'
    ];

    for (final name in botNames) {
      final scoreVariation = rand.nextInt(350) - 100;
      competitors.add(LeagueCompetitor(
        name: name,
        points: max(50, baseScore + scoreVariation),
        isUser: false,
      ));
    }

    // Add user
    competitors.add(LeagueCompetitor(
      name: 'أنت (You)',
      points: userScore,
      isUser: true,
    ));

    // Sort descending by points
    competitors.sort((a, b) => b.points.compareTo(a.points));

    final userRank = competitors.indexWhere((c) => c.isUser) + 1;
    final isPromoted = userRank <= 5;
    final isDemoted = userRank > competitors.length - 3 && currentTier != LeagueTier.bronze;

    return LeagueStandingsReport(
      tier: currentTier,
      userRank: userRank,
      isPromoted: isPromoted,
      isDemoted: isDemoted,
      leaderboard: competitors,
    );
  }
}
