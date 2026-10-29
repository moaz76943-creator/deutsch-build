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

  StreakFreezeLedger recordUsage(String reason) {
    if (!canConsume) return this;
    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: [
        ...usageHistory,
        FreezeUsageRecord(usedAt: DateTime.now(), reason: reason),
      ],
    );
  }
}
