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

    final usedAt = timestamp ?? DateTime.now();
    final localUsedAt = usedAt.toLocal();
    final today = DateTime(localUsedAt.year, localUsedAt.month, localUsedAt.day);

    for (final record in usageHistory) {
      final localRecord = record.usedAt.toLocal();
      final recordDay = DateTime(localRecord.year, localRecord.month, localRecord.day);
      if (recordDay == today) {
        // Prevent duplicate freeze consumption on the same local day
        return this;
      }
    }

    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: [
        ...usageHistory,
        FreezeUsageRecord(usedAt: usedAt, reason: reason),
      ],
    );
  }
}
