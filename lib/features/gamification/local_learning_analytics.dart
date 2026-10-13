import 'package:flutter/foundation.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

class AnalyticsReport {
  final int totalReviews;
  final int dailyReviewsAverage;
  final int masteredCards;
  final double completionRate;
  final double recallAccuracy;
  final String learningTrend;
  final double consistencyScore;
  final Map<String, int> dailyReviews;

  AnalyticsReport({
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
  
  static Future<OperationResult<AnalyticsReport>> generateReport({
    required List<ReviewTransactionEnvelope> history,
    required DirectedPairId pairId,
    required int daysWindow,
    required DateTime referenceDateUtc,
  }) async {
    try {
      final reportMap = await compute(_aggregateAnalytics, {
        'history': history,
        'pairKey': pairId.uniqueKey,
        'daysWindow': daysWindow,
        'referenceDateUtc': referenceDateUtc.toIso8601String(),
      });

      final report = AnalyticsReport(
        totalReviews: reportMap['totalReviews'] as int,
        dailyReviewsAverage: reportMap['dailyReviewsAverage'] as int,
        masteredCards: reportMap['masteredCards'] as int,
        completionRate: reportMap['completionRate'] as double,
        recallAccuracy: reportMap['recallAccuracy'] as double,
        learningTrend: reportMap['learningTrend'] as String,
        consistencyScore: reportMap['consistencyScore'] as double,
        dailyReviews: Map<String, int>.from(reportMap['dailyReviews'] as Map),
      );

      return OperationResult.success(report);
    } catch (e) {
      return OperationResult.failure(
        AnalyticsUnavailableFailure('ANALYTICS_ERR', 'Failed to generate report: $e'),
      );
    }
  }

  static Future<OperationResult<String>> checkNewBadge({
    required List<ReviewTransactionEnvelope> history,
    required DirectedPairId pairId,
    required DateTime referenceDateUtc,
  }) async {
    final result = await generateReport(
      history: history,
      pairId: pairId,
      daysWindow: 30,
      referenceDateUtc: referenceDateUtc,
    );
    
    if (result.isSuccess) {
      if (result.data.masteredCards > 100) {
        return const OperationResult.success('وسام المائة بطاقة المتقنة');
      }
      return const OperationResult.success('');
    }
    return OperationResult.failure(result.failure);
  }

  static Map<String, dynamic> _aggregateAnalytics(Map<String, dynamic> params) {
    final rawHistory = params['history'] as List<ReviewTransactionEnvelope>;
    final pairKey = params['pairKey'] as String;
    final daysWindow = params['daysWindow'] as int;
    final refDate = DateTime.parse(params['referenceDateUtc'] as String);

    final records = <_ParsedRecord>[];
    for (final raw in rawHistory) {
      if (raw.languagePairKey != pairKey) continue;

      records.add(_ParsedRecord(
        id: raw.reviewEventId,
        contentKey: raw.learnerContentKey,
        rating: raw.rating,
        timestamp: raw.timestamp,
      ));
    }

    final uniqueRecordsMap = <String, _ParsedRecord>{};
    for (final r in records) {
      uniqueRecordsMap[r.id] = r;
    }
    final uniqueRecords = uniqueRecordsMap.values.toList();

    final windowStart = refDate.subtract(Duration(days: daysWindow));

    final windowRecords = uniqueRecords.where((r) {
      return r.timestamp.isAfter(windowStart) && (r.timestamp.isBefore(refDate) || r.timestamp.isAtSameMomentAs(refDate));
    }).toList();

    windowRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int totalReviews = windowRecords.length;

    double recallAccuracy = 0.0;
    if (totalReviews > 0) {
      int correct = windowRecords.where((r) => r.rating >= 3).length;
      recallAccuracy = correct / totalReviews;
    }

    final activeDays = <String>{};
    final dailyReviews = <String, int>{};

    for (final r in windowRecords) {
      final localTs = r.timestamp.toLocal();
      final localDay = '${localTs.year}-${localTs.month.toString().padLeft(2, '0')}-${localTs.day.toString().padLeft(2, '0')}';
      activeDays.add(localDay);
      dailyReviews[localDay] = (dailyReviews[localDay] ?? 0) + 1;
    }

    double consistencyScore = daysWindow > 0 ? (activeDays.length / daysWindow) * 100.0 : 0.0;
    if (consistencyScore > 100) consistencyScore = 100.0;

    double completionRate = daysWindow > 0 ? activeDays.length / daysWindow : 0.0;

    final latestRatings = <String, int>{};
    for (final r in uniqueRecords) { // Use all unique records, not just windowRecords
      latestRatings[r.contentKey] = r.rating;
    }
    int masteredCards = latestRatings.values.where((rating) => rating >= 4).length;

    final midPoint = windowStart.add(Duration(days: daysWindow ~/ 2));
    int firstHalfReviews = windowRecords.where((r) => r.timestamp.isBefore(midPoint)).length;
    int secondHalfReviews = windowRecords.where((r) => r.timestamp.isAfter(midPoint) || r.timestamp.isAtSameMomentAs(midPoint)).length;

    String learningTrend = 'stable';
    if (secondHalfReviews > firstHalfReviews) {
      learningTrend = 'upward';
    } else if (secondHalfReviews < firstHalfReviews && firstHalfReviews > 0) {
      learningTrend = 'downward';
    }

    int dailyReviewsAverage = daysWindow > 0 ? totalReviews ~/ daysWindow : 0;

    return {
      'totalReviews': totalReviews,
      'dailyReviewsAverage': dailyReviewsAverage,
      'masteredCards': masteredCards,
      'completionRate': completionRate,
      'recallAccuracy': recallAccuracy,
      'learningTrend': learningTrend,
      'consistencyScore': consistencyScore,
      'dailyReviews': dailyReviews,
    };
  }
}

class _ParsedRecord {
  final String id;
  final String contentKey;
  final int rating;
  final DateTime timestamp;

  _ParsedRecord({
    required this.id,
    required this.contentKey,
    required this.rating,
    required this.timestamp,
  });
}
