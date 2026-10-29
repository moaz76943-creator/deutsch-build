import 'package:flutter/foundation.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

/// A factual summary of committed review events for ONE versioned directed pair.
/// Mastery and task completion cannot be inferred from raw review ratings.
class AnalyticsReport {
  final int totalReviews;
  final int dailyReviewsAverage;
  final int? masteredCards;
  final double? completionRate;
  final double recallAccuracy;
  final String learningTrend;
  final double consistencyScore;
  final Map<String, int> dailyReviews;

  const AnalyticsReport({
    required this.totalReviews,
    required this.dailyReviewsAverage,
    required this.masteredCards,
    required this.completionRate,
    required this.recallAccuracy,
    required this.learningTrend,
    required this.consistencyScore,
    required this.dailyReviews,
  });
}

class AnalyticsUnavailableFailure extends OperationFailure {
  const AnalyticsUnavailableFailure(super.code, super.message);
}

class LocalLearningAnalytics {
  static const int maxHistoryBatch = 50000;
  static const int maxWindowDays = 366;

  /// Backwards-compatible mock-free report. Never synthesize progress.
  static Future<Map<String, dynamic>> generate30DayReport() async {
    return {
      'mastered_cards': 0,
      'active_domains': 0,
      'learning_trend': 'insufficient_evidence',
      'consistency_score': 0,
    };
  }

  /// Backwards-compatible badge check.
  static Future<String?> checkNewBadge() async {
    return null;
  }

  /// The caller MUST supply only already-committed records from the canonical
  /// durable progress writer. Unversioned pairs never silently match.
  static Future<OperationResult<AnalyticsReport>> generateReport({
    required List<ReviewTransactionEnvelope> history,
    required DirectedPairId pairId,
    required int daysWindow,
    required DateTime referenceDateUtc,
  }) async {
    if (!pairId.isValidForLearning() ||
        daysWindow < 1 ||
        daysWindow > maxWindowDays ||
        history.length > maxHistoryBatch) {
      return const OperationResult<AnalyticsReport>.failure(
        AnalyticsUnavailableFailure('INVALID_INPUT', 'Invalid pair/window/batch'),
      );
    }
    try {
      final values = await compute(_aggregateCommittedReviews, <String, Object>{
        'events': history,
        'pair': pairId.uniqueKey,
        'days': daysWindow,
        'now': referenceDateUtc.toUtc(),
      });
      return OperationResult<AnalyticsReport>.success(
        AnalyticsReport(
          totalReviews: values['totalReviews'] as int,
          dailyReviewsAverage: values['dailyReviewsAverage'] as int,
          masteredCards: null,
          completionRate: null,
          recallAccuracy: values['recallAccuracy'] as double,
          learningTrend: values['learningTrend'] as String,
          consistencyScore: values['consistencyScore'] as double,
          dailyReviews: Map<String, int>.from(values['dailyReviews'] as Map),
        ),
      );
    } catch (e) {
      return OperationResult<AnalyticsReport>.failure(
        AnalyticsUnavailableFailure('COMPUTE_FAILED', e.toString()),
      );
    }
  }
}

Map<String, Object> _aggregateCommittedReviews(Map<String, Object> params) {
  final events = (params['events'] as List).cast<ReviewTransactionEnvelope>();
  final pairKey = params['pair'] as String;
  final days = params['days'] as int;
  final now = params['now'] as DateTime;
  final start = now.subtract(Duration(days: days));

  final scoped = events.where((e) => e.pairId.uniqueKey == pairKey).toList();
  final unique = <String, ReviewTransactionEnvelope>{};
  for (final review in scoped) {
    unique[review.eventId] = review;
  }

  final inWindow = unique.values.where((e) =>
      e.timestamp.isAfter(start) && !e.timestamp.isAfter(now)).toList();
  inWindow.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final daily = <String, int>{};
  var successful = 0;
  var early = 0;
  var late = 0;
  final midpoint = start.add(Duration(seconds: days * 86400 ~/ 2));
  for (final review in inWindow) {
    if (review.rating >= 2) successful++;
    if (review.timestamp.isBefore(midpoint)) {
      early++;
    } else {
      late++;
    }
    final day = review.timestamp.toLocal();
    final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    daily[dateKey] = (daily[dateKey] ?? 0) + 1;
  }
  final count = inWindow.length;
  return <String, Object>{
    'totalReviews': count,
    'dailyReviewsAverage': count ~/ days,
    'recallAccuracy': count == 0 ? 0.0 : successful / count,
    'learningTrend': early == late ? 'stable' : (late > early ? 'upward' : 'downward'),
    'consistencyScore': ((daily.length / days) * 100.0).clamp(0.0, 100.0).toDouble(),
    'dailyReviews': daily,
  };
}
