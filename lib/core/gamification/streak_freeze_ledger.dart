class FreezeUsageRecord {
  final DateTime usedAt;
  final String reason;

  const FreezeUsageRecord({required this.usedAt, required this.reason});
}

/// سجل محلي شفاف لحساب استهلاك دروع التجميد اليومية
class StreakFreezeLedger {
  final int totalShields;
  final List<FreezeUsageRecord> usageHistory;

  const StreakFreezeLedger({
    this.totalShields = 2,
    this.usageHistory = const [],
  });

  int get remainingShields => totalShields - usageHistory.length;
  bool get canConsume => remainingShields > 0;

<<<<<<< HEAD
  StreakFreezeLedger recordUsage(String reason, {DateTime? now}) {
    if (!canConsume) return this;
    final currentTime = now ?? DateTime.now();

    // Validate freeze consumption and prevent duplicate freezes
    for (final record in usageHistory) {
      final currentLocal = currentTime.toLocal();
      final recordLocal = record.usedAt.toLocal();
      if (recordLocal.year == currentLocal.year &&
          recordLocal.month == currentLocal.month &&
          recordLocal.day == currentLocal.day) {
        return this; // Duplicate freeze prevented
      }
    }

=======
  StreakFreezeLedger recordUsage(String reason) {
    if (!canConsume) return this;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: [
        ...usageHistory,
<<<<<<< HEAD
        FreezeUsageRecord(usedAt: currentTime, reason: reason),
=======
        FreezeUsageRecord(usedAt: DateTime.now(), reason: reason),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      ],
    );
  }
}
