import 'package:flutter/foundation.dart' show compute, debugPrint;
import '../../core/srs_scheduler.dart';
import '../../core/progress/review_transaction_envelope.dart';

sealed class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsUnavailable extends AnalyticsState {
  final String reason;
  const AnalyticsUnavailable(this.reason);
}

class AnalyticsData extends AnalyticsState {
  final int totalReviews;
  final double recallAccuracy;
  final double completionRate;
  final Map<DateTime, int> dailyReviews;
  final String learningTrend;
  final int masteredCards;

  const AnalyticsData({
    required this.totalReviews,
    required this.recallAccuracy,
    required this.completionRate,
    required this.dailyReviews,
    required this.learningTrend,
    required this.masteredCards,
  });
}

class LocalLearningAnalytics {
  /// Aggregates progress based on the requested window using isolated processing
  static Future<AnalyticsState> analyze({
    required String languagePairKey,
    required int daysWindow,
    DateTime? currentTime,
    List<ReviewTransactionEnvelope>? testHistory,
  }) async {
    try {
      final history = testHistory ?? UnifiedSrsScheduler.instance.history;

      if (history.isEmpty) {
        return const AnalyticsData(
          totalReviews: 0,
          recallAccuracy: 0.0,
          completionRate: 0.0,
          dailyReviews: {},
          learningTrend: 'flat',
          masteredCards: 0,
        );
      }

      final now = (currentTime ?? DateTime.now()).toUtc();

      // Limit memory by isolating computation
      final resultMap = await compute(_processAnalytics, {
        'history': history.map((e) => e.toMap()).toList(),
        'languagePairKey': languagePairKey,
        'daysWindow': daysWindow,
        'now': now.millisecondsSinceEpoch,
      });

      if (resultMap['error'] != null) {
        return AnalyticsUnavailable(resultMap['error'] as String);
      }

      return AnalyticsData(
        totalReviews: resultMap['totalReviews'] as int,
        recallAccuracy: resultMap['recallAccuracy'] as double,
        completionRate: resultMap['completionRate'] as double,
        dailyReviews: (resultMap['dailyReviews'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(DateTime.parse(k), v as int),
        ),
        learningTrend: resultMap['learningTrend'] as String,
        masteredCards: resultMap['masteredCards'] as int,
      );
    } catch (e) {
      return AnalyticsUnavailable("Failed to process analytics: $e");
    }
  }

  /// توليد تقرير النمو لآخر 30 يوماً
  static Future<Map<String, dynamic>> generate30DayReport({
    String languagePairKey = 'unknown',
  }) async {
    debugPrint("جاري توليد تقرير النمو محلياً...");
    final state = await analyze(languagePairKey: languagePairKey, daysWindow: 30);

    if (state is AnalyticsData) {
      return {
        'mastered_cards': state.masteredCards,
        'learning_trend': state.learningTrend,
        'consistency_score': (state.completionRate * 100).toInt(),
      };
    }

    return {
      'mastered_cards': 0,
      'learning_trend': 'flat',
      'consistency_score': 0,
    };
  }

  /// التحقق من استحقاق المستخدم لوسام جديد
  static Future<String?> checkNewBadge({
    String languagePairKey = 'unknown',
  }) async {
    final report = await generate30DayReport(languagePairKey: languagePairKey);
    if ((report['mastered_cards'] as int) > 100) {
      return 'وسام المائة بطاقة المتقنة';
    }
    return null;
  }
}

Map<String, dynamic> _processAnalytics(Map<String, dynamic> params) {
  try {
    final rawHistory = params['history'] as List<dynamic>;
    final targetPairKey = params['languagePairKey'] as String;
    final daysWindow = params['daysWindow'] as int;
    final nowMs = params['now'] as int;
    final nowUtc = DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true);

    final windowStart = nowUtc.subtract(Duration(days: daysWindow));

    final seenEventIds = <String>{};

    int totalReviews = 0;
    int correctReviews = 0;

    final dailyReviewsCount = <DateTime, int>{};
    final latestRatings = <String, Map<String, dynamic>>{};

    int h1Reviews = 0;
    int h2Reviews = 0;
    final halfWindowMs = (daysWindow * 86400000) ~/ 2;
    final midPoint = windowStart.add(Duration(milliseconds: halfWindowMs));

    for (var i = 0; i < rawHistory.length; i++) {
      final rawEnv = rawHistory[i];
      if (rawEnv is! Map) continue;

      final eventId = rawEnv['reviewEventId']?.toString();
      final pairKey = rawEnv['languagePairKey']?.toString();
      final contentKey = rawEnv['learnerContentKey']?.toString();
      final ratingRaw = rawEnv['rating'];
      final timestampStr = rawEnv['timestamp']?.toString();

      if (eventId == null || eventId.isEmpty) continue;
      if (pairKey != targetPairKey) continue;
      if (contentKey == null || contentKey.isEmpty) continue;
      if (ratingRaw == null) continue;
      if (timestampStr == null) continue;

      final rating = ratingRaw is int ? ratingRaw : int.tryParse(ratingRaw.toString()) ?? 0;

      if (seenEventIds.contains(eventId)) continue;
      seenEventIds.add(eventId);

      final timestamp = DateTime.tryParse(timestampStr)?.toUtc();
      if (timestamp == null) continue;

      if (timestamp.isBefore(windowStart)) continue;
      if (timestamp.isAfter(nowUtc)) continue;

      totalReviews++;
      if (rating >= 3) {
        correctReviews++;
      }

      final dayKey = DateTime.utc(timestamp.year, timestamp.month, timestamp.day);
      dailyReviewsCount[dayKey] = (dailyReviewsCount[dayKey] ?? 0) + 1;

      if (timestamp.isBefore(midPoint)) {
        h1Reviews++;
      } else {
        h2Reviews++;
      }

      final currentLatest = latestRatings[contentKey];
      if (currentLatest == null || timestamp.isAfter(currentLatest['ts'] as DateTime)) {
        latestRatings[contentKey] = {'ts': timestamp, 'rating': rating};
      }
    }

    final recallAccuracy = totalReviews > 0 ? (correctReviews / totalReviews) : 0.0;
    final completionRate = dailyReviewsCount.length / (daysWindow > 0 ? daysWindow : 1);

    int masteredCards = 0;
    for (final info in latestRatings.values) {
      if ((info['rating'] as int) >= 4) {
        masteredCards++;
      }
    }

    String learningTrend = 'flat';
    if (h2Reviews > (h1Reviews * 1.1)) {
      learningTrend = 'upward';
    } else if (h2Reviews < (h1Reviews * 0.9) && h1Reviews > 0) {
      learningTrend = 'downward';
    }

    return {
      'totalReviews': totalReviews,
      'recallAccuracy': recallAccuracy,
      'completionRate': completionRate.clamp(0.0, 1.0),
      'dailyReviews': dailyReviewsCount.map((k, v) => MapEntry(k.toIso8601String(), v)),
      'learningTrend': learningTrend,
      'masteredCards': masteredCards,
    };
  } catch (e) {
    return {'error': e.toString()};
  }
}
