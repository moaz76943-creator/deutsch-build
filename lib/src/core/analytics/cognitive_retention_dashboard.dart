import 'dart:math';

/// Forecasted retention rate across future milestone intervals.
class RetentionForecast {
  final double day7Retention;
  final double day30Retention;
  final double day90Retention;
  final int totalTrackedItems;
  final int masteredItemsCount; // Stability > 30 days

  const RetentionForecast({
    required this.day7Retention,
    required this.day30Retention,
    required this.day90Retention,
    required this.totalTrackedItems,
    required this.masteredItemsCount,
  });
}

/// Analyzes FSRS-5 stability parameters to project long-term memory curves.
class CognitiveRetentionDashboard {
  const CognitiveRetentionDashboard();

  /// Calculates retention probability R = exp(-t / S) across portfolio items.
  RetentionForecast calculateForecast(List<double> stabilities) {
    if (stabilities.isEmpty) {
      return const RetentionForecast(
        day7Retention: 0.0,
        day30Retention: 0.0,
        day90Retention: 0.0,
        totalTrackedItems: 0,
        masteredItemsCount: 0,
      );
    }

    double sumR7 = 0.0;
    double sumR30 = 0.0;
    double sumR90 = 0.0;
    int masteredCount = 0;

    for (final s in stabilities) {
      final safeS = max(s, 0.1);
      sumR7 += exp(-7.0 / safeS);
      sumR30 += exp(-30.0 / safeS);
      sumR90 += exp(-90.0 / safeS);

      if (safeS >= 30.0) {
        masteredCount++;
      }
    }

    final total = stabilities.length;

    return RetentionForecast(
      day7Retention: double.parse((sumR7 / total * 100.0).toStringAsFixed(1)),
      day30Retention: double.parse((sumR30 / total * 100.0).toStringAsFixed(1)),
      day90Retention: double.parse((sumR90 / total * 100.0).toStringAsFixed(1)),
      totalTrackedItems: total,
      masteredItemsCount: masteredCount,
    );
  }
}
