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
    final now = timestamp ?? DateTime.now();

    // Prevent duplicate freeze consumption on the same local day.
    // Ensure we handle local-day boundaries securely.
    for (final record in usageHistory) {
      if (record.usedAt.year == now.year &&
          record.usedAt.month == now.month &&
          record.usedAt.day == now.day) {
        return this; // Already consumed a freeze today.
      }
    }

    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: [
        ...usageHistory,
        FreezeUsageRecord(usedAt: now, reason: reason),
      ],
    );
  }
}
