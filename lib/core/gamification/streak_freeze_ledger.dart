class FreezeUsageRecord {
  final DateTime usedAt;
  final String reason;

  const FreezeUsageRecord({required this.usedAt, required this.reason});
}

/// Immutable-usage-style ledger. A freeze is consumed at most once per local day.
class StreakFreezeLedger {
  final int totalShields;
  final List<FreezeUsageRecord> usageHistory;

  const StreakFreezeLedger({
    this.totalShields = 2,
    this.usageHistory = const [],
  });

  int get remainingShields =>
      (totalShields - usageHistory.length).clamp(0, totalShields < 0 ? 0 : totalShields).toInt();

  bool get canConsume => remainingShields > 0;

  StreakFreezeLedger recordUsage(String reason, {DateTime? timestamp}) {
    if (!canConsume || reason.trim().isEmpty) return this;
    final at = timestamp ?? DateTime.now();
    final local = at.toLocal();
    for (final previous in usageHistory) {
      final day = previous.usedAt.toLocal();
      if (day.year == local.year &&
          day.month == local.month &&
          day.day == local.day) {
        return this;
      }
    }
    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: [
        ...usageHistory,
        FreezeUsageRecord(usedAt: at, reason: reason),
      ],
    );
  }
}
