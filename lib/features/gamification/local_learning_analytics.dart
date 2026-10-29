import 'dart:convert';
import 'dart:typed_data';

import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Local-only learning analytics derived from persisted SRS state.
///
/// No network analytics are emitted. Unsupported metrics remain explicitly
/// unavailable instead of being synthesized from constants.
class LocalLearningAnalytics {
  static const int masteryRepetitions = 3;
  static const int masteryIntervalDays = 21;
  static const String _masteryBadgeReceipt =
      'learning/badges/mastery100/v1';

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
      'review_days_30d': observedReviewDays.length,
      'observed_streak_days': _observedStreakDays(
        observedReviewDays,
        clock,
      ),
      // A complete event history is not part of the current shared progress
      // contract, so trend and consistency are not inferred from last-state rows.
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
      // Never claim a new reward if its durable receipt could not be stored.
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
}
