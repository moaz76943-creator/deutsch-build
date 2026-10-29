import 'package:flutter/foundation.dart';
import '../../core/srs_scheduler.dart';

enum AnalyticsWindow {
  days7(7),
  days30(30),
  days90(90);

  final int days;
  const AnalyticsWindow(this.days);
}

abstract class LocalAnalyticsResult {
  const LocalAnalyticsResult();
}

class LocalAnalyticsUnavailable extends LocalAnalyticsResult {
  const LocalAnalyticsUnavailable();
}

class LocalAnalyticsData extends LocalAnalyticsResult {
  final int totalReviews;
  final double recallAccuracy;
  final double completionRate;
  final String learningTrend; // 'upward', 'downward', 'flat'
  final Map<String, int> dailyReviews; // YYYY-MM-DD -> count

  const LocalAnalyticsData({
    required this.totalReviews,
    required this.recallAccuracy,
    required this.completionRate,
    required this.learningTrend,
    required this.dailyReviews,
  });
}

class LocalLearningAnalytics {
  /// Compute local analytics for a given time window and language pair.
  static Future<LocalAnalyticsResult> generateReport({
    AnalyticsWindow window = AnalyticsWindow.days30,
    String? languagePairKey,
    List<Map<String, dynamic>>? testHistory,
    String? testNowUtc,
  }) async {
    // If we're not in a test, let the isolate read the history directly to avoid heavy serialization on UI thread.
    // However, since UnifiedSrsScheduler is an in-memory singleton, we can't easily access its instance from another isolate
    // because singletons are per-isolate. But the instructions say "avoid loading full progress history into widget memory."
    // Let's pass the list from the main isolate if testHistory is provided, else we pull it here and send it.
    // Given it's in-memory, we have no choice but to pass it from the main isolate unless it's stored in sqflite.
    final history = testHistory ?? UnifiedSrsScheduler.instance.history.map((e) => e.toMap()).toList();
    final nowString = testNowUtc ?? DateTime.now().toUtc().toIso8601String();
    
    final resultParams = await compute(_computeAnalytics, {
      'windowDays': window.days,
      'languagePairKey': languagePairKey,
      'history': history,
      'now': nowString,
    });

    if (resultParams == null) {
      return const LocalAnalyticsUnavailable();
    }

    return LocalAnalyticsData(
      totalReviews: resultParams['totalReviews'] as int,
      recallAccuracy: resultParams['recallAccuracy'] as double,
      completionRate: resultParams['completionRate'] as double,
      learningTrend: resultParams['learningTrend'] as String,
      dailyReviews: Map<String, int>.from(resultParams['dailyReviews'] as Map),
    );
  }

  static Map<String, dynamic>? _computeAnalytics(Map<String, dynamic> params) {
    final int windowDays = params['windowDays'] as int;
    final String? languagePairKey = params['languagePairKey'] as String?;
    final List<Map<String, dynamic>> historyMaps = (params['history'] as List).cast<Map<String, dynamic>>();
    final DateTime nowUtc = DateTime.parse(params['now'] as String).toUtc();

    final List<Map<String, dynamic>> validRecords = [];
    final Set<String> seenEventIds = {};

    for (final map in historyMaps) {
      if (map['reviewEventId'] == null || map['timestamp'] == null || map['learnerContentKey'] == null) continue;

      final String eventId = map['reviewEventId'] as String;
      if (seenEventIds.contains(eventId)) continue;
      seenEventIds.add(eventId);

      final timestampStr = map['timestamp'] as String;
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(timestampStr).toUtc();
      } catch (e) {
        continue;
      }

      if (languagePairKey != null && map['languagePairKey'] != languagePairKey) continue;

      final difference = nowUtc.difference(timestamp).inDays;
      if (difference >= 0 && difference < windowDays) {
        validRecords.add(map);
      }
    }

    if (validRecords.isEmpty) {
      return null;
    }

    int totalReviews = validRecords.length;
    int correctReviews = 0;

    final Set<String> uniqueKeys = {};
    final Set<String> passedKeys = {};
    final Map<String, int> dailyReviews = {};

    int firstHalfCorrect = 0;
    int firstHalfTotal = 0;
    int secondHalfCorrect = 0;
    int secondHalfTotal = 0;
    final int halfWindow = windowDays ~/ 2;

    for (final record in validRecords) {
      final rating = record['rating'] as int? ?? 0;
      final isCorrect = rating >= 2;
      if (isCorrect) correctReviews++;

      final contentKey = record['learnerContentKey'] as String;
      uniqueKeys.add(contentKey);
      if (isCorrect) {
        passedKeys.add(contentKey);
      }

      final timestampUtc = DateTime.parse(record['timestamp'] as String).toUtc();

      // Use explicit local-day grouping by converting to local time before generating the date key
      final localTimestamp = timestampUtc.toLocal();
      final dateKey = "${localTimestamp.year.toString().padLeft(4, '0')}-${localTimestamp.month.toString().padLeft(2, '0')}-${localTimestamp.day.toString().padLeft(2, '0')}";
      dailyReviews[dateKey] = (dailyReviews[dateKey] ?? 0) + 1;

      final diffDays = nowUtc.difference(timestampUtc).inDays;
      if (diffDays < halfWindow) {
        secondHalfTotal++;
        if (isCorrect) secondHalfCorrect++;
      } else {
        firstHalfTotal++;
        if (isCorrect) firstHalfCorrect++;
      }
    }

    final recallAccuracy = totalReviews > 0 ? correctReviews / totalReviews : 0.0;
    final completionRate = uniqueKeys.isNotEmpty ? passedKeys.length / uniqueKeys.length : 0.0;

    final firstHalfRatio = firstHalfTotal > 0 ? firstHalfCorrect / firstHalfTotal : 0.0;
    final secondHalfRatio = secondHalfTotal > 0 ? secondHalfCorrect / secondHalfTotal : 0.0;

    String learningTrend = 'flat';
    if (secondHalfRatio > firstHalfRatio + 0.05) {
      learningTrend = 'upward';
    } else if (secondHalfRatio < firstHalfRatio - 0.05) {
      learningTrend = 'downward';
    }

    return {
      'totalReviews': totalReviews,
      'recallAccuracy': recallAccuracy,
      'completionRate': completionRate,
      'learningTrend': learningTrend,
      'dailyReviews': dailyReviews,
    };
  }
}
