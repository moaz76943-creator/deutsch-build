class FreezeUsageRecord {
  final DateTime usedAt;
  final String reason;
  const FreezeUsageRecord({required this.usedAt, required this.reason});
}

/// Local calendar days, no phone permission, no wall-clock streak fabrication.
class StreakFreezeLedger {
  static const int maxShields = 366;
  final int totalShields;
  final List<FreezeUsageRecord> usageHistory;

  const StreakFreezeLedger({
    this.totalShields = 2,
    this.usageHistory = const [],
  });

  int get _capacity => totalShields <= 0 ? 0 : totalShields.clamp(0, maxShields).toInt();

  String _calendarKey(DateTime time) {
    final day = time.toLocal();
    return '${day.year}-${day.month}-${day.day}';
  }

  int get remainingShields {
    if (_capacity <= 0) return 0;
    final used = <String>{};
    for (final record in usageHistory) {
      used.add(_calendarKey(record.usedAt));
      if (used.length >= _capacity) break;
    }
    final remaining = _capacity - used.length;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canConsume => remainingShields > 0;

  StreakFreezeLedger recordUsage(String reason, {DateTime? timestamp}) {
    if (!canConsume || reason.trim().isEmpty) return this;
    final usedAt = timestamp ?? DateTime.now();
    final day = _calendarKey(usedAt);
    if (usageHistory.any((record) => _calendarKey(record.usedAt) == day)) {
      return this;
    }
    if (usageHistory.length >= maxShields) return this;
    return StreakFreezeLedger(
      totalShields: totalShields,
      usageHistory: List<FreezeUsageRecord>.unmodifiable([
        ...usageHistory,
        FreezeUsageRecord(usedAt: usedAt, reason: reason),
      ]),
    );
  }
}
