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
      return OperationResult<AnalyticsReport>.success(AnalyticsReport(
        totalReviews: values['totalReviews'] as int,
        dailyReviewsAverage: values['dailyReviewsAverage'] as int,
        masteredCards: null, // Not evidence-backed by review envelopes.
        completionRate: null, // Requires assigned and finished task counts.
        recallAccuracy: values['recallAccuracy'] as double,
        learningTrend: values['learningTrend'] as String,
        consistencyScore: values['consistencyScore'] as double,
        dailyReviews: Map<String, int>.unmodifiable(
          values['dailyReviews'] as Map<String, int>),
      ));
    } catch (error) {
      return OperationResult<AnalyticsReport>.failure(
        AnalyticsUnavailableFailure('INVALID_HISTORY', '$error'),
      );
    }
  }

  /// Legacy API: no verified input is available, so return explicit unknowns
  /// rather than the old fabricated "120 mastered cards" report.
  static Future<Map<String, dynamic>> generate30DayReport() async => {
    'mastered_cards': null,
    'active_domains': null,
    'learning_trend': 'insufficient_evidence',
    'consistency_score': null,
    'is_verified': false,
  };

  /// Badge grants require a separately verified SRS mastery projection.
  static Future<String?> checkNewBadge() async => null;
}

Map<String, Object> _aggregateCommittedReviews(Map<String, Object> input) {
  final events = input['events'] as List<ReviewTransactionEnvelope>;
  final pairKey = input['pair'] as String;
  final days = input['days'] as int;
  final now = (input['now'] as DateTime).toUtc();
  final start = now.subtract(Duration(days: days));
  final unique = <String, ReviewTransactionEnvelope>{};

  for (final event in events) {
    if (event.languagePairKey != pairKey) continue;
    if (event.reviewEventId.trim().isEmpty ||
        event.learnerContentKey.trim().isEmpty ||
        event.rating < 0 ||
        event.rating > 3) {
      throw const FormatException('Malformed committed review event');
    }
    final existing = unique[event.reviewEventId];
    if (existing != null) {
      if (existing.learnerContentKey != event.learnerContentKey ||
          existing.rating != event.rating ||
          !existing.timestamp.isAtSameMomentAs(event.timestamp)) {
        throw const FormatException('Conflicting reviewId payload');
      }
      continue;
    }
    unique[event.reviewEventId] = event;
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
    // 0=again, 1=hard, 2=good, 3=easy (ReviewRating).
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
