import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

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

/// Local-only learning analytics derived from persisted SRS state.
///
/// No network analytics are emitted. Unsupported metrics remain explicitly
/// unavailable instead of being synthesized from constants.
class LocalLearningAnalytics {
  static const int masteryRepetitions = 3;
  static const int masteryIntervalDays = 21;
  static const String _masteryBadgeReceipt = 'learning/badges/mastery100/v1';
  static const int maxHistoryBatch = 50000;
  static const int maxWindowDays = 366;

  static Future<Map<String, dynamic>> generate30DayReport() async {
    try {
      final rows = await _loadProgressRows();
      return computeReportFromRows(rows);
    } catch (_) {
      return <String, dynamic>{
        'available': false,
        'mastered_cards': 0,
        'active_languages': 0,
        'due_cards': 0,
        'review_days_30d': 0,
        'observed_streak_days': 0,
        'learning_trend': 'unavailable',
        'consistency_score': null,
      };
    }
  }

  static Map<String, dynamic> computeReportFromRows(
    List<Map<String, dynamic>> rows, {
    DateTime? now,
  }) {
    final clock = (now ?? DateTime.now()).toUtc();
    final nowEpoch = clock.millisecondsSinceEpoch ~/ 1000;
    final windowStart =
        clock.subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/
            1000;

    var mastered = 0;
    var due = 0;
    final languages = <String>{};
    final observedReviewDays = <String>{};
    var missingReviewDateEvidence = false;

    for (final row in rows) {
      final repetitions = (row['repetition_count'] as num?)?.toInt() ?? 0;
      final interval = (row['interval_days'] as num?)?.toInt() ?? 0;
      if (repetitions >= masteryRepetitions &&
          interval >= masteryIntervalDays) {
        mastered++;
      }

      final language = row['target_language_code']?.toString().trim() ?? '';
      if (language.isNotEmpty) {
        languages.add(language);
      }

      final dueAt = row['next_due_at'];
      if (dueAt == null || (dueAt is num && dueAt.toInt() <= nowEpoch)) {
        due++;
      }

      final reviewedAt = row['last_reviewed_at'];
      if (reviewedAt is! num && repetitions > 0) {
        missingReviewDateEvidence = true;
      }
      if (reviewedAt is num) {
        final epoch = reviewedAt.toInt();
        if (epoch >= windowStart && epoch <= nowEpoch) {
          final date =
              DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true);
          observedReviewDays.add(_dateKey(date));
        }
      }
    }

    return <String, dynamic>{
      'available': true,
      'mastered_cards': mastered,
      'active_languages': languages.length,
      'due_cards': due,
      'review_days_30d': missingReviewDateEvidence
          ? null
          : observedReviewDays.length,
      'observed_streak_days': missingReviewDateEvidence
          ? null
          : _observedStreakDays(observedReviewDays, clock),
      'learning_trend': 'unavailable',
      'consistency_score': null,
    };
  }

  /// Returns the badge only on the first securely persisted award.
  static Future<String?> checkNewBadge() async {
    final report = await generate30DayReport();
    if (report['available'] != true ||
        (report['mastered_cards'] as int? ?? 0) < 100) {
      return null;
    }

    try {
      final vault = UserVaultSecurityService();
      if (await vault.readRecord(_masteryBadgeReceipt) != null) {
        return null;
      }
      final receipt = Uint8List.fromList(
        utf8.encode(
          jsonEncode(<String, dynamic>{
            'badge': 'mastery100',
            'awarded_at': DateTime.now().toUtc().toIso8601String(),
            'mastered_cards': report['mastered_cards'],
          }),
        ),
      );
      await vault.putRecord(_masteryBadgeReceipt, receipt);
      return 'وسام المائة بطاقة المتقنة';
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> _loadProgressRows() async {
    final vault = UserVaultSecurityService();
    if (await vault.isOperationalActive) {
      final snapshot = await vault.exportOperationalSnapshot();
      return (snapshot['srs'] ?? <Map<String, dynamic>>[])
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);
    }

    final db = await DatabaseService.instance.progressDb;
    final rows = await db.query('srs_progress');
    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  static int _observedStreakDays(Set<String> days, DateTime now) {
    if (days.isEmpty) {
      return 0;
    }
    var cursor = DateTime.utc(now.year, now.month, now.day);
    if (!days.contains(_dateKey(cursor))) {
      final yesterday = cursor.subtract(const Duration(days: 1));
      if (!days.contains(_dateKey(yesterday))) {
        return 0;
      }
      cursor = yesterday;
    }

    var streak = 0;
    while (days.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _dateKey(DateTime value) {
    final utc = value.toUtc();
    return utc.year.toString().padLeft(4, '0') +
        '-' +
        utc.month.toString().padLeft(2, '0') +
        '-' +
        utc.day.toString().padLeft(2, '0');
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

  final scoped = events.where((e) => e.languagePairKey == pairKey).toList();
  final unique = <String, ReviewTransactionEnvelope>{};
  for (final review in scoped) {
    unique[review.reviewEventId] = review;
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
