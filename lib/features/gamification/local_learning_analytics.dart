import 'package:flutter/foundation.dart';
import '../../core/srs_scheduler.dart';

enum AnalyticsWindow { days7, days30, days90 }

class PairMetrics {
  final Map<String, int> dailyReviews;
  final double completionRate;
  final double recallAccuracy;
  final int totalReviews;
  final int uniqueCardsMastered;

  const PairMetrics({
    required this.dailyReviews,
    required this.completionRate,
    required this.recallAccuracy,
    required this.totalReviews,
    required this.uniqueCardsMastered,
  });
}

abstract class LearningAnalyticsResult {}

class AnalyticsDataState extends LearningAnalyticsResult {
  final Map<String, PairMetrics> pairSpecificMetrics;

  AnalyticsDataState(this.pairSpecificMetrics);
}

class AnalyticsUnavailableState extends LearningAnalyticsResult {}

/// محرك تقارير النمو وتحليل بيانات التعلم المحلية
class LocalLearningAnalytics {
  static Future<LearningAnalyticsResult> generateReport(AnalyticsWindow window,
      {DateTime? nowUtc}) async {
    final history = UnifiedSrsScheduler.instance.history;
    if (history.isEmpty) {
      return AnalyticsUnavailableState();
    }

    int windowDays = 30;
    switch (window) {
      case AnalyticsWindow.days7:
        windowDays = 7;
        break;
      case AnalyticsWindow.days30:
        windowDays = 30;
        break;
      case AnalyticsWindow.days90:
        windowDays = 90;
        break;
    }

    final currentUtc = nowUtc ?? DateTime.now().toUtc();
    final input = {
      'history': history.map((e) => e.toMap()).toList(),
      'windowDays': windowDays,
      'currentUtc': currentUtc.toIso8601String(),
    };

    try {
      final result = await compute(_aggregateHistory, input);
      if (result.isEmpty) {
        return AnalyticsUnavailableState();
      }
      return AnalyticsDataState(result);
    } catch (e) {
      debugPrint("Error generating local analytics: $e");
      return AnalyticsUnavailableState();
    }
  }

  static Map<String, PairMetrics> _aggregateHistory(
      Map<String, dynamic> input) {
    final List<dynamic> historyMaps = input['history'] ?? [];
    final int windowDays = input['windowDays'] ?? 30;
    final DateTime currentUtc = DateTime.parse(input['currentUtc']);
    final DateTime threshold = currentUtc.subtract(Duration(days: windowDays));

    // Deduplicate by reviewEventId and safely parse
    final Map<String, Map<String, dynamic>> deduplicated = {};
    for (var envMap in historyMaps) {
      if (envMap is! Map) continue;

      final eventId = envMap['reviewEventId'];
      if (eventId == null || eventId is! String || eventId.isEmpty) continue;

      if (!deduplicated.containsKey(eventId)) {
        deduplicated[eventId] = Map<String, dynamic>.from(envMap);
      }
    }

    final Map<String, List<Map<String, dynamic>>> byPair = {};
    for (var envMap in deduplicated.values) {
      final timestampStr = envMap['timestamp'];
      if (timestampStr == null || timestampStr is! String) continue;

      DateTime timestamp;
      try {
        timestamp = DateTime.parse(timestampStr).toUtc();
      } catch (_) {
        continue; // Skip invalid dates
      }

      if (timestamp.isAfter(threshold) ||
          timestamp.isAtSameMomentAs(threshold)) {
        final pairKey = envMap['languagePairKey'];
        if (pairKey == null || pairKey is! String || pairKey.isEmpty) continue;

        byPair.putIfAbsent(pairKey, () => []).add(envMap);
      }
    }

    final Map<String, PairMetrics> result = {};
    for (var entry in byPair.entries) {
      final pairKey = entry.key;
      final events = entry.value;

      int totalReviews = 0;
      int successfulReviews = 0;
      final Set<String> uniqueCards = {};
      final Set<String> masteredCards = {};
      final Map<String, int> dailyReviews = {};

      for (var envMap in events) {
        final ratingRaw = envMap['rating'];
        if (ratingRaw == null || ratingRaw is! int) continue;

        final rating = ratingRaw;
        final contentKey = envMap['learnerContentKey'];
        if (contentKey == null || contentKey is! String || contentKey.isEmpty) {
          continue;
        }

        totalReviews++;
        if (rating >= 3) {
          successfulReviews++;
        }

        uniqueCards.add(contentKey);
        if (rating >= 4) {
          masteredCards.add(contentKey);
        }

        final timestampStr = envMap['timestamp'] as String;
        final timestamp = DateTime.parse(timestampStr).toUtc();
        // Explicitly defined local-day grouping (UTC date part only)
        final localDayStr =
            "${timestamp.year.toString().padLeft(4, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
        dailyReviews[localDayStr] = (dailyReviews[localDayStr] ?? 0) + 1;
      }

      if (totalReviews == 0) {
        continue; // Skip if all records within pair were corrupted
      }

      double recallAccuracy = successfulReviews / totalReviews;
      double completionRate = uniqueCards.isNotEmpty
          ? masteredCards.length / uniqueCards.length
          : 0.0;

      result[pairKey] = PairMetrics(
        dailyReviews: dailyReviews,
        completionRate: completionRate,
        recallAccuracy: recallAccuracy,
        totalReviews: totalReviews,
        uniqueCardsMastered: masteredCards.length,
      );
    }

    return result;
  }

  /// التحقق من استحقاق المستخدم لوسام جديد
  static Future<String?> checkNewBadge() async {
    final result = await generateReport(AnalyticsWindow.days30);
    if (result is AnalyticsDataState) {
      int totalMastered = 0;
      for (var pm in result.pairSpecificMetrics.values) {
        totalMastered += pm.uniqueCardsMastered;
      }
      if (totalMastered > 100) {
        return 'وسام المائة بطاقة المتقنة';
      }
    }
    return null;
  }
}
