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

  StreakFreezeLedger recordUsage(String reason, {DateTime? timestamp}) {
    if (!canConsume) return this;

    final useTime = timestamp ?? DateTime.now();
    final localUseTime = useTime.toLocal();

    // Prevent duplicate freezes for the same day (local-day boundary handling)
    for (final record in usageHistory) {
      final localRecordTime = record.usedAt.toLocal();
      if (localRecordTime.year == localUseTime.year &&
          localRecordTime.month == localUseTime.month &&
          localRecordTime.day == localUseTime.day) {
        return this; // Already used today
      }
    }

    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: [
        ...usageHistory,
        FreezeUsageRecord(usedAt: useTime, reason: reason),
      ],
    );
  }
}
