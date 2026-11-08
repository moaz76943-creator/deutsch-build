import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

class StreakProjection {
  final int streakCount;
  final StreakFreezeLedger ledger;
  final DateTime? lastActivityLocalDay;

  const StreakProjection({
    required this.streakCount,
    required this.ledger,
    this.lastActivityLocalDay,
  });
}

class GamificationProjectionEngine {
  /// Calculates deterministic domain mastery from `ReviewTransactionEnvelope` events.
  /// Handles bounding replay windows, deduplication, valid scoring (0-3), and pair isolation.
  static DomainMasteryProjection projectMastery({
    required String domainId,
    required String sourceLanguageId,
    required String targetLanguageId,
    required int eligibleCardCount,
    required List<ReviewTransactionEnvelope> events,
  }) {
    final languagePairKey = '${sourceLanguageId}_$targetLanguageId';

    // Deduplicate by cardId (learnerContentKey) using the most recent event
    final Map<String, ReviewTransactionEnvelope> latestEvents = {};

    for (final event in events) {
      if (event.languagePairKey != languagePairKey) continue;

      // Filter out invalid ratings
      if (event.rating < 0 || event.rating > 3) continue;

      // Filter invalid timestamps (e.g., from the future)
      if (event.timestamp
          .isAfter(DateTime.now().add(const Duration(days: 1)))) {
        continue;
      }

      final existing = latestEvents[event.learnerContentKey];
      if (existing == null || event.timestamp.isAfter(existing.timestamp)) {
        latestEvents[event.learnerContentKey] = event;
      }
    }

    int introducedCount = 0;
    int recalledCount = 0;
    int masteredCount = 0;
    DateTime? lastEvidence;

    for (final event in latestEvents.values) {
      introducedCount++;
      if (event.rating >= 2) {
        // good or easy
        recalledCount++;
        // Consider it mastered if it has a high rating.
        // A more complex mastery rule could be based on multiple reviews,
        // but since we only have envelopes, we use rating == 3 for mastered.
        if (event.rating == 3) {
          masteredCount++;
        }
      }

      if (lastEvidence == null || event.timestamp.isAfter(lastEvidence)) {
        lastEvidence = event.timestamp;
      }
    }

    return DomainMasteryProjection(
      domainId: domainId,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      eligibleCardCount: eligibleCardCount,
      introducedCardCount: introducedCount,
      recalledCardCount: recalledCount,
      masteredCardCount: masteredCount,
      dueCardCount: 0, // Simplified for projection
      lastEvidenceUtc:
          lastEvidence ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      masteryRevision: latestEvents.length,
    );
  }

  /// Reconstructs streaks safely by isolating valid daily events, applying freeze recovery
  /// logic cleanly, and correctly respecting local days to avoid additive inflation.
  static StreakProjection projectStreak({
    required List<DateTime> activityTimestamps,
    required StreakFreezeLedger initialLedger,
    required DateTime todayLocal,
  }) {
    if (activityTimestamps.isEmpty) {
      return StreakProjection(
        streakCount: 0,
        ledger: initialLedger,
        lastActivityLocalDay: null,
      );
    }

    // Sort timestamps chronologically and filter valid past dates
    final sortedLocalDates = activityTimestamps
        .where((ts) => !ts.isAfter(todayLocal.add(const Duration(days: 1))))
        .map((ts) => ts.toLocal())
        .map((local) => DateTime(local.year, local.month, local.day))
        .toList()
      ..sort();

    // Deduplicate by local day
    final Set<DateTime> uniqueLocalDaysSet = {};
    final List<DateTime> uniqueLocalDays = [];
    for (final day in sortedLocalDates) {
      if (uniqueLocalDaysSet.add(day)) {
        uniqueLocalDays.add(day);
      }
    }

    if (uniqueLocalDays.isEmpty) {
      return StreakProjection(
        streakCount: 0,
        ledger: initialLedger,
        lastActivityLocalDay: null,
      );
    }

    int currentStreak = 1;
    StreakFreezeLedger currentLedger = initialLedger;
    DateTime lastDay = uniqueLocalDays.first;

    for (int i = 1; i < uniqueLocalDays.length; i++) {
      final currentDay = uniqueLocalDays[i];
      final difference = currentDay.difference(lastDay).inDays;

      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        // Gap detected, try to consume freezes
        int gapsToFill = difference - 1;
        bool streakBroken = false;

        while (gapsToFill > 0) {
          if (currentLedger.canConsume) {
            // Provide a timestamp that falls on the missed day
            final missedDay = lastDay.add(const Duration(days: 1));
            currentLedger = currentLedger.recordUsage('streak_recovery',
                timestamp: missedDay);
            currentStreak++;
            gapsToFill--;
            lastDay = missedDay;
          } else {
            streakBroken = true;
            break;
          }
        }

        if (streakBroken) {
          currentStreak = 1;
        } else {
          // Survived the gap
          currentStreak++;
        }
      }

      lastDay = currentDay;
    }

    // Now check if there's a gap between the last activity and today
    final differenceToToday = todayLocal.difference(lastDay).inDays;
    if (differenceToToday > 1) {
      int gapsToFill = differenceToToday -
          1; // don't count today as missed yet if they haven't played, only past days
      bool streakBroken = false;

      while (gapsToFill > 0) {
        if (currentLedger.canConsume) {
          final missedDay = lastDay.add(const Duration(days: 1));
          currentLedger = currentLedger.recordUsage('streak_recovery',
              timestamp: missedDay);
          gapsToFill--;
          lastDay = missedDay;
        } else {
          streakBroken = true;
          break;
        }
      }

      if (streakBroken) {
        currentStreak = 0; // Streak is lost
      }
    } else if (differenceToToday == 1) {
      // It's the next day, streak is at risk but not lost yet
    }

    return StreakProjection(
      streakCount: currentStreak,
      ledger: currentLedger,
      lastActivityLocalDay: uniqueLocalDays.last,
    );
  }
}
